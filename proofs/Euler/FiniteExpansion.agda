{-# OPTIONS --safe --without-K #-}
module Euler.FiniteExpansion where

-- Finite Euler-factor expansion, independently of unique factorization,
-- absolute convergence, or complex analytic continuation.
--
-- A list of ratios may eventually be instantiated as
--   chi(p) * p^(-s)
-- for a list of distinct primes. The identities proved here do NOT say
-- that those primes enumerate every integer: that is a later theorem.
-- Each local geometric factor has an explicit *finite* exponent cutoff.

open import Algebra.Bundles using (CommutativeRing)
open import Data.Nat.Base using (ℕ; zero; suc)
open import Data.List.Base using (List; []; _∷_)
open import Geometric.General

module OverRing {c ℓ} (R : CommutativeRing c ℓ) where

  open CommutativeRing R hiding (zero)
  open import Relation.Binary.Reasoning.Setoid setoid
  open Geometric.General.OverCommutativeRing R using (power; geometric)

  -- Sum_{k=0}^{cutoff-1} ratio^k * tail.
  -- Keeping the tail *inside* the sum makes this an independent nested
  -- exponent enumeration, not the definition of a product of factors.
  scaled-geometric : Carrier → ℕ → Carrier → Carrier
  scaled-geometric ratio zero tail = 0#
  scaled-geometric ratio (suc cutoff) tail =
    scaled-geometric ratio cutoff tail + power ratio cutoff * tail

  -- Distributivity is what turns that exponent sum into a local factor.
  scaled-geometric-factor
    : (ratio : Carrier) (cutoff : ℕ) (tail : Carrier)
    → scaled-geometric ratio cutoff tail ≈ geometric ratio cutoff * tail
  scaled-geometric-factor ratio zero tail = begin
    scaled-geometric ratio zero tail
      ≈⟨ refl ⟩
    0#
      ≈⟨ sym (zeroˡ tail) ⟩
    0# * tail
      ≈⟨ refl ⟩
    geometric ratio zero * tail
      ∎
  scaled-geometric-factor ratio (suc cutoff) tail = begin
    scaled-geometric ratio (suc cutoff) tail
      ≈⟨ refl ⟩
    scaled-geometric ratio cutoff tail + power ratio cutoff * tail
      ≈⟨ +-congʳ (scaled-geometric-factor ratio cutoff tail) ⟩
    geometric ratio cutoff * tail + power ratio cutoff * tail
      ≈⟨ sym (distribʳ tail (geometric ratio cutoff) (power ratio cutoff)) ⟩
    (geometric ratio cutoff + power ratio cutoff) * tail
      ≈⟨ refl ⟩
    geometric ratio (suc cutoff) * tail
      ∎

  -- A finite product of finite local geometric factors.
  finite-local-product : List Carrier → ℕ → Carrier
  finite-local-product [] cutoff = 1#
  finite-local-product (ratio ∷ rest) cutoff =
    geometric ratio cutoff * finite-local-product rest cutoff

  -- Nested sum over one exponent k for every ratio in the input list.
  -- The empty list has the single empty exponent assignment of weight 1.
  exponent-expanded : List Carrier → ℕ → Carrier
  exponent-expanded [] cutoff = 1#
  exponent-expanded (ratio ∷ rest) cutoff =
    scaled-geometric ratio cutoff (exponent-expanded rest cutoff)

  -- The finite, algebraic precursor to a Dirichlet Euler product.
  -- It uses only ring distributivity and induction on the list/cutoff.
  -- No nonzero denominators, analytic limits, or primality assumptions.
  finite-product-expands
    : (ratios : List Carrier) (cutoff : ℕ)
    → finite-local-product ratios cutoff ≈ exponent-expanded ratios cutoff
  finite-product-expands [] cutoff = refl
  finite-product-expands (ratio ∷ rest) cutoff = begin
    finite-local-product (ratio ∷ rest) cutoff
      ≈⟨ refl ⟩
    geometric ratio cutoff * finite-local-product rest cutoff
      ≈⟨ *-congˡ (finite-product-expands rest cutoff) ⟩
    geometric ratio cutoff * exponent-expanded rest cutoff
      ≈⟨ sym (scaled-geometric-factor ratio cutoff
                   (exponent-expanded rest cutoff)) ⟩
    scaled-geometric ratio cutoff (exponent-expanded rest cutoff)
      ≈⟨ refl ⟩
    exponent-expanded (ratio ∷ rest) cutoff
      ∎
