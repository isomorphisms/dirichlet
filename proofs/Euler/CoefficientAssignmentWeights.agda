{-# OPTIONS --safe --without-K #-}
module Euler.CoefficientAssignmentWeights where

-- The coefficient a(n), for a completely multiplicative arithmetic
-- function into any commutative ring, equals the product of local prime
-- weights prescribed by the exponent assignment encoding n.
--
-- This connects the natural-number encoding of the finite-prime-basis
-- proof to the local geometric weights in the formal Euler expansion.
-- It is not an analytic statement about convergence.

open import Algebra.Bundles using (CommutativeRing)
import Data.Nat.Base as Nat
open Nat using (ℕ; zero; suc)
open import Data.List.Base using (List; []; _∷_; _++_; replicate)
open import Data.Product.Base using (_,_)
open import Data.Unit.Base using (tt)
open import Euler.PrimeExponentInjectivity
  using (ExponentAssignment; expanded-primes; encode)
import Euler.PrimeFactorWeights
open import Geometric.General

module OverRing {c ℓ} (R : CommutativeRing c ℓ) where
  open CommutativeRing R hiding (zero)
  open import Relation.Binary.Reasoning.Setoid setoid
  open Geometric.General.OverCommutativeRing R using (power)

  module ForCompletelyMultiplicative
    (coefficient : ℕ → Carrier)
    (coefficient-one : coefficient 1 ≈ 1#)
    (coefficient-times : (left right : ℕ)
      → coefficient (Nat._*_ left right)
        ≈ coefficient left * coefficient right) where

    module Factor = Euler.PrimeFactorWeights.OverRing R
    open Factor.ForCompletelyMultiplicative
      coefficient coefficient-one coefficient-times
      using (prime-weights; coefficient-of-product)

    -- The expression that appears as a term of the expanded local-factor
    -- product, before any identification with arithmetic integers.
    assignment-weight
      : (basis : List ℕ) → ExponentAssignment basis → Carrier
    assignment-weight [] tt = 1#
    assignment-weight (prime ∷ rest) (exponent , tail) =
      power (coefficient prime) exponent * assignment-weight rest tail

    -- Multiplicative weight of a concatenation of factor lists.
    prime-weights-append
      : (left right : List ℕ)
      → prime-weights (left ++ right)
        ≈ prime-weights left * prime-weights right
    prime-weights-append [] right =
      sym (*-identityˡ (prime-weights right))
    prime-weights-append (prime ∷ rest) right = begin
      coefficient prime * prime-weights (rest ++ right)
        ≈⟨ *-congˡ (prime-weights-append rest right) ⟩
      coefficient prime * (prime-weights rest * prime-weights right)
        ≈⟨ sym (*-assoc (coefficient prime)
                 (prime-weights rest) (prime-weights right)) ⟩
      (coefficient prime * prime-weights rest) * prime-weights right
        ∎

    -- Repeating one prime exponent times computes its local power.
    prime-weights-repeated
      : (prime : ℕ) (exponent : ℕ)
      → prime-weights (replicate exponent prime)
        ≈ power (coefficient prime) exponent
    prime-weights-repeated prime zero = refl
    prime-weights-repeated prime (suc exponent) = begin
      coefficient prime * prime-weights (replicate exponent prime)
        ≈⟨ *-congˡ (prime-weights-repeated prime exponent) ⟩
      coefficient prime * power (coefficient prime) exponent
        ≈⟨ refl ⟩
      power (coefficient prime) (suc exponent)
        ∎

    -- Expand the encoded prime list, preserving the local exponent
    -- weights exactly. Repeated bases are allowed here; uniqueness of
    -- exponent assignment requires the separate distinct-prime theorem.
    prime-weights-of-assignment
      : (basis : List ℕ) (assignment : ExponentAssignment basis)
      → prime-weights (expanded-primes basis assignment)
        ≈ assignment-weight basis assignment
    prime-weights-of-assignment [] tt = refl
    prime-weights-of-assignment (prime ∷ rest) (exponent , tail) = begin
      prime-weights
        (replicate exponent prime ++ expanded-primes rest tail)
        ≈⟨ prime-weights-append (replicate exponent prime)
              (expanded-primes rest tail) ⟩
      prime-weights (replicate exponent prime)
        * prime-weights (expanded-primes rest tail)
        ≈⟨ *-cong (prime-weights-repeated prime exponent)
                   (prime-weights-of-assignment rest tail) ⟩
      power (coefficient prime) exponent * assignment-weight rest tail
        ∎

    -- The termwise arithmetic identification needed to reindex finite
    -- Euler expansions by actual integers.
    coefficient-of-assignment
      : (basis : List ℕ) (assignment : ExponentAssignment basis)
      → coefficient (encode basis assignment)
        ≈ assignment-weight basis assignment
    coefficient-of-assignment basis assignment =
      trans (coefficient-of-product (expanded-primes basis assignment))
            (prime-weights-of-assignment basis assignment)
