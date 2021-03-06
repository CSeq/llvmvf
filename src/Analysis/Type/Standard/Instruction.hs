-------------------------------------------------------------------------------
-- Module    :  Analysis.Type.Standard.Instruction
-- Copyright :  (c) 2013 Marcelo Sousa
-- A Type System for Memory Analysis of LLVM IR Modules
-- Type Inference
-------------------------------------------------------------------------------

module Analysis.Type.Standard.Instruction where

import qualified Data.Map as M
import Data.Maybe

import Language.LLVMIR

import Analysis.Type.Util
import Analysis.Type.Standard.Constant

import Debug.Trace (trace)

-- Need to pattern match on the value here.
typeCheckBranchs :: Values -> Type
typeCheckBranchs [] = error "typeCheckBranchs: Empty value list"
--typeCheckBranchs l  = TyJumpTo $ map typeCheckBranch l

typeCheckBranch :: Value -> Identifier
typeCheckBranch (Id i ty) = i -- TODO need to check if ty is a TyLabel or *(TyInt 8)
typeCheckBranch v = error $ "typeCheckBranchs: Expected identifier and given " ++ show v

-- Terminators
typeCheckTerminator :: NamedTypes -> TyEnv -> Terminator -> (TyEnv, Type)
typeCheckTerminator nmdtye tye i = case i of
	Ret pc VoidRet      -> (tye, TyVoid)
	Ret pc (ValueRet v) -> (tye, typeValue nmdtye tye v) 
	Unreachable pc      -> (tye, TyUndefined) -- Unreachable has no defined semantics 
	Br  pc v t f        -> if typeValue nmdtye tye v == TyInt 1
		                   then (tye, typeCheckBranchs [t,f])
		                   else error "typeCheckTerminator.Br: Condition type is not i1"
	UBr pc d            -> (tye, typeCheckBranchs [d])
	Switch pc ty v elems -> error "typeCheckTerminator: Switch instruction not supported."

-- Phi Instructions
typeCheckPHI :: NamedTypes -> TyEnv -> PHI -> (TyEnv, Type)
typeCheckPHI nmdtye tye i = case i of
 	PHI pc i ty vals -> let (vs,ls) = unzip vals
 	                        tyvs = map (typeValue nmdtye tye) vs
 	                        tyls = map typeCheckBranch ls
 	                        p1 = all (==ty) tyvs
 	                    in if seq tyls p1
 	                       then (insert i ty tye, ty)
 	                       else error $ "typeCheckPHI.PHI: " ++ show ty ++ " " ++ show tyvs

