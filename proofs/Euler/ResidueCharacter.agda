{-# OPTIONS --safe --without-K #-}
module Euler.ResidueCharacter where

-- A finite residue multiplication table can certify a character on ALL
-- natural numbers. This is a genuine lifting theorem: the proof is not
-- bounded by the machine integer range of a source generator.
--
-- The finite table laws are explicit obligations of its supplier.
-- They must themselves be proved in Agda; numerical C/JS verification
-- does not inhabit any of these fields.

open import Level using (_⊔_)
open import Algebra.Bundles using (CommutativeRing)
import Data.Nat.Base as Nat
open Nat using (ℕ; zero; suc; _<_; _%_)
open import Data.Nat.DivMod using (m%n<n; %-distribˡ-*; [m+n]%n≡m%n)
open import Data.Nat.Divisibility using (_∣_; ∣-trans; %-presˡ-∣; ∣n∣m%n⇒∣m)
open import Data.Nat.GCD using (gcd; gcd-universality; gcd-greatest; gcd[m,n]∣m; gcd[m,n]∣n)
open import Data.Product.Base using (_,_)
import Relation.Binary.PropositionalEquality as Eq
open Eq using (_≡_; _≢_)
open import Euler.DirichletCertificate

-- Reduction modulo a positive integer preserves the gcd. This is
-- established through the universal divisor property, NOT by appealing
-- to a floating-point or bounded gcd implementation.
gcd-residue : (m tail : ℕ)
  → gcd m (suc tail) ≡ gcd (m % suc tail) (suc tail)
gcd-residue m tail = gcd-universality
  {m = m % suc tail} {n = suc tail} {g = gcd m (suc tail)}
  (λ (d∣remainder , d∣modulus) →
    gcd-greatest
      (∣n∣m%n⇒∣m {n = suc tail} {m = m} d∣modulus d∣remainder)
      d∣modulus)
  (λ d∣gcd →
    %-presˡ-∣
      (∣-trans d∣gcd (gcd[m,n]∣m m (suc tail)))
      (∣-trans d∣gcd (gcd[m,n]∣n m (suc tail))) ,
    ∣-trans d∣gcd (gcd[m,n]∣n m (suc tail)))

record FiniteResidueCharacter {c ℓ}
  (R : CommutativeRing c ℓ) (tail : ℕ) : Set (c ⊔ ℓ) where
  open CommutativeRing R hiding (zero)
  private
    q = suc tail
  field
    table : ℕ → Carrier
    table-one : table (1 % q) ≈ 1#
    table-product : (a b : ℕ)
      → a < q → b < q
      → table ((Nat._*_ a b) % q) ≈ table a * table b
    table-nonunit-zero : (a : ℕ)
      → a < q → gcd a q ≢ 1
      → table a ≈ 0#

module CertifiedFromTable {c ℓ}
  (R : CommutativeRing c ℓ)
  (tail : ℕ)
  (finite : FiniteResidueCharacter R tail) where

  open CommutativeRing R hiding (zero)
  open import Relation.Binary.Reasoning.Setoid setoid
  open FiniteResidueCharacter finite

  q = suc tail

  -- The sole definition of the infinite-natural-number coefficient.
  value : ℕ → Carrier
  value n = table (n % q)

  table-cong : ∀ {m n} → m ≡ n → table m ≈ table n
  table-cong Eq.refl = refl

  value-product : (m n : ℕ)
    → value (Nat._*_ m n) ≈ value m * value n
  value-product m n = begin
    value (Nat._*_ m n)
      ≈⟨ refl ⟩
    table ((Nat._*_ m n) % q)
      ≈⟨ table-cong (%-distribˡ-* m n q) ⟩
    table (((m % q) Nat.* (n % q)) % q)
      ≈⟨ table-product (m % q) (n % q)
           (m%n<n m q) (m%n<n n q) ⟩
    table (m % q) * table (n % q)
      ≈⟨ refl ⟩
    value m * value n
      ∎

  value-periodic : (n : ℕ)
    → value (Nat._+_ n q) ≈ value n
  value-periodic n =
    table-cong ([m+n]%n≡m%n n q)

  value-nonunit-zero : (n : ℕ)
    → gcd n q ≢ 1 → value n ≈ 0#
  value-nonunit-zero n not-unit =
    table-nonunit-zero (n % q) (m%n<n n q)
      (λ residue-gcd-one →
        not-unit (Eq.trans (gcd-residue n tail) residue-gcd-one))

  -- The public proof certificate is now valid on ALL natural numbers.
  -- The only remaining input is a genuine finite table certificate.
  certified : DirichletCharacterCertificate R
  certified = record
    { modulus = q
    ; modulus-nonzero = λ ()
    ; value = value
    ; value-one = table-one
    ; value-product = value-product
    ; value-periodic = value-periodic
    ; value-nonunit-zero = value-nonunit-zero
    }
