{-# OPTIONS --safe --without-K #-}
module Euler.PrimeFactorWeights where

-- Completely multiplicative coefficients respect any prime factorisation.
-- This does not assume that the coefficient has a complex implementation.
-- The standard library's PrimeFactorisation carries both the prime proofs
-- and the certified equation n = product factors.
--
-- No analytic limits, characters, primality tests or normalizing casts occur.

open import Algebra.Bundles using (CommutativeRing)
import Data.Nat.Base as Nat
open Nat using (ℕ)
open import Data.List.Base using (List; []; _∷_)
open import Data.Nat.ListAction using (product)
open import Data.Nat.Primality.Factorisation using (PrimeFactorisation)
import Relation.Binary.PropositionalEquality as Equality

module OverRing {c ℓ} (R : CommutativeRing c ℓ) where

  open CommutativeRing R hiding (zero)
  open import Relation.Binary.Reasoning.Setoid setoid

  module ForCompletelyMultiplicative
    (coefficient : ℕ → Carrier)
    (coefficient-one : coefficient 1 ≈ 1#)
    (coefficient-times : (left right : ℕ)
      → coefficient (Nat._*_ left right)
        ≈ coefficient left * coefficient right) where

    -- Product of coefficient(p) over the factorisation list, with
    -- multiplicities. It is *not* a product over distinct primes.
    prime-weights : List ℕ → Carrier
    prime-weights [] = 1#
    prime-weights (p ∷ rest) =
      coefficient p * prime-weights rest

    -- Finite multiplicativity, obtained by induction on the factors.
    coefficient-of-product
      : (factors : List ℕ)
      → coefficient (product factors) ≈ prime-weights factors
    coefficient-of-product [] = coefficient-one
    coefficient-of-product (p ∷ rest) = begin
      coefficient (product (p ∷ rest))
        ≈⟨ refl ⟩
      coefficient (Nat._*_ p (product rest))
        ≈⟨ coefficient-times p (product rest) ⟩
      coefficient p * coefficient (product rest)
        ≈⟨ *-congˡ (coefficient-of-product rest) ⟩
      coefficient p * prime-weights rest
        ≈⟨ refl ⟩
      prime-weights (p ∷ rest)
        ∎

    -- Every *supplied, certified* prime factorisation gives exactly the
    -- original arithmetic coefficient. Agda's stdlib supplies the
    -- existence/uniqueness of those factorisations separately.
    coefficient-of-prime-factorisation
      : (n : ℕ) (factorisation : PrimeFactorisation n)
      → coefficient n
        ≈ prime-weights (PrimeFactorisation.factors factorisation)
    coefficient-of-prime-factorisation n factorisation =
      Equality.subst
        (λ k → coefficient k
          ≈ prime-weights (PrimeFactorisation.factors factorisation))
        (Equality.sym (PrimeFactorisation.isFactorisation factorisation))
        (coefficient-of-product
          (PrimeFactorisation.factors factorisation))

    -- A useful invariance corollary: the coefficient product is
    -- independent of which valid factorisation witness was supplied.
    factorisation-independent
      : (n : ℕ)
      → (first second : PrimeFactorisation n)
      → prime-weights (PrimeFactorisation.factors first)
        ≈ prime-weights (PrimeFactorisation.factors second)
    factorisation-independent n first second =
      trans (sym (coefficient-of-prime-factorisation n first))
            (coefficient-of-prime-factorisation n second)
