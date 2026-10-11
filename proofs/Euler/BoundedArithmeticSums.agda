{-# OPTIONS --safe --without-K #-}
module Euler.BoundedArithmeticSums where

-- Finite Euler factors equal a bounded arithmetic sum.  No prime or
-- distinctness assumption is needed for equality over exponent assignments.
-- Those additional hypotheses make the assignment-to-integer map injective
-- (Euler.PrimeExponentInjectivity), so the summands then count *different*
-- positive integers exactly once.
--
-- Both cutoff and prime basis are finite here. No infinite product,
-- convergence, analytic continuation, or unverified numeric equality.

open import Algebra.Bundles using (CommutativeRing)
open import Data.Nat.Base using (ℕ; zero; suc)
import Data.Nat.Base as Nat
open import Data.List.Base using (List; []; _∷_; map)
open import Data.Product.Base using (_,_)
open import Data.Unit.Base using (tt)
open import Euler.PrimeExponentInjectivity using (ExponentAssignment; encode)
import Euler.CoefficientAssignmentWeights
import Euler.FiniteExpansion
open import Geometric.General

module OverRing {c ℓ} (R : CommutativeRing c ℓ) where
  open CommutativeRing R hiding (zero)
  open import Relation.Binary.Reasoning.Setoid setoid
  open Geometric.General.OverCommutativeRing R using (power; geometric)
  open Euler.FiniteExpansion.OverRing R
    using (scaled-geometric; scaled-geometric-factor; finite-local-product)

  -- Ordinary finite sum, indexed by the integers 0,...,cutoff-1.
  sum-exponents : ℕ → (ℕ → Carrier) → Carrier
  sum-exponents zero f = 0#
  sum-exponents (suc cutoff) f =
    sum-exponents cutoff f + f cutoff

  sum-exponents-cong
    : (cutoff : ℕ) (f g : ℕ → Carrier)
    → ((exponent : ℕ) → f exponent ≈ g exponent)
    → sum-exponents cutoff f ≈ sum-exponents cutoff g
  sum-exponents-cong zero f g equal-terms = refl
  sum-exponents-cong (suc cutoff) f g equal-terms =
    +-cong (sum-exponents-cong cutoff f g equal-terms)
           (equal-terms cutoff)

  sum-exponents-scale
    : (cutoff : ℕ) (factor : Carrier) (f : ℕ → Carrier)
    → sum-exponents cutoff (λ exponent → factor * f exponent)
      ≈ factor * sum-exponents cutoff f
  sum-exponents-scale zero factor f =
    sym (zeroʳ factor)
  sum-exponents-scale (suc cutoff) factor f = begin
    sum-exponents (suc cutoff) (λ exponent → factor * f exponent)
      ≈⟨ refl ⟩
    sum-exponents cutoff (λ exponent → factor * f exponent)
      + factor * f cutoff
      ≈⟨ +-congʳ (sum-exponents-scale cutoff factor f) ⟩
    factor * sum-exponents cutoff f + factor * f cutoff
      ≈⟨ sym (distribˡ factor (sum-exponents cutoff f) (f cutoff)) ⟩
    factor * (sum-exponents cutoff f + f cutoff)
      ≈⟨ refl ⟩
    factor * sum-exponents (suc cutoff) f
      ∎

  -- Iterated finite sum over the Cartesian product of exponent choices.
  -- The empty basis has exactly one assignment, with weight f tt.
  sum-assignments
    : (basis : List ℕ) (cutoff : ℕ)
    → (ExponentAssignment basis → Carrier) → Carrier
  sum-assignments [] cutoff f = f tt
  sum-assignments (prime ∷ rest) cutoff f =
    sum-exponents cutoff
      (λ exponent → sum-assignments rest cutoff
        (λ tail → f (exponent , tail)))

  sum-assignments-cong
    : (basis : List ℕ) (cutoff : ℕ)
    → (f g : ExponentAssignment basis → Carrier)
    → ((assignment : ExponentAssignment basis) → f assignment ≈ g assignment)
    → sum-assignments basis cutoff f ≈ sum-assignments basis cutoff g
  sum-assignments-cong [] cutoff f g equal-terms = equal-terms tt
  sum-assignments-cong (prime ∷ rest) cutoff f g equal-terms =
    sum-exponents-cong cutoff
      (λ exponent → sum-assignments rest cutoff
        (λ tail → f (exponent , tail)))
      (λ exponent → sum-assignments rest cutoff
        (λ tail → g (exponent , tail)))
      (λ exponent → sum-assignments-cong rest cutoff
        (λ tail → f (exponent , tail))
        (λ tail → g (exponent , tail))
        (λ tail → equal-terms (exponent , tail)))

  -- Distributing a fixed coefficient through every finite exponent sum.
  sum-assignments-scale
    : (basis : List ℕ) (cutoff : ℕ)
    → (factor : Carrier)
    → (f : ExponentAssignment basis → Carrier)
    → sum-assignments basis cutoff (λ assignment → factor * f assignment)
      ≈ factor * sum-assignments basis cutoff f
  sum-assignments-scale [] cutoff factor f = refl
  sum-assignments-scale (prime ∷ rest) cutoff factor f = begin
    sum-assignments (prime ∷ rest) cutoff
      (λ assignment → factor * f assignment)
      ≈⟨ refl ⟩
    sum-exponents cutoff
      (λ exponent → sum-assignments rest cutoff
        (λ tail → factor * f (exponent , tail)))
      ≈⟨ sum-exponents-cong cutoff
            (λ exponent → sum-assignments rest cutoff
              (λ tail → factor * f (exponent , tail)))
            (λ exponent → factor * sum-assignments rest cutoff
              (λ tail → f (exponent , tail)))
            (λ exponent → sum-assignments-scale rest cutoff factor
              (λ tail → f (exponent , tail))) ⟩
    sum-exponents cutoff
      (λ exponent → factor * sum-assignments rest cutoff
        (λ tail → f (exponent , tail)))
      ≈⟨ sum-exponents-scale cutoff factor
            (λ exponent → sum-assignments rest cutoff
              (λ tail → f (exponent , tail))) ⟩
    factor * sum-assignments (prime ∷ rest) cutoff f
      ∎

  sum-exponents-is-scaled-geometric
    : (ratio : Carrier) (cutoff : ℕ) (tail : Carrier)
    → sum-exponents cutoff (λ exponent → power ratio exponent * tail)
      ≈ scaled-geometric ratio cutoff tail
  sum-exponents-is-scaled-geometric ratio zero tail = refl
  sum-exponents-is-scaled-geometric ratio (suc cutoff) tail =
    +-congʳ (sum-exponents-is-scaled-geometric ratio cutoff tail)

  module ForCompletelyMultiplicative
    (coefficient : ℕ → Carrier)
    (coefficient-one : coefficient 1 ≈ 1#)
    (coefficient-times : (left right : ℕ)
      → coefficient (Nat._*_ left right)
        ≈ coefficient left * coefficient right) where

    module Weights = Euler.CoefficientAssignmentWeights.OverRing R
    open Weights.ForCompletelyMultiplicative
      coefficient coefficient-one coefficient-times
      using (assignment-weight; coefficient-of-assignment)

    -- Summing independently over all bounded exponents is exactly the
    -- finite local-geometric-factor product.  The proof uses no indexing
    -- theorem and is valid for an arbitrary list of number bases.
    assignment-weights-sum-to-factors
      : (basis : List ℕ) (cutoff : ℕ)
      → sum-assignments basis cutoff (assignment-weight basis)
        ≈ finite-local-product (map coefficient basis) cutoff
    assignment-weights-sum-to-factors [] cutoff = refl
    assignment-weights-sum-to-factors (prime ∷ rest) cutoff = begin
      sum-assignments (prime ∷ rest) cutoff
        (assignment-weight (prime ∷ rest))
        ≈⟨ refl ⟩
      sum-exponents cutoff
        (λ exponent → sum-assignments rest cutoff
          (λ tail → power (coefficient prime) exponent
            * assignment-weight rest tail))
        ≈⟨ sum-exponents-cong cutoff
              (λ exponent → sum-assignments rest cutoff
                (λ tail → power (coefficient prime) exponent
                  * assignment-weight rest tail))
              (λ exponent → power (coefficient prime) exponent
                * sum-assignments rest cutoff (assignment-weight rest))
              (λ exponent → sum-assignments-scale rest cutoff
                (power (coefficient prime) exponent)
                (assignment-weight rest)) ⟩
      sum-exponents cutoff
        (λ exponent → power (coefficient prime) exponent
          * sum-assignments rest cutoff (assignment-weight rest))
        ≈⟨ sum-exponents-cong cutoff
              (λ exponent → power (coefficient prime) exponent
                * sum-assignments rest cutoff (assignment-weight rest))
              (λ exponent → power (coefficient prime) exponent
                * finite-local-product (map coefficient rest) cutoff)
              (λ exponent → *-congˡ
                (assignment-weights-sum-to-factors rest cutoff)) ⟩
      sum-exponents cutoff
        (λ exponent → power (coefficient prime) exponent
          * finite-local-product (map coefficient rest) cutoff)
        ≈⟨ sum-exponents-is-scaled-geometric (coefficient prime) cutoff
              (finite-local-product (map coefficient rest) cutoff) ⟩
      scaled-geometric (coefficient prime) cutoff
        (finite-local-product (map coefficient rest) cutoff)
        ≈⟨ scaled-geometric-factor (coefficient prime) cutoff
              (finite-local-product (map coefficient rest) cutoff) ⟩
      geometric (coefficient prime) cutoff
        * finite-local-product (map coefficient rest) cutoff
        ≈⟨ refl ⟩
      finite-local-product (map coefficient (prime ∷ rest)) cutoff
        ∎

    -- FINITE EULER PRODUCT IDENTITY, WITH ARITHMETIC COEFFICIENTS.
    --
    -- The right-hand side is an explicit bounded sum of a(n), where
    -- n = encode(basis,assignment).  The distinct-prime theorem gives
    -- injectivity of this integer indexing for actual prime bases.
    --
    -- This is not a quotient of geometric sums, an infinite product,
    -- or the complete Dirichlet L(s,chi) equality.
    finite-euler-arithmetic-sum
      : (basis : List ℕ) (cutoff : ℕ)
      → finite-local-product (map coefficient basis) cutoff
        ≈ sum-assignments basis cutoff
            (λ assignment → coefficient (encode basis assignment))
    finite-euler-arithmetic-sum basis cutoff = begin
      finite-local-product (map coefficient basis) cutoff
        ≈⟨ sym (assignment-weights-sum-to-factors basis cutoff) ⟩
      sum-assignments basis cutoff (assignment-weight basis)
        ≈⟨ sum-assignments-cong basis cutoff
              (assignment-weight basis)
              (λ assignment → coefficient (encode basis assignment))
              (λ assignment → sym (coefficient-of-assignment basis assignment)) ⟩
      sum-assignments basis cutoff
        (λ assignment → coefficient (encode basis assignment))
        ∎
