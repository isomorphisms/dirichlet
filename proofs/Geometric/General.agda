{-# OPTIONS --safe --without-K #-}
module Geometric.General where

-- An independent generalization of Finite.agda.
-- All ring laws come from the supplied CommutativeRing structure; this
-- module contains no postulates, holes, reflection, or numeric testing.

open import Algebra.Bundles using (CommutativeRing)
open import Data.Nat.Base using (ℕ; zero; suc)

module OverCommutativeRing {c ℓ} (R : CommutativeRing c ℓ) where

  open CommutativeRing R
  open import Relation.Binary.Reasoning.Setoid setoid
  open import Algebra.Properties.Ring ring using (-‿distribˡ-*)

  infixl 6 _-_
  _-_ : Carrier → Carrier → Carrier
  left - right = left + (- right)

  power : Carrier → ℕ → Carrier
  power ratio zero = 1#
  power ratio (suc count) = ratio * power ratio count

  geometric : Carrier → ℕ → Carrier
  geometric ratio zero = 0#
  geometric ratio (suc count) =
    geometric ratio count + power ratio count

  -- (1-q)*t = t - q*t, obtained from distributivity, unit and
  -- compatibility of additive inverses with multiplication.
  multiply-difference
    : (ratio term : Carrier)
    → ((1# - ratio) * term) ≈ (term - ratio * term)
  multiply-difference ratio term = begin
    (1# - ratio) * term
      ≈⟨ distribʳ term 1# (- ratio) ⟩
    (1# * term) + ((- ratio) * term)
      ≈⟨ +-cong (*-identityˡ term)
           (sym (-‿distribˡ-* ratio term)) ⟩
    term + (- (ratio * term))
      ∎

  -- (1-p) + (1-q)*p = 1-q*p.
  cancellation-step
    : (ratio term : Carrier)
    → (1# - term) + ((1# - ratio) * term)
      ≈ (1# - ratio * term)
  cancellation-step ratio term = begin
    (1# - term) + ((1# - ratio) * term)
      ≈⟨ +-congˡ (multiply-difference ratio term) ⟩
    (1# + (- term)) + (term + (- (ratio * term)))
      ≈⟨ +-assoc 1# (- term) (term + (- (ratio * term))) ⟩
    1# + ((- term) + (term + (- (ratio * term))))
      ≈⟨ +-congˡ (sym (+-assoc (- term) term (- (ratio * term)))) ⟩
    1# + (((- term) + term) + (- (ratio * term)))
      ≈⟨ +-congˡ (+-congʳ (+-inverseˡ term)) ⟩
    1# + (0# + (- (ratio * term)))
      ≈⟨ +-congˡ (+-identityˡ (- (ratio * term))) ⟩
    1# + (- (ratio * term))
      ∎

  -- Genuine induction. No division and no condition q ≉ 1#.
  finite-geometric
    : (ratio : Carrier) (count : ℕ)
    → ((1# - ratio) * geometric ratio count)
      ≈ (1# - power ratio count)
  finite-geometric ratio zero = begin
    (1# - ratio) * geometric ratio zero
      ≈⟨ refl ⟩
    (1# - ratio) * 0#
      ≈⟨ zeroʳ (1# - ratio) ⟩
    0#
      ≈⟨ sym (+-inverseʳ 1#) ⟩
    1# - 1#
      ≈⟨ refl ⟩
    1# - power ratio zero
      ∎
  finite-geometric ratio (suc count) = begin
    (1# - ratio) * geometric ratio (suc count)
      ≈⟨ refl ⟩
    (1# - ratio) * (geometric ratio count + power ratio count)
      ≈⟨ distribˡ (1# - ratio) (geometric ratio count)
           (power ratio count) ⟩
    ((1# - ratio) * geometric ratio count)
      + ((1# - ratio) * power ratio count)
      ≈⟨ +-congʳ (finite-geometric ratio count) ⟩
    (1# - power ratio count)
      + ((1# - ratio) * power ratio count)
      ≈⟨ cancellation-step ratio (power ratio count) ⟩
    1# - ratio * power ratio count
      ≈⟨ refl ⟩
    1# - power ratio (suc count)
      ∎