typeCheckInstruction :: NamedTypes -> TyEnv -> Instruction -> (TyEnv, Type)
typeCheckInstruction nmdtye tye i = case i of
  -- Standard Binary Operations
  -- Integer Operations
 	Add  pc i ty op1 op2 -> typeCheckBinInstr TyClassInt tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2) 
 	Sub  pc i ty op1 op2 -> typeCheckBinInstr TyClassInt tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2) 
 	Mul  pc i ty op1 op2 -> typeCheckBinInstr TyClassInt tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2) 
 	UDiv pc i ty op1 op2 -> typeCheckBinInstr TyClassInt tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2) 
 	SDiv pc i ty op1 op2 -> typeCheckBinInstr TyClassInt tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2) 
 	URem pc i ty op1 op2 -> typeCheckBinInstr TyClassInt tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2) 
 	SRem pc i ty op1 op2 -> typeCheckBinInstr TyClassInt tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2) 
  -- Bitwise Binary Operations
	Shl  pc i ty op1 op2 -> typeCheckBinInstr TyClassInt tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2)
	LShr pc i ty op1 op2 -> typeCheckBinInstr TyClassInt tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2)
	AShr pc i ty op1 op2 -> typeCheckBinInstr TyClassInt tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2)
	And  pc i ty op1 op2 -> typeCheckBinInstr TyClassInt tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2)
	Or   pc i ty op1 op2 -> typeCheckBinInstr TyClassInt tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2)
	Xor  pc i ty op1 op2 -> typeCheckBinInstr TyClassInt tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2)
  -- Float Operations
 	FAdd pc i ty op1 op2 -> typeCheckBinInstr TyClassFloat tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2)
 	FSub pc i ty op1 op2 -> typeCheckBinInstr TyClassFloat tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2)
 	FMul pc i ty op1 op2 -> typeCheckBinInstr TyClassFloat tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2)
 	FDiv pc i ty op1 op2 -> typeCheckBinInstr TyClassFloat tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2)
 	FRem pc i ty op1 op2 -> typeCheckBinInstr TyClassFloat tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2)
  -- Cast Operations
	Trunc    pc i v ty -> typeCastOp nmdtye tye i v ty isInt (>)    -- Truncate integers
	ZExt     pc i v ty -> typeCastOp nmdtye tye i v ty isInt (<)    -- Zero extend integers
	SExt     pc i v ty -> typeCastOp nmdtye tye i v ty isInt (<)    -- Sign extend integers
	FPTrunc  pc i v ty -> typeCastOp nmdtye tye i v ty isFloat (>)  -- Truncate floating point
	FPExt    pc i v ty -> typeCastOp nmdtye tye i v ty isFloat (<=) -- Extend floating point
	FPToUI   pc i v ty -> fptoint    nmdtye tye i v ty              -- floating point -> UInt
	FPToSI   pc i v ty -> fptoint    nmdtye tye i v ty              -- floating point -> SInt
	UIToFP   pc i v ty -> inttofp    nmdtye tye i v ty              -- UInt -> floating point
	SIToFP   pc i v ty -> inttofp    nmdtye tye i v ty              -- SInt -> floating point
	PtrToInt pc i v ty ->                                           -- Pointer -> Integer
		let tyv = typeUnaryExpression nmdtye tye "PtrToInt" 41 v ty
	    in (insert i tyv tye, tyv)
	IntToPtr pc i v ty -> 										-- Integer -> Pointer
		let tyv = typeValue nmdtye tye v
	    in if isInt tyv && isPointer ty 
	       then (insert i ty tye, ty)
	       else error $ "IntToPtr: Either type is not pointer or not int: " ++ show [tyv, ty] 
	BitCast  pc i v ty ->                                       -- Type cast
		let tyv = typeUnaryExpression nmdtye tye "BitCast" 43 v ty
		in (insert i tyv tye, tyv)                
  -- Other Operations
 	ICmp pc i cond ty op1 op2 -> typeCheckCmp TyClassInt   tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2)
 	FCmp pc i cond ty op1 op2 -> typeCheckCmp TyClassFloat tye i ty (typeValue nmdtye tye op1) (typeValue nmdtye tye op2)
  -- Memory Operations
 	Alloca pc i ty       align   -> (insert i (TyPointer ty) tye, ty)-- Alloca should receive a size integer too  
 	Store  pc   ty v1 v2 align   -> 
 	  case typeValue nmdtye tye v2 of
 	  	TyPointer ty -> 
 	  	  let tyv2 = typeValue nmdtye tye v1
 	  	  in if ty == tyv2 && isFstClass ty
 	  	     then (tye, TyVoid)
 	  	     else error $ "typeCheckInstruction.Store: " ++ show ty 
 	  	x -> error $ "typeCheck Store: " ++ show x
	Load   pc i    v     align   -> 
	  case typeValue nmdtye tye v of
	  	TyPointer ty -> if isFstClass ty
	  		            then (insert i ty tye, ty)
	  		            else error $ "typeCheckInstruction.Load: " ++ show ty 
	  	x -> error $ "typeCheck Load: " ++ show x
 	GetElementPtr pc i ty v idxs ->
 	  let ety = typeGetElementPtrConstantExpr nmdtye tye v idxs
 	  in if ety == ty
      	 then (insert i ty tye, ty)
      	 else error $ "typeCheckInstruction.GetElementPtr: " ++ show [ety,ty]
  -- Call Operation
  	Call pc i ty callee vs -> typeCheckCall nmdtye tye i ty callee vs
  -- Selection Operations
  	Select pc i cv vt vf       -> error "select operation not supported."
  	ExtractValue pc i ty v idxs   -> 
  	  let ty = typeValue nmdtye tye v
  	  in if length idxs > 0
         then if isAgg ty
              then let t = getTypeAgg nmdtye ty idxs
                   in (insert i t tye, t)
              else error $ "ExtractValue: " ++ show ty ++ " is not aggregate."  
         else error $ "ExtractValue: empty list" 
  	InsertValue pc i v vi idxs -> error "InsertValue operation not supported"
  -- Atomic Operations
  	Cmpxchg   pc i mptr cval nval ord -> 
  		case typeValue nmdtye tye mptr of
  			TyPointer ty -> let cty = typeValue nmdtye tye cval
  			                    nty = typeValue nmdtye tye nval
                            in if ty == cty && cty == nty
                               then (insert i ty tye, ty)
                               else error $ "Cmpxchg: Types are not equal " ++ show [ty,cty,nty]
  			x -> error $ "Cmpxchg: Type of first element is not pointer: " ++ show x
  	AtomicRMW pc i mptr val op ord -> 
  		case typeValue nmdtye tye mptr of
  			TyPointer ty -> let vty = typeValue nmdtye tye val
                            in if ty == vty 
                               then (insert i ty tye, ty)
                               else error $ "AtomicRMW: Types are not equal " ++ show [ty,vty]
  			x -> error $ "AtomicRMW: Type of first element is not pointer: " ++ show x


