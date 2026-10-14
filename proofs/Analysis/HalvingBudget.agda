{-# OPTIONS --safe --without-K #-}
module Analysis.HalvingBudget where

-- Concrete exact-rational example of a decaying geometric error budget.
-- These are finite estimates, not a declaration that an infinite sum
-- or a real/complex limit already exists.

open import Data.Nat.Base using (ℕ; zero; suc)
import Data.Rational.Base as ℚ
import Data.Rational.Properties as ℚP
import Relation.Nullary.Decidable.Core as Dec
open import Relation.Binary.PropositionalEquality.Core
  using (_≡_; refl; sym; trans; cong)
import Analysis.RationalTailBudget as Tail

-- At every step the remaining error budget is halved.
halving-budget : ℕ → ℚ.ℚ
halving-budget zero = ℚ.1ℚ
halving-budget (suc n) = ℚ.½ ℚ.* halving-budget n

halving-weight : ℕ → ℚ.ℚ
halving-weight n = halving-budget (suc n)

half-plus-half : ℚ.½ ℚ.+ ℚ.½ ≡ ℚ.1ℚ
half-plus-half = refl

-- One exact geometric term plus its successor remainder equals the
-- current remainder, so it satisfies the local budget inequality.
halving-step
  : (index : ℕ)
  → (halving-weight index ℚ.+ halving-budget (suc index))
      ℚ.≤ halving-budget index
halving-step index =
  ℚP.≤-reflexive
    (trans
      (sym (ℚP.*-distribʳ-+ (halving-budget index) ℚ.½ ℚ.½))
      (trans
        (cong (λ ratio → ratio ℚ.* halving-budget index)
          half-plus-half)
        (ℚP.*-identityˡ (halving-budget index))))

-- The only two numerical facts used are 0 ≤ 1 and 0 ≤ 1/2,
-- established by the standard library's *decidable exact rational order*.
half-nonnegative : ℚ.NonNegative ℚ.½
half-nonnegative = ℚ.nonNegative
  (Dec.from-yes (ℚP._≤?_ ℚ.0ℚ ℚ.½))

budget-nonnegative
  : (index : ℕ) → ℚ.0ℚ ℚ.≤ halving-budget index
budget-nonnegative zero =
  Dec.from-yes (ℚP._≤?_ ℚ.0ℚ ℚ.1ℚ)
budget-nonnegative (suc index) =
  ℚP.≤-trans
    (ℚP.≤-reflexive (sym (ℚP.*-zeroʳ ℚ.½)))
    (ℚP.*-monoˡ-≤-nonNeg ℚ.½ {{half-nonnegative}}
      (budget-nonnegative index))

-- An actual quantitative bound for EVERY finite geometric tail:
--   ∑_{k=from}^{from+count-1} 2^{-(k+1)} ≤ 2^{-from}.
-- The conceptual powers are represented by the checked recurrence,
-- not by machine floats or untrusted approximation.
halving-finite-tail-bound
  : (from count : ℕ)
  → Tail.finite-tail halving-weight from count
      ℚ.≤ halving-budget from
halving-finite-tail-bound from count =
  Tail.finite-tail-bounded halving-weight halving-budget
    halving-step budget-nonnegative from count
