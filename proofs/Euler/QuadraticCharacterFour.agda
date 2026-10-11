{-# OPTIONS --safe --without-K #-}
module Euler.QuadraticCharacterFour where

-- A genuinely nonprincipal Dirichlet character, proved rather than
-- accepted because an executable modulus-four table happened to pass.
--
-- chi4(n) = 0 for even n, +1 for n≡1 mod 4, -1 for n≡3 mod 4.
-- The finite table laws below have no postulates or opaque foreign tests.
-- Euler.ResidueCharacter lifts those finite laws to ALL natural n.

open import Data.Empty using (⊥-elim)
open import Data.Nat.Base using (ℕ; zero; suc; _<_; _*_; _%_)
open import Data.Nat.GCD using (gcd)
open import Relation.Binary.PropositionalEquality using (_≡_; _≢_; refl)
import Data.Integer.Base as Int
open Int using (ℤ; 0ℤ; 1ℤ; -1ℤ)
import Data.Integer.Properties as IntegerProperties
open import Euler.ResidueCharacter
open import Euler.DirichletCertificate
open import Data.List.Base using (List)

ring = IntegerProperties.+-*-commutativeRing

-- The table is only used at residues 0,1,2,3. Its values elsewhere
-- are immaterial because the lifting theorem always reduces mod 4.
table4 : ℕ → ℤ
table4 zero = 0ℤ
table4 (suc zero) = 1ℤ
table4 (suc (suc zero)) = 0ℤ
table4 (suc (suc (suc zero))) = -1ℤ
table4 (suc (suc (suc (suc n)))) = 0ℤ

-- All 16 possible pairs of residues are checked by normalization in
-- the standard integer ring; a>=4 or b>=4 contradicts the bounds.
product4 : (a b : ℕ) → a < 4 → b < 4
  → table4 ((a * b) % 4) ≡ Int._*_ (table4 a) (table4 b)
product4 zero zero _ _ = refl
product4 zero (suc zero) _ _ = refl
product4 zero (suc (suc zero)) _ _ = refl
product4 zero (suc (suc (suc zero))) _ _ = refl
product4 zero (suc (suc (suc (suc n)))) _ ()
product4 (suc zero) zero _ _ = refl
product4 (suc zero) (suc zero) _ _ = refl
product4 (suc zero) (suc (suc zero)) _ _ = refl
product4 (suc zero) (suc (suc (suc zero))) _ _ = refl
product4 (suc zero) (suc (suc (suc (suc n)))) _ ()
product4 (suc (suc zero)) zero _ _ = refl
product4 (suc (suc zero)) (suc zero) _ _ = refl
product4 (suc (suc zero)) (suc (suc zero)) _ _ = refl
product4 (suc (suc zero)) (suc (suc (suc zero))) _ _ = refl
product4 (suc (suc zero)) (suc (suc (suc (suc n)))) _ ()
product4 (suc (suc (suc zero))) zero _ _ = refl
product4 (suc (suc (suc zero))) (suc zero) _ _ = refl
product4 (suc (suc (suc zero))) (suc (suc zero)) _ _ = refl
product4 (suc (suc (suc zero))) (suc (suc (suc zero))) _ _ = refl
product4 (suc (suc (suc zero))) (suc (suc (suc (suc n)))) _ ()
product4 (suc (suc (suc (suc n)))) b () _

-- Nonunits modulo four have residues 0 or 2. On residues 1 and 3,
-- the standard-library gcd computes to 1, contradicting the hypothesis.
nonunit4 : (a : ℕ) → a < 4 → gcd a 4 ≢ 1 → table4 a ≡ 0ℤ
nonunit4 zero _ _ = refl
nonunit4 (suc zero) _ not-a-unit = ⊥-elim (not-a-unit refl)
nonunit4 (suc (suc zero)) _ _ = refl
nonunit4 (suc (suc (suc zero))) _ not-a-unit = ⊥-elim (not-a-unit refl)
nonunit4 (suc (suc (suc (suc n)))) () _

finite4 : FiniteResidueCharacter ring 3
finite4 = record
  { table = table4
  ; table-one = refl
  ; table-product = product4
  ; table-nonunit-zero = nonunit4
  }

module FromTable = CertifiedFromTable ring 3 finite4
open FromTable using (value)

certified4 : DirichletCharacterCertificate ring
certified4 = FromTable.certified

-- Closed values are genuine computational consequences of the
-- definition, not a substitute for the quantified laws above.
chi4-at-two : value 2 ≡ 0ℤ
chi4-at-two = refl

chi4-at-three : value 3 ≡ -1ℤ
chi4-at-three = refl

chi4-at-five : value 5 ≡ 1ℤ
chi4-at-five = refl

module Euler4 = OverCertifiedCharacter ring certified4

-- Fully certified finite arithmetic Euler identity for a nonprincipal
-- character. This is not yet an analytic infinite Euler product.
finite-chi4-euler
  : (bases : List ℕ) (cutoff : ℕ)
  → Euler4.finite-local-product bases cutoff
    ≡ Euler4.arithmetic-exponent-sum bases cutoff 1
finite-chi4-euler = Euler4.finite-character-euler-expansion
