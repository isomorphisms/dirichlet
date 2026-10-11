{-# OPTIONS --safe --without-K #-}
module Analysis.RationalAbsoluteTail where

-- Exact absolute-value control for finite sums of SIGNED rational terms.
--
-- For a caller-supplied rational budget B and signed coefficients w,
-- the obligation is |w(n)| + B(n+1) ≤ B(n) at every index.
-- The triangle inequality then yields
--     |sum_{j=n}^{end-1} w(j)| + B(end) ≤ B(n)
-- for EVERY finite end.  A nonnegative budget also bounds the absolute
-- tail directly.  No limit/completeness assumption is smuggled in.

open import Data.Nat.Base using (ℕ; suc; zero)
import Data.Rational.Base as ℚ
import Data.Rational.Properties as ℚP
open import Relation.Binary.PropositionalEquality.Core using (sym)
import Analysis.RationalTailBudget as Tail

rational-abs : ℚ.ℚ → ℚ.ℚ
rational-abs = ℚ.∣_∣

absolute-budget-step : (weight budget : ℕ → ℚ.ℚ) → Set
absolute-budget-step weight budget =
  (index : ℕ) →
    rational-abs (weight index) ℚ.+ budget (suc index)
      ℚ.≤ budget index

absolute-tail-plus-remainder
  : (weight budget : ℕ → ℚ.ℚ)
  → absolute-budget-step weight budget
  → (from count : ℕ)
  → (rational-abs (Tail.finite-tail weight from count)
       ℚ.+ budget (Tail.end-index from count))
      ℚ.≤ budget from
absolute-tail-plus-remainder weight budget step from zero =
  ℚP.≤-reflexive (ℚP.+-identityˡ (budget from))
absolute-tail-plus-remainder weight budget step from (suc count) =
  ℚP.≤-trans
    (ℚP.+-monoˡ-≤ (budget (Tail.end-index (suc from) count))
      (ℚP.∣p+q∣≤∣p∣+∣q∣
        (weight from) (Tail.finite-tail weight (suc from) count)))
    (ℚP.≤-trans
      (ℚP.≤-reflexive
        (ℚP.+-assoc
          (rational-abs (weight from))
          (rational-abs (Tail.finite-tail weight (suc from) count))
          (budget (Tail.end-index (suc from) count))))
      (ℚP.≤-trans
        (ℚP.+-monoʳ-≤ (rational-abs (weight from))
          (absolute-tail-plus-remainder weight budget step
            (suc from) count))
        (step from)))

absolute-tail-bounded
  : (weight budget : ℕ → ℚ.ℚ)
  → absolute-budget-step weight budget
  → ((index : ℕ) → ℚ.0ℚ ℚ.≤ budget index)
  → (from count : ℕ)
  → (rational-abs (Tail.finite-tail weight from count))
      ℚ.≤ budget from
absolute-tail-bounded weight budget step nonnegative from count =
  ℚP.≤-trans
    (ℚP.≤-reflexive
      (sym (ℚP.+-identityʳ
        (rational-abs (Tail.finite-tail weight from count)))))
    (ℚP.≤-trans
      (ℚP.+-monoʳ-≤
        (rational-abs (Tail.finite-tail weight from count))
        (nonnegative (Tail.end-index from count)))
      (absolute-tail-plus-remainder weight budget step from count))
