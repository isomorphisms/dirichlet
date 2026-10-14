{-# OPTIONS --safe --without-K #-}
module Euler.QuadraticCharacterThree where

-- The nonprincipal quadratic Dirichlet character modulo 3, constructed
-- with a *checked* integer residue table rather than an assumed field.
-- Normalization, multiplicativity, periodicity on every natural number,
-- and vanishing at nonunits all follow from Agda proofs.

open import Data.Empty using (⊥-elim)
open import Data.Nat.Base using (ℕ; zero; suc; s≤s; _<_; _*_; _%_)
open import Data.Nat.GCD using (gcd)
open import Relation.Binary.PropositionalEquality using (_≡_; _≢_; refl)
import Data.Integer.Base as Int
open Int using (ℤ; 0ℤ; 1ℤ; -1ℤ)
import Data.Integer.Properties as IntegerProperties
open import Euler.ResidueCharacter
open import Euler.DirichletCertificate
open import Data.List.Base using (List)

ring = IntegerProperties.+-*-commutativeRing

table3 : ℕ → ℤ
table3 zero = 0ℤ
table3 (suc zero) = 1ℤ
table3 (suc (suc zero)) = -1ℤ
table3 (suc (suc (suc n))) = 0ℤ

-- Complete 3×3 multiplication table. Cases outside 0,1,2 are excluded
-- by the bounds, so there is no default "assume true" branch.
product3 : (a b : ℕ) → a < 3 → b < 3
  → table3 ((a * b) % 3) ≡ Int._*_ (table3 a) (table3 b)
product3 zero zero _ _ = refl
product3 zero (suc zero) _ _ = refl
product3 zero (suc (suc zero)) _ _ = refl
product3 zero (suc (suc (suc n))) _ (s≤s (s≤s (s≤s ())))
product3 (suc zero) zero _ _ = refl
product3 (suc zero) (suc zero) _ _ = refl
product3 (suc zero) (suc (suc zero)) _ _ = refl
product3 (suc zero) (suc (suc (suc n))) _ (s≤s (s≤s (s≤s ())))
product3 (suc (suc zero)) zero _ _ = refl
product3 (suc (suc zero)) (suc zero) _ _ = refl
product3 (suc (suc zero)) (suc (suc zero)) _ _ = refl
product3 (suc (suc zero)) (suc (suc (suc n))) _ (s≤s (s≤s (s≤s ())))
product3 (suc (suc (suc n))) b (s≤s (s≤s (s≤s ()))) _

nonunit3 : (a : ℕ) → a < 3 → gcd a 3 ≢ 1 → table3 a ≡ 0ℤ
nonunit3 zero _ _ = refl
nonunit3 (suc zero) _ nonunit = ⊥-elim (nonunit refl)
nonunit3 (suc (suc zero)) _ nonunit = ⊥-elim (nonunit refl)
nonunit3 (suc (suc (suc n))) (s≤s (s≤s (s≤s ()))) _

finite3 : FiniteResidueCharacter ring 2
finite3 = record
  { table = table3
  ; table-one = refl
  ; table-product = product3
  ; table-nonunit-zero = nonunit3
  }

module FromTable = CertifiedFromTable ring 2 finite3
open FromTable using (value)

certified3 : DirichletCharacterCertificate ring
certified3 = FromTable.certified

chi3-at-two : value 2 ≡ -1ℤ
chi3-at-two = refl

chi3-at-three : value 3 ≡ 0ℤ
chi3-at-three = refl

chi3-at-four : value 4 ≡ 1ℤ
chi3-at-four = refl

module Euler3 = OverCertifiedCharacter ring certified3

finite-chi3-euler
  : (bases : List ℕ) (cutoff : ℕ)
  → Euler3.finite-local-product bases cutoff
    ≡ Euler3.arithmetic-exponent-sum bases cutoff 1
finite-chi3-euler = Euler3.finite-character-euler-expansion
