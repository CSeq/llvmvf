{-# LANGUAGE UnicodeSyntax, FlexibleInstances, RecordWildCards, DoAndIfThenElse #-}
-------------------------------------------------------------------------------
-- Module    :  Analysis.Type.Inference.Solver
-- Copyright :  (c) 2013 Marcelo Sousa
-- Worklist algorithm
-- Type equality must consider recursive types
-- That is going to complicate a bit more.

-------------------------------------------------------------------------------

module Analysis.Type.Inference.Solver where

import Language.LLVMIR hiding (Id)
import Analysis.Type.Inference.Base
import Analysis.Type.Memory.Util
import Analysis.Type.Memory.TyAnn as T
import Language.LLVMIR.Util
import Analysis.Type.Inference.Value
import Control.Monad.State
import Analysis.Type.Util

import Prelude.Unicode ((⧺),(≡))
import Data.List.Unicode ((∈))

import qualified Data.Set as S
import qualified Data.Map as M

import Control.Monad
import Control.Monad.State

import qualified Debug.Trace as Trace

trace s f = f
--trace = Trace.trace

data Ω = Ω 
  { 
    rc  ∷ S.Set Τℂ  -- remaining constraints
  , mic ∷ M.Map Id ℂ -- current map
  }

instance Eq Ω where
  (Ω rc1 mic1) == (Ω rc2 mic2) = rc1 ≡ rc2 && mic1 ≡ mic2 

νΤℂ ∷ Τℂ → ΩState ()
νΤℂ τℂ = do γ@Ω{..} ← get
            let rc' = τℂ ∘ rc
            put γ{rc=rc'}

νIℂ ∷ Id → ℂ → ΩState ()
νIℂ i c = do γ@Ω{..} ← get
             let mic' = M.insert i c mic
             put γ{mic=mic'}

type ΩState α = State Ω α

εΩ = Ω ε M.empty

iΩ c = Ω c M.empty 

μrewriteEq ∷ ΩState ()
μrewriteEq = trace ("fixRewriteEq -----") $ do
  γ ← get
  let τℂs = S.toList $ rc γ
  put γ{rc = ε}
  mapM_ rewriteEq τℂs 
  γ' ← get
  if γ ≡ γ'
  then (↣) ()
  else μrewriteEq

rewriteEq ∷ Τℂ → ΩState ()
rewriteEq τℂ =
  case τℂ of
    c1 :=: c2 → do 
      rwEq c1 c2
      (↣) ()
    _  → νΤℂ τℂ

-- rwEq
rwEq ∷ ℂ → ℂ → ΩState ℂ
rwEq α β = trace ("rwEq " ⧺ show α ⧺ " " ⧺ show β) $ 
  case α of
    ℂτ τ     → rwEqτ α β -- type
    ℂc cl    → rwEqc α β -- class
    ℂι c i   → rwEqι α β -- gep
    ℂp c τα  → rwEqp α β -- pointer
    ℂλ ca cr → rwEqλ α β -- function
    ℂπ n     → rwEqπ α β -- var

-- Type
rwEqτ ∷ ℂ → ℂ → ΩState ℂ
rwEqτ α@(ℂτ τ1) β = 
  case β of
    ℂτ τ2 → case τ1 ≅ τ2 of
              Nothing → error $ "rwEqτ (1) " ⧺ show α ⧺ " " ⧺ show β
              Just c  → (↣) $ ℂτ c
    ℂc cl → if τ1 `classOf` cl 
            then (↣) α
            else error $ "rwEqτ (2)"
    _ → rwEq β α                       
rwEqτ _ _ = error $ "rwEqτ: FATAL"

-- Type Class
rwEqc ∷ ℂ → ℂ → ΩState ℂ
rwEqc α@(ℂc cl1) β = 
  case β of 
    ℂc cl2 → case cl1 ≅ cl2 of
              Nothing → error $ "rwEqc (1) " ⧺ show α ⧺ " " ⧺ show β
              Just cl → (↣) $ ℂc cl
    _ → rwEq β α
rwEqc _ _ = error $ "rwEqc: FATAL"

-- Type Var
rwEqπ ∷ ℂ → ℂ → ΩState ℂ
rwEqπ α@(ℂπ n) β = do
  γ@Ω{..} ← get
  case M.lookup n mic of
    Nothing → do
      νIℂ n β
      (↣) β
    Just ζ  → case ζ of
      ℂπ m → if n ≡ m
             then do νIℂ n β
                     (↣) β
             else case β of
                ℂπ o → if n ≡ o || o ≡ m
                       then (↣) β
                       else do νIℂ m β
                               (↣) β
                _ → do νIℂ n β
                       (↣) β
      _    → do c ← rwEq β ζ
                νIℂ n c
                (↣) c
rwEqπ _ _ = error $ "rwEqπ: FATAL"

-- Type Function
rwEqλ ∷ ℂ → ℂ → ΩState ℂ
rwEqλ α@(ℂλ ca1 cr1) β =
  case β of 
    ℂλ ca2 cr2 → do
      ca ← mapM (uncurry rwEq) $ zip ca1 ca2
      cr ← rwEq cr1 cr2
      (↣) $ ℂλ ca cr
    ℂc c → error $ "rwEqλ: class constraint"
    _    → rwEq β α
rwEqλ _ _ = error $ "rwEqλ: FATAL"

-- Type gep
rwEqι ∷ ℂ → ℂ → ΩState ℂ
rwEqι α@(ℂι cin idxn) β =
  case β of
    ℂτ τ → error "rqEqgep type"
    ℂπ n → error "rqEqgep pi"
    ℂc c → error "rqEqgep class"
    ℂι c2 i2 → error "rqEqgep gep"
    ℂp c ταρ → error "rqEqgep pointer"
    ℂλ ca cr → error "rqEqgep function"

-- Type pointer
-- Missing ℂc
rwEqp ∷ ℂ → ℂ → ΩState ℂ
rwEqp α@(ℂp c1 τα1) β =
  case β of
    ℂτ τ → case τ of
      TyDer (TyPtr τ1 τα2) → 
        case τα1 ≅ τα2 of
          Just τα → do c ← rwEq c1 (ℂτ τ1)
                       case c of
                        ℂτ τ' → (↣) $ ℂτ $ TyDer $ TyPtr τ' τα
                        _     → error $ "rwEqp error: impossible case? " ⧺ show c
          Nothing → error $ "rwEqp error: " ⧺ show α ⧺ " " ⧺ show β
      _ → error $ "rwEqp: types dont match " ⧺ show α ⧺ " " ⧺ show β
    ℂp c2 τα2 → 
      case τα1 ≅ τα2 of
        Just τα → do c ← rwEq c1 c2
                     (↣) $ ℂp c τα
        Nothing → error $ "rwEqp error: " ⧺ show α ⧺ " " ⧺ show β
    ℂλ ca cr → error "rwEqp: cant constraint pointer with function" 
    _ → rwEq β α
rwEqp _ _ = error $ "rwEqp: FATAL"

------------------------------------------

type Γ = M.Map Id Τα

(⊨) ∷ S.Set Τℂ → Γ
(⊨) τℂ = let γ@Ω{..} = trace "rewriteEq" $ execState μrewriteEq (iΩ τℂ)
             γ' = trace "solveEq" $ M.mapWithKey (\n c → solveEq mic [n] c) mic
         in S.fold solveCast γ' rc

-- Solve 
-- Input : Env, Constraints left
solveEq ∷ M.Map Id ℂ → [Id] → ℂ → Τα
solveEq γ n τℂ = case τℂ of
  ℂτ τ → τ
  ℂπ m → look γ n m
  ℂc cl → error "solve does not expect a class"
  ℂι c i → error "solve does not expect a gep"
  ℂp c a → let cτ = solveEq γ n c 
           in TyDer $ TyPtr cτ a  
  ℂλ ca cr → let caτ = map (solveEq γ n) ca
                 crτ = solveEq γ n cr
             in TyDer $ TyFun caτ crτ False

look ∷ M.Map Id ℂ → [Id] → Id → Τα 
look γ l m | m ∈ l = error "look: same identifiers"
           | otherwise = case M.lookup m γ of
                Nothing → error "look: not in map" 
                Just c  → solveEq γ (m:l) c

solveCast ∷ Τℂ → Γ → Γ
solveCast τℂ γ = case τℂ of
  c1 :=: c2 → error "solveCast :=: impossible"
  c1 :<: c2 → error "solveCast :<: constraint"
  c1 :≤: c2 → error "solveCast :<=: constraint"
  c1 :≌: c2 → solveBitEq γ c1 c2

solveBitEq ∷ Γ → ℂ → ℂ → Γ
solveBitEq γ α@(ℂπ n) β =
  let ατ = safeLookup n γ
  in case β of
    ℂτ βτ → if sizeOf ατ ≡ sizeOf βτ
            then γ
            else error $ "solveBitEq: bitsize mismatch " ⧺ show α ⧺ " " ⧺ show β
    ℂπ m  → undefined
    _ → error "solveBitEq: beta is not supported"
solveBitEq γ α β = error "solveBitEq: fst arg is not Cpi" 

safeLookup ∷ Id → Γ → Τα
safeLookup n γ = 
  case M.lookup n γ of
    Nothing → error $ "safeLookup failed with id=" ⧺ show n
    Just τ  → τ 

instance AEq TClass where
  TInt ≅ T1NA = Just TInt
  TInt ≅ T1   = Just TInt
  TInt ≅ _    = Nothing
  TFlt ≅ T1NA = Just TFlt 
  TFlt ≅ T1   = Just TFlt
  TFlt ≅ _    = Nothing
  TPtr ≅ T1NA = Just TPtr 
  TPtr ≅ T1   = Just TPtr
  TPtr ≅ _    = Nothing
  T1NA ≅ TAgg = Nothing
  T1NA ≅ β    = β ≅ T1NA
  TAgg ≅ β    = β ≅ TAgg
  T1   ≅ β    = Just β   
