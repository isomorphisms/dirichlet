{-# OPTIONS --safe --without-K #-}
module Euler.DirichletCertificate where

-- A formal, proof-carrying boundary for arithmetic Dirichlet characters.
-- A residue-phase table from a C/JS generator is NOT itself a proof of
-- any of these fields. Agda consumers must construct checked witnesses.
--
-- This module does not assume complex numbers or commit mathematical
-- structure to Idriç's general-purpose language core. The ring is supplied
-- by the consuming mathematics project.

open import Level using (_⊔_)
open import Algebra.Bundles using (CommutativeRing)
import Data.Nat.Base as Nat
open Nat using (ℕ; zero; suc)
open import Data.Nat.GCD using (gcd)
open import Relation.Binary.PropositionalEquality using (_≢_)
open import Geometric.General
import Euler.CharacterExpansion as Expansion

record DirichletCharacterCertificate {c ℓ}
  (R : CommutativeRing c ℓ) : Set (c ⊔ ℓ) where
  open CommutativeRing R hiding (zero)
  field
    modulus : ℕ
    modulus-nonzero : modulus ≢ 0
    value : ℕ → Carrier
    value-one : value 1 ≈ 1#
    value-product : (m n : ℕ)
      → value (Nat._*_ m n) ≈ value m * value n
    value-periodic : (n : ℕ)
      → value (Nat._+_ n modulus) ≈ value n
    value-nonunit-zero : (n : ℕ)
      → gcd n modulus ≢ 1
      → value n ≈ 0#

module OverCertifiedCharacter {c ℓ}
  (R : CommutativeRing c ℓ)
  (certificate : DirichletCharacterCertificate R) where

  open CommutativeRing R hiding (zero)
  open import Relation.Binary.Reasoning.Setoid setoid
  open DirichletCharacterCertificate certificate

  open Geometric.General.OverCommutativeRing R using (power; geometric)
  module ExpansionRing = Expansion.OverRing R
  module Arithmetic =
    ExpansionRing.ForCompletelyMultiplicative
      value value-one value-product
  open Arithmetic public
    using (finite-local-product; arithmetic-exponent-sum;
           arithmetic-exponent-sum-factor; finite-character-euler-expansion)

  -- Setoid congruence of integer powers and finite geometric factors.
  power-cong
    : (left right : Carrier)
    → left ≈ right
    → (n : ℕ)
    → power left n ≈ power right n
  power-cong left right eq zero = refl
  power-cong left right eq (suc n) =
    *-cong eq (power-cong left right eq n)

  geometric-cong
    : (left right : Carrier)
    → left ≈ right
    → (n : ℕ)
    → geometric left n ≈ geometric right n
  geometric-cong left right eq zero = refl
  geometric-cong left right eq (suc n) =
    +-cong (geometric-cong left right eq n)
      (power-cong left right eq n)

  -- The truncated local Euler factor at a nonunit prime equals 1 for
  -- positive exponent cutoff. The statement is valid for any nonunit
  -- integer; the caller need not prove primality for this local lemma.
  zero-local-factor : (count : ℕ)
    → geometric 0# (suc count) ≈ 1#
  zero-local-factor zero = begin
    geometric 0# (suc zero)
      ≈⟨ refl ⟩
    0# + 1#
      ≈⟨ +-identityˡ 1# ⟩
    1#
      ∎
  zero-local-factor (suc count) = begin
    geometric 0# (suc (suc count))
      ≈⟨ refl ⟩
    geometric 0# (suc count) + (0# * power 0# count)
      ≈⟨ +-cong (zero-local-factor count)
           (zeroˡ (power 0# count)) ⟩
    1# + 0#
      ≈⟨ +-identityʳ 1# ⟩
    1#
      ∎

  nonunit-local-factor
    : (p : ℕ)
    → gcd p modulus ≢ 1
    → (count : ℕ)
    → geometric (value p) (suc count) ≈ 1#
  nonunit-local-factor p nonunit count = begin
    geometric (value p) (suc count)
      ≈⟨ geometric-cong (value p) 0#
           (value-nonunit-zero p nonunit) (suc count) ⟩
    geometric 0# (suc count)
      ≈⟨ zero-local-factor count ⟩
    1#
      ∎