typeCastOp :: NamedTypes -> TyEnv -> Identifier -> Value -> Type -> (Type -> Bool) -> (Type -> Type -> Bool) -> (TyEnv, Type)
typeCastOp nmdtye tye i v ty top op = 
	let tyv = typeValue nmdtye tye v
	in if top tyv && top ty
	   then if op tyv ty
		    then (insert i ty tye, ty)
		  	else error $ "typeCastOpInt: op failed " ++ show [tyv,ty]
		else error $ "typeCastOpInt: not int " ++ show [tyv,ty]

fptoint :: NamedTypes -> TyEnv -> Identifier -> Value -> Type -> (TyEnv, Type)
fptoint nmdtye tye i v ty = 
	let tyv = typeValue nmdtye tye v
	in case tyv of
		TyFloatPoint fp -> if isInt ty 
			               then (insert i ty tye, ty)
			               else error $ "fptoint: Type " ++ show ty ++ " is not an int"
		TyVector n (TyFloatPoint _) -> case ty of
			TyVector m (TyInt _) -> if n == m 
									then (insert i ty tye, ty)
									else error $ "fptoint: vector sizes dont match"
			x -> error $ "fptoint: " ++ show x ++ " is not a vector of ints"
		x -> error $ "fptoint: Type " ++ show x ++ " is not a float or vector of floats"

inttofp :: NamedTypes -> TyEnv -> Identifier -> Value -> Type -> (TyEnv, Type)
inttofp nmdtye tye i v ty = 
	let tyv = typeValue nmdtye tye v
	in case tyv of
		TyInt _ -> if isFloat ty 
			       then (insert i ty tye, ty)
			       else error $ "inttofp: Type " ++ show ty ++ " is not a float"
		TyVector n (TyInt _) -> case ty of
			TyVector m (TyFloatPoint _) -> if n == m 
									then (insert i ty tye, ty)
									else error $ "inttofp: vector sizes dont match"
			x -> error $ "inttofp: " ++ show x ++ " is not a vector of floats"
		x -> error $ "inttofp: Type " ++ show x ++ " is not an int or vector of ints"

