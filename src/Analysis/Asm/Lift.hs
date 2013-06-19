{-# LANGUAGE UnicodeSyntax, RecordWildCards, FlexibleInstances, DoAndIfThenElse #-}
-------------------------------------------------------------------------------
-- Module    :  Analysis.Asm.Lift
-- Copyright :  (c) 2013 Marcelo Sousa
-- Inline Asm 
-------------------------------------------------------------------------------

module Analysis.Asm.Lift(liftAsm) where

import Language.LLVMIR hiding (Id)
import qualified Language.LLVMIR as IR
import Language.LLVMIR.Util
import qualified Language.Asm as AS

import qualified Data.Map as M
import qualified Data.Set as S
import Prelude.Unicode ((⧺),(≡))


import Control.Monad
import Control.Applicative
import Control.Monad.State hiding (lift)

(↣) ∷ (Monad m) ⇒ a → m a
(↣) = return

(∘) :: Ord α ⇒ α → S.Set α → S.Set α
(∘) = S.insert

(∈) ∷ Ord α ⇒ α → S.Set α → Bool
(∈) = S.member

-- A bit of unicode non-sense
(∪) ∷ Ord κ ⇒ M.Map κ α → M.Map κ α → M.Map κ α
(∪) = M.union

ε ∷ Ord κ ⇒ M.Map κ α
ε = M.empty

type Id = Identifier

type ΕState α = State Ε α

-- Environment
data Ε = Ε 
	{ fn ∷ (Id, Int)   -- Current Function
	, names ∷ S.Set Id -- Names
	, asmfn ∷ Functions -- Created Functions
  	}

-- update the function in the
-- environment
νfn ∷ (Id,Int) → ΕState ()
νfn n = do γ@Ε{..} ← get
           put γ{fn = n}

νasmfn ∷ (Id,Function) → ΕState ()
νasmfn (i,f) = do γ@Ε{..} ← get
                  let fns = M.insert i f asmfn
                  put γ{asmfn = fns}

νname ∷ Id → ΕState ()
νname i = do γ@Ε{..} ← get
             let n = i ∘ names
             put γ{names=n}

δfn ∷ ΕState (Id,Int)
δfn = do γ@Ε{..} ← get
         (↣) fn

δnames ∷ ΕState (S.Set Id)
δnames = do γ@Ε{..} ← get
            (↣) names

buildName ∷ Id → Int → Id
buildName (Global s) n = Global $ s ⧺ show n
buildName (Local _) _ = error "buildName: Local given"

freshName ∷ ΕState Id
freshName = do γ@Ε{..} ← get
               let n = uncurry buildName fn
                   fn' = (fst fn,(snd fn) + 1)
               νfn fn'
               if n ∈ names
               then freshName
               else do νname n
                       (↣) n

εΕ ∷ Module → Ε
εΕ m = Ε (Global "",0) (getNames m) ε

-------------------------------------------------------------------------------
liftAsm ∷ Module → Module
liftAsm m@(Module id layout target gvs fns nmdtys) = 
	let (f,α@Ε{..}) = runState (liftList [] $ M.toList fns) $ εΕ m
	    fns' = asmfn ∪ M.fromList f
	in Module id layout target gvs fns' nmdtys

class Assembly α where
	lift ∷ α → ΕState α

liftList ∷ Assembly α ⇒ [α] → [α] → ΕState [α]
liftList = foldM liftElem

liftElem ∷ Assembly α ⇒ [α] → α → ΕState [α]
liftElem β α = do α' ← lift α
                  (↣) $ α':β

instance Assembly (Identifier,Function) where
	lift (i,fn) = case fn of
		FunctionDecl name linkage retty isVar params     → (↣) (i,fn)
		FunctionDef  name linkage retty isVar params bbs → do
			νfn (i,0)
			bbs' ← mapM lift bbs
			let fn' = FunctionDef name linkage retty isVar params bbs'
			(↣) (i,fn')

instance Assembly BasicBlock where
	lift bb = case bb of
		BasicBlock label phis instrs tmn → do
			instrs' ← mapM lift instrs
			(↣) $ BasicBlock label phis instrs' tmn

instance Assembly Instruction where
	lift i = case i of
		InlineAsm pc α τ _ _ _ asm constr args → do
			fname ← freshName		    
			let fn = buildFn fname τ asm args
			νasmfn (fname,fn)
			(↣) $ Call pc α τ fname args
		_ → (↣) i

-------------------------------------------------------------------------------
data Γ = Γ {
	  vars    ∷ M.Map Id Value
	, lastVar ∷ Maybe Value
	, counter ∷ Int -- Num of bbs
	, locals  ∷ S.Set Id
	, params  ∷ Parameters
	, args    ∷ Values
}

εΓ ∷ Parameters → Values → Γ
εΓ p v = let ip = S.fromList $ map (\(Parameter i _ ) → i) p
         in Γ ε Nothing 0 ip p v

freshLocal ∷ State Γ Id
freshLocal = do 
	γ@Γ{..} ← get
	let tmp = Local $ "tmp" ⧺ (show $ S.size locals)
	    locals' = tmp ∘ locals
	put γ{locals = locals'}
	(↣) tmp

buildFn ∷ Id → Type → AS.Asm → Values → Function
buildFn n τ asm vals = 
	let params = buildParams vals
	    bbs = evalState (buildBody asm) $ εΓ params vals
	in FunctionDef n PrivateLinkage τ False params bbs

buildParams ∷ Values → Parameters
buildParams v = map buildParam $ zip v [0..]

buildParam ∷ (Value,Int) → Parameter
buildParam (v,i) = Parameter (Local $ show i) $ typeOf v

buildBody ∷ AS.Asm → State Γ BasicBlocks
buildBody (_,sections) = mapM (buildBB . snd) sections

buildBB ∷ [AS.GAS] → State Γ BasicBlock
buildBB instr = do
	bbname ← buildBBName
	instrs ← foldM buildInstruction [] instr
	tmn ← buildTerminator
	(↣) $ BasicBlock bbname [] instrs tmn

buildBBName ∷ State Γ Id
buildBBName = do 
    γ@Γ{..} ← get
    let name = Local $ "bb" ⧺ show counter
        c = counter + 1
    put γ{counter=c}
    (↣) name

buildTerminator ∷ State Γ Terminator
buildTerminator = do 
	γ@Γ{..} ← get
	case lastVar of
		Nothing → (↣) $ Ret 0 VoidRet
		Just α  → (↣) $ Ret 0 $ ValueRet α
  
buildInstruction ∷ Instructions → AS.GAS → State Γ Instructions
buildInstruction is i = case i of
	AS.Add τ' α β → do
		let τ = τGas2τ τ'
		αv ← buildValue τ α
		βv ← buildValue τ β
		βi ← ssaValue βv
		γ@Γ{..} ← get
		put γ{lastVar = Just βi}
		let ι = Add 0 (valueIdentifier' "" βi) τ αv βv
		(↣) $ ι:is
	AS.Mov τ' α β → do
		let τ = τGas2τ τ'
		αv ← buildValue τ α
		βv ← buildValue τ β
		γ@Γ{..} ← get
		let βi = valueIdentifier' "" βv
		    vars' = M.insert βi αv vars
		put γ{vars=vars', lastVar = Just αv}
		(↣) is
	AS.Cmpxchg τ α β → do
		ι ← buildCmpxchg (τGas2τ τ) α β 
		(↣) $ ι:is
	_ → (↣) is

buildCmpxchg ∷ Type → AS.Operand → AS.Operand → State Γ Instruction
buildCmpxchg τ n (AS.Reg ptr) = do
	γ@Γ{..} ← get
	let ptrpos = read ptr ∷ Int
	    τptr = TyPointer τ
	    Parameter i t = params !! (ptrpos - 1)
	    ptrv = case M.lookup i vars of
        	Nothing → IR.Id i τ
        	Just v  → v
	if τptr /= t
	then error "buildCmpxchg: pointer location failed"
	else case n of
		AS.Lit nval → do
			let nv = Constant $ SmpConst $ ConstantInt nval τ
			    Parameter oi ot = params !! ptrpos
			    ov = case M.lookup oi vars of
			    	Nothing → IR.Id oi ot
			    	Just v'  → v'
			j ← freshLocal
			let βj = IR.Id j τ
			γ@Γ{..} ← get
			put γ{lastVar = Just βj}
			(↣) $ Cmpxchg 0 j ptrv nv ov Monotonic
		AS.Reg nreg → do
			let Parameter ni nt = params !! ptrpos
			    nv = case M.lookup ni vars of
			    	Nothing → IR.Id ni nt
			    	Just nv' → nv'
			    Parameter oi ot = params !! (ptrpos + 1)
			    ov = case M.lookup oi vars of
			    	Nothing → IR.Id oi ot
			    	Just ov' → ov'
			j ← freshLocal
			let βj = IR.Id j τ
			γ@Γ{..} ← get
			put γ{lastVar = Just βj}
			(↣) $ Cmpxchg 0 j ptrv nv ov Monotonic
buildCmpxchg τ n _ = error "buildCmpxchg"
  
{-
cmpxchg(ptr,old,new) 
__cmpxchg(ptr,old,new,sizeof(*(ptr)))
__raw_cmpxchg((ptr), (old), (new), (size), LOCK_PREFIX)

%293 = call i32 asm sideeffect "lock; cmpxchgl $2,$1", "={ax},=*m,r,0,*m,~{memory},~{dirflag},~{fpsr},~{flags}"
(i32* %287, i32 %292, i32 %c.0.i.i.i, i32* %287) #4, !dbg !11571, !srcloc !11573
-}
buildValue ∷ Type → AS.Operand → State Γ Value
buildValue τ (AS.Lit n) = (↣) $ Constant $ SmpConst $ ConstantInt n τ
buildValue τ (AS.Reg "0") = (↣) $ IR.Id (Local "0") τ
buildValue τ (AS.Reg s) = do γ@Γ{..} ← get
                             let ns = read s ∷ Int
                                 Parameter i t = params !! (ns - 1)
                             case M.lookup i vars of
                             	Nothing → (↣) $ IR.Id i τ
                             	Just v  → (↣) v
buildValue τ (AS.CReg s) = error "buildValue: does not support clobber registers"

ssaValue ∷ Value → State Γ Value
ssaValue (IR.Id i τ)  = do j ← freshLocal
                           γ@Γ{..} ← get
                           let v = IR.Id j τ
                               vars' = M.insert i v vars
                           put γ{vars=vars'}
                           (↣) v 
ssaValue (Constant c) = do i ← freshLocal
                           (↣) $ IR.Id i (typeOf c)

τGas2τ ∷ AS.TyGas → Type
τGas2τ (AS.I n) = TyInt n
τGas2τ (AS.Fp n) = TyFloatPoint $ fpτGas2τ n

fpτGas2τ ∷ Int → TyFloatPoint
fpτGas2τ 16  = TyHalf
fpτGas2τ 32  = TyFloat
fpτGas2τ 64  = TyDouble
fpτGas2τ 128 = TyFP128
fpτGas2τ 80  = Tyx86FP80
fpτGas2τ _   = error "fpτGas2τ" 