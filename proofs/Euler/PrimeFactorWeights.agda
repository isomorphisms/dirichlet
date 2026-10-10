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
open import Data.Product.Base using (_×_; _,_)
open import Geometric.General
open import Data.Nat.ListAction using (product)
open import Data.Nat.Primality.Factorisation using (PrimeFactorisation)
import Relation.Binary.PropositionalEquality as Equality

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

    -- The arithmetic exponent p^k has the corresponding coefficient power.
    -- This makes the prime-power terms of finite local Euler factors explicit.
    natural-power : ℕ → ℕ → ℕ
    natural-power base Nat.zero = 1
    natural-power base (Nat.suc exponent) =
      Nat._*_ base (natural-power base exponent)

    coefficient-of-power
      : (base exponent : ℕ)
      → coefficient (natural-power base exponent)
        ≈ power (coefficient base) exponent
    coefficient-of-power base Nat.zero = coefficient-one
    coefficient-of-power base (Nat.suc exponent) = begin
      coefficient (natural-power base (Nat.suc exponent))
        ≈⟨ refl ⟩
      coefficient (Nat._*_ base (natural-power base exponent))
        ≈⟨ coefficient-times base (natural-power base exponent) ⟩
      coefficient base * coefficient (natural-power base exponent)
        ≈⟨ *-congˡ (coefficient-of-power base exponent) ⟩
      coefficient base * power (coefficient base) exponent
        ≈⟨ refl ⟩
      power (coefficient base) (Nat.suc exponent)
        ∎

    -- Associate a list of (base, exponent) pairs to its integer and
    -- its local prime-power coefficient product. Primality/uniqueness
    -- of the bases is NOT assumed by these algebraic definitions.
    exponent-number : List (ℕ × ℕ) → ℕ
    exponent-number [] = 1
    exponent-number ((base , exponent) ∷ rest) =
      Nat._*_ (natural-power base exponent) (exponent-number rest)

    exponent-weight : List (ℕ × ℕ) → Carrier
    exponent-weight [] = 1#
    exponent-weight ((base , exponent) ∷ rest) =
      power (coefficient base) exponent * exponent-weight rest

    coefficient-of-exponent-list
      : (base-exponents : List (ℕ × ℕ))
      → coefficient (exponent-number base-exponents)
        ≈ exponent-weight base-exponents
    coefficient-of-exponent-list [] = coefficient-one
    coefficient-of-exponent-list ((base , exponent) ∷ rest) = begin
      coefficient (exponent-number ((base , exponent) ∷ rest))
        ≈⟨ refl ⟩
      coefficient (Nat._*_ (natural-power base exponent)
                           (exponent-number rest))
        ≈⟨ coefficient-times (natural-power base exponent)
                              (exponent-number rest) ⟩
      coefficient (natural-power base exponent)
        * coefficient (exponent-number rest)
        ≈⟨ *-cong (coefficient-of-power base exponent)
                   (coefficient-of-exponent-list rest) ⟩
      power (coefficient base) exponent * exponent-weight rest
        ≈⟨ refl ⟩
      exponent-weight ((base , exponent) ∷ rest)
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