typeCheckCall :: NamedTypes -> TyEnv -> Identifier -> Type -> Identifier -> Values -> (TyEnv, Type)
typeCheckCall nmdtye tye i rfnty c args = 
	let ty = getFnType tye c 
	in case ty of
			TyPointer (TyFunction typms tyr iv) ->
			  let tyargs = map (typeValue nmdtye tye) args
			  in if tyr == rfnty
			  	 then if all (\(a,b) -> a == b) $ zip tyargs typms
				 	  then if iv || length tyargs == length typms
					       then if i == Local "" 
					       	    then (tye, ty)
					       	    else (insert i tyr tye, ty)
					       else error $ "typeCheckCall: length mismatch in " ++ show c
					  else error $ "typeCheckCall: argument type mismatch " ++ show (zip tyargs typms)
				 else error $ "typeCheckCall: return type are different in " ++ show c ++ "\n" ++ show [tyr, ty]
			x -> error $ "typeCheckCall: Function has type: " ++ show x

getFnType :: TyEnv -> Identifier -> Type
getFnType tye ident@(Global i) =
	case M.lookup ident tye of
		Nothing -> case M.lookup (Local i) tye of
			Nothing -> error $ "getFnType: Function " ++ show ident ++ " not in env: " ++ show tye
			Just t  -> t
		Just t -> t
getFnType tye  (Local i) = error "getFnType: Local Identifier"

typeCheckBinInstr :: TyClass -> TyEnv -> Identifier -> Type -> Type -> Type -> (TyEnv, Type)
typeCheckBinInstr TyClassInt   tye i ty@(TyInt x)        tv1 tv2 = (insert i ty tye, f ty tv1 tv2)
typeCheckBinInstr TyClassFloat tye i ty@(TyFloatPoint x) tv1 tv2 = (insert i ty tye, f ty tv1 tv2)
typeCheckBinInstr n _ _ _ _ _ = error "typeCheckBinInstr"
f t1 t2 t3 = if t1 == t2 && t2 == t3 
		     then t1
		     else error $ "typeCheckBinInstr: " ++ show [t1,t2,t3]
		     
typeCheckCmp :: TyClass -> TyEnv -> Identifier -> Type -> Type -> Type -> (TyEnv, Type)
typeCheckCmp TyClassInt tye i ty@(TyInt 1) tv1 tv2 =
    let ntye = insert i ty tye 
	in if tv1 == tv2 
	   then case tv1 of
	     TyPointer _ -> (ntye, ty)
	     TyInt _     -> (ntye, ty)
	     x           -> error $ "typeCheckCmp.TyClassInt: " ++ show x
	   else error $ "typeCheckCmp.TyClassInt: " ++ show [tv1,tv2]
typeCheckCmp TyClassInt tye i ty@(TyVector s (TyInt _)) tv1 tv2 =
    let ntye = insert i ty tye 
	in if tv1 == tv2
	   then case tv1 of
	     TyVector r (TyInt _) -> if r == s 
	     	                     then (ntye, ty)
	                             else error $ "typeCheckCmp.TyClassInt(2): " ++ show [r,s]
	     x -> error $ "typeCheckCmp.TyClassInt(2): " ++ show x
	   else error $ "typeCheckCmp.TyClassInt(2): " ++ show [tv1,tv2]
typeCheckCmp TyClassFloat tye i ty@(TyInt 1) tv1 tv2 =
    let ntye = insert i ty tye 
	in if tv1 == tv2 
	   then case tv1 of
	     TyPointer _    -> (ntye, ty)
	     TyFloatPoint _ -> (ntye, ty)
	     x -> error $ "typeCheckCmp.TyClassFloat: " ++ show x
	   else error $ "typeCheckCmp.TyClassFloat: " ++ show [tv1,tv2]
typeCheckCmp TyClassFloat tye i ty@(TyVector s (TyFloatPoint _)) tv1 tv2 =
    let ntye = insert i ty tye 
	in if tv1 == tv2 
	   then case tv1 of
	     TyVector r (TyFloatPoint _) -> if r == s 
	     	                            then (ntye, ty)
	                                    else error $ "typeCheckCmp.TyClassFloat(2): " ++ show [r,s]
	     x           -> error $ "typeCheckCmp.TyClassFloat(2): " ++ show x
	   else error $ "typeCheckCmp.TyClassFloat(2): " ++ show [tv1,tv2]
