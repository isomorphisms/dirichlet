{-# OPTIONS --safe --without-K #-}
module Euler.TrivialCharacter where

-- A *constructed* Dirichlet character certificate, with no axioms
-- supplied by a caller: the modulus-one character chi(n)=1.
-- This shows how an actual proof-bearing character instantiates the
-- arithmetic finite Euler theorem. It does NOT verify a C11/JS table.

open import Algebra.Bundles using (CommutativeRing)
open import Data.Empty using (⊥-elim)
open import Data.Nat.Base using (ℕ)
open import Data.Nat.GCD using (gcd-zeroʳ)
open import Data.List.Base using (List)
open import Euler.DirichletCertificate

module OverRing {c ℓ} (R : CommutativeRing c ℓ) where

  open CommutativeRing R hiding (zero)

  -- Every integer is a unit modulo 1. The nonunit-zero obligation
  -- is discharged by gcd(n,1)=1, not by assuming an impossible law.
  character-one : DirichletCharacterCertificate R
  character-one = record
    { modulus = 1
    ; modulus-nonzero = λ ()
    ; value = λ n → 1#
    ; value-one = refl
    ; value-product = λ m n → sym (*-identityʳ 1#)
    ; value-periodic = λ n → refl
    ; value-nonunit-zero =
        λ n not-a-unit → ⊥-elim (not-a-unit (gcd-zeroʳ n))
    }

  module Concrete = OverCertifiedCharacter R character-one
  open Concrete using (finite-local-product; arithmetic-exponent-sum)

  -- Actual certified modulus-one specialization of the finite
  -- arithmetic Euler expansion (the finite precursor to zeta).
  finite-trivial-character-euler
    : (bases : List ℕ) (cutoff : ℕ)
    → finite-local-product bases cutoff
      ≈ arithmetic-exponent-sum bases cutoff 1
  finite-trivial-character-euler =
    Concrete.finite-character-euler-expansion
