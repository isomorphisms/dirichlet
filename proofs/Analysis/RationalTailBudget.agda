{-# OPTIONS --safe --without-K #-}
module Analysis.RationalTailBudget where

-- Exact finite-tail bounds in ℚ.  This module does not postulate
-- completeness, an infinite sum, or a limit.
--
-- A proposed error budget B(n) must be checked at every index:
--     w(n) + B(n+1) ≤ B(n).
-- The theorem then proves, by induction, that the *actual finite tail*
-- from n across any count of terms is bounded by the decrease in budget.
-- If every B(n) is nonnegative, the tail itself is ≤ B(n).
--
-- This interface allows the next stage to plug in a concrete bound for
-- w(n)=1/(n+1)^2 rather than assuming the convergence it needs to prove.

open import Data.Nat.Base using (ℕ; zero; suc)
import Data.Rational.Base as ℚ
import Data.Rational.Properties as ℚP
open ℚ using (ℚ; 0ℚ; _+_; _≤_)

-- Keep endpoint arithmetic structural: no addition reassociation needed.
end-index : ℕ → ℕ → ℕ
end-index from zero = from
end-index from (suc count) = end-index (suc from) count

finite-tail : (weight : ℕ → ℚ) → ℕ → ℕ → ℚ
finite-tail weight from zero = 0ℚ
finite-tail weight from (suc count) =
  weight from + finite-tail weight (suc from) count

-- The decrease of B is a genuine local proof obligation.
-- It is NOT an unchecked estimate constructed inside this theorem.
budget-step : (weight budget : ℕ → ℚ) → Set
budget-step weight budget =
  (index : ℕ) → weight index + budget (suc index) ≤ budget index

-- Proof by induction on the exact length of a finite tail.
finite-tail-plus-remainder
  : (weight budget : ℕ → ℚ)
  → budget-step weight budget
  → (from count : ℕ)
  → finite-tail weight from count + budget (end-index from count)
    ≤ budget from
finite-tail-plus-remainder weight budget step from zero =
  ℚP.≤-reflexive (ℚP.+-identityˡ (budget from))
finite-tail-plus-remainder weight budget step from (suc count) =
  ℚP.≤-trans
    (ℚP.≤-reflexive
      (ℚP.sym
        (ℚP.+-assoc (weight from)
          (finite-tail weight (suc from) count)
          (budget (end-index (suc from) count)))))
    (ℚP.≤-trans
      (ℚP.+-monoʳ-≤ (weight from)
        (finite-tail-plus-remainder weight budget step
          (suc from) count))
      (step from))

-- Under a nonnegative error budget, all finite tails are bounded
-- uniformly in their lengths by the budget at their start index.
finite-tail-bounded
  : (weight budget : ℕ → ℚ)
  → budget-step weight budget
  → ((index : ℕ) → 0ℚ ≤ budget index)
  → (from count : ℕ)
  → finite-tail weight from count ≤ budget from
finite-tail-bounded weight budget step nonnegative from count =
  ℚP.≤-trans
    (ℚP.≤-reflexive
      (ℚP.sym (ℚP.+-identityʳ (finite-tail weight from count))))
    (ℚP.≤-trans
      (ℚP.+-monoʳ-≤ (finite-tail weight from count)
         (nonnegative (end-index from count)))
      (finite-tail-plus-remainder weight budget step from count))
