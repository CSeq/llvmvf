{-# LANGUAGE UnicodeSyntax, FlexibleInstances #-}
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

import Analysis.Type.Inference.Value
import Control.Monad.State
import Analysis.Type.Util

import Prelude.Unicode ((⧺),(≡))
import Data.List.Unicode ((∈))

import qualified Data.Set as S
import qualified Data.Map as M
import qualified Debug.Trace as Trace

trace s f = f

type Ω = M.Map Id ℂ

εΩ = M.empty

collapse ∷ S.Set Τℂ → Ω
collapse = S.fold rewrite εΩ

rewrite ∷ Τℂ → Ω → Ω
rewrite τℂ γ = case τℂ of
  c1 :=: c2 → snd $ rewriteEq γ c1 c2 
  c1 :<: c2 → undefined
  c1 :≤: c2 → undefined
  c1 :≌: c2 → undefined

-- rewriteEq
rewriteEq ∷ Ω → ℂ → ℂ → (ℂ,Ω)
rewriteEq γ α β = trace "rewriteEq " $ 
  case α of
    ℂτ τ     → rwEqτ γ α β -- type
    ℂc cl    → rwEqc γ α β -- class
    ℂι c i   → undefined --rwEqι γ α β -- gep
    ℂp c τα  → rwEqp γ α β -- pointer
    ℂλ ca cr → rwEqλ γ α β -- function
    ℂπ n     → rwEqπ γ α β -- var

-- Type
rwEqτ ∷ Ω → ℂ → ℂ → (ℂ,Ω)
rwEqτ γ α@(ℂτ τ1) β = trace "rwEqτ" $ 
  case β of
    ℂτ τ2 → case τ1 ≅ τ2 of
              Nothing → error $ "rwEqτ (1)"
              Just c  → (ℂτ c,γ)
    ℂc cl → if τ1 `classOf` cl 
            then (α,γ)
            else error $ "rwEqτ (2)"
    _ → rewriteEq γ β α                       
rwEqτ γ _ _ = error $ "rwEqτ: FATAL"

-- Type Class
rwEqc ∷ Ω → ℂ → ℂ → (ℂ,Ω)
rwEqc γ α@(ℂc cl1) β = trace "rwEqc" $ 
  case β of 
    ℂc cl2 → if cl1 ≡ cl2
             then (α,γ)
             else error $ "rwEqc (1)"
    _ → rewriteEq γ β α
rwEqc γ _ _ = error $ "rwEqc: FATAL"

-- Type Var
rwEqπ ∷ Ω → ℂ → ℂ → (ℂ,Ω)
rwEqπ γ α@(ℂπ n) β = trace "rwEqπ" $ 
  case M.lookup n γ of
    Nothing → (β, M.insert n β γ)
    Just ζ  → case ζ of
      ℂπ m → if n ≡ m
             then (β, M.insert n β γ)
             else case β of
                ℂπ o → if n ≡ o || o ≡ m
                       then (β, γ)
                       else (β, M.insert m β γ)
                _ → (β,M.insert n β γ)
      _    → let (c,γ') = rewriteEq γ β ζ
             in (c,M.insert n c γ')
rwEqπ γ _ _ = error $ "rwEqπ: FATAL"


-- Type Function
rwEqλ ∷ Ω → ℂ → ℂ → (ℂ,Ω)
rwEqλ γ α@(ℂλ ca1 cr1) β = trace "rwEqλ" $ 
  case β of 
    ℂλ ca2 cr2 → 
      let (ca,γ') = foldr fλ ([],γ) $ zip ca1 ca2
          fλ (a1,a2) (lca, g) = 
            let (c,g') = rewriteEq g a1 a2
            in (c:lca,g')
          (cr,γ'') = rewriteEq γ' cr1 cr2
      in (ℂλ ca cr,γ'')
    ℂc c → undefined  
    _    → rewriteEq γ β α
rwEqλ γ _ _ = error $ "rwEqλ: FATAL"

{-
-- Type gep
rwEqι ∷ Ω → ℂ → ℂ → (ℂ,Ω)
rwEqι γ (ℂι c1 i1) (ℂι c2 i2)
rwEqι γ (ℂι c1 i1) (ℂc c)
rwEqι γ (ℂι c1 i1) (ℂλ ca cr) = error "rewriteEq: cant constraint gep with function"
rwEqι γ (ℂι c1 i1) (ℂp c ταρ) = error "rewriteEq: cant constraint gep with pointer"
rwEqι γ (ℂι c1 i1) c = rewriteEq γ c (ℂι c1 i1) 
-}

-- Type pointer
-- Missing ℂc
rwEqp ∷ Ω → ℂ → ℂ → (ℂ,Ω)
rwEqp γ α@(ℂp c1 τα1) β = trace "rwEqp" $ 
  case β of
    ℂτ τ → case τ of
      TyDer (TyPtr τ1 τα2) → 
        let (c,γ') = rewriteEq γ c1 (ℂτ τ1)
        in case τα1 ≅ τα2 of
         Just τα → (α,γ')
         Nothing → error $ "rwEqp error: " ⧺ show α ⧺ " " ⧺ show β
      _ → error "rwEqp: types dont match"
    ℂp c2 τα2 → 
      let (c,γ') = rewriteEq γ c1 c2
      in case τα1 ≅ τα2 of
         Just τα → (α,γ')
         Nothing → error $ "rwEqp error: " ⧺ show α ⧺ " " ⧺ show β
    ℂλ ca cr → error "rewriteEq: cant constraint pointer with function" 
    _ → rewriteEq γ β α
rwEqp γ _ _ = error $ "rwEqp: FATAL"

------------------------------------------

type Γ = M.Map Id Τα

(⊨) ∷ S.Set Τℂ → Γ
(⊨) τℂ = let γ = trace "collapse" $ collapse τℂ 
         in trace "solve" $ M.mapWithKey (\n c → solve γ [n] c) γ

-- Solve 
-- Input : Env, Constraints left
solve ∷ Ω → [Id] → ℂ → Τα
solve γ n τℂ = case τℂ of
  ℂτ τ → τ
  ℂπ m → look γ n m
  ℂc cl → error "solve does not expect a class"
  ℂι c i → undefined
  ℂp c a → let cτ = solve γ n c 
           in TyDer $ TyPtr cτ a  
  ℂλ ca cr → let caτ = map (solve γ n) ca
                 crτ = solve γ n cr
             in TyDer $ TyFun caτ crτ False

look ∷ Ω → [Id] → Id → Τα 
look γ l m | m ∈ l = error "look: same identifiers"
           | otherwise = case M.lookup m γ of
                Nothing → error "look: not in map" 
                Just c  → solve γ (m:l) c
{-
data ℂ = ℂτ Τα -- Type α
       | ℂπ Id -- Type of Id
       | ℂc ΤClass -- Class of
       | ℂι ℂ Int  -- for GEP instruction
       | ℂp ℂ Ταρ  -- Pointer to ℂ Τα
       | ℂλ [ℂ] ℂ  -- Function
-}