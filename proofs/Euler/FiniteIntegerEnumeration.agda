{-# OPTIONS --safe --without-K #-}
module Euler.FiniteIntegerEnumeration where

-- Explicitly enumerate the positive integers in a bounded Euler sum.
-- This module checks:
--   (1) that the ordered list implements the independently defined
--       bounded exponent sum, using only commutative ring laws;
--   (2) that every enumerated integer has a certified bounded smooth
--       prime factorisation;
--   (3) that every independently characterised bounded smooth integer
--       occurs in the list.
--
-- Absence of duplicates is a SEPARATE theorem: it follows from the
-- uniqueness of prime-exponent encodings together with uniqueness of
-- the exponent enumeration, and must not be assumed from this file.

open import Data.Nat.Base using (ℕ; zero; suc; _<_)
import Data.Nat.Base as Nat
import Data.Nat.Properties as NatProperties
open import Data.List.Base
  using (List; []; _∷_; _++_; map; concatMap; downFrom)
open import Data.List.Relation.Unary.All
  using (All; []; _∷_)
open import Data.List.Relation.Unary.Any
  using (Any; here; there)
open import Data.List.Membership.Propositional using (_∈_)
import Data.List.Membership.Propositional.Properties as Membership
open import Data.Product.Base using (_,_; _×_; Σ)
open import Data.Unit.Base using (tt)
open import Relation.Binary.PropositionalEquality.Core
  using (_≡_)
import Relation.Binary.PropositionalEquality as Equality
open import Euler.PrimeExponentInjectivity
  using (ExponentAssignment; Distinct; encode)
open import Euler.BoundedSmoothSupport
  using (Bounded; BoundedSmoothInteger;
         bounded-assignment-gives-supported-integer;
         supported-integer-gives-bounded-assignment)
open import Data.Nat.Primality using (Prime)

-- Enumerate each exponent from cutoff-1 down to 0, then recursively
-- enumerate the remaining coordinates. The empty basis has one
-- exponent assignment (the empty tuple), even when cutoff is zero.
bounded-assignments
  : (basis : List ℕ) (cutoff : ℕ) → List (ExponentAssignment basis)
bounded-assignments [] cutoff = tt ∷ []
bounded-assignments (prime ∷ rest) cutoff =
  concatMap
    (λ exponent → map
      (λ tail → exponent , tail)
      (bounded-assignments rest cutoff))
    (downFrom cutoff)

-- These are genuine integer indices, not serialized tuples.
bounded-integers : (basis : List ℕ) (cutoff : ℕ) → List ℕ
bounded-integers basis cutoff =
  map (encode basis) (bounded-assignments basis cutoff)

-- All exponents in downFrom cutoff are strictly smaller than cutoff.
weaken-exponent-bound
  : (items : List ℕ) (cutoff : ℕ)
  → All (λ exponent → exponent < cutoff) items
  → All (λ exponent → exponent < suc cutoff) items
weaken-exponent-bound [] cutoff [] = []
weaken-exponent-bound (exponent ∷ rest) cutoff (bound ∷ bounds) =
  NatProperties.m<n⇒m<1+n bound
    ∷ weaken-exponent-bound rest cutoff bounds

downFrom-bounded
  : (cutoff : ℕ)
  → All (λ exponent → exponent < cutoff) (downFrom cutoff)
downFrom-bounded zero = []
downFrom-bounded (suc cutoff) =
  NatProperties.≤-refl
    ∷ weaken-exponent-bound (downFrom cutoff) cutoff
        (downFrom-bounded cutoff)

all-append
  : {A : Set} (P : A → Set) (left right : List A)
  → All P left → All P right → All P (left ++ right)
all-append P [] right [] right-proofs = right-proofs
all-append P (item ∷ rest) right (proof ∷ rest-proofs) right-proofs =
  proof ∷ all-append P rest right rest-proofs right-proofs

bounded-block
  : (prime : ℕ) (rest : List ℕ) (cutoff exponent : ℕ)
  → exponent < cutoff
  → (tails : List (ExponentAssignment rest))
  → All (Bounded cutoff rest) tails
  → All (Bounded cutoff (prime ∷ rest))
      (map (λ tail → exponent , tail) tails)
bounded-block prime rest cutoff exponent bound [] [] = []
bounded-block prime rest cutoff exponent bound (tail ∷ tails)
              (tail-bound ∷ tail-bounds) =
  (bound , tail-bound)
    ∷ bounded-block prime rest cutoff exponent bound tails tail-bounds

bounded-blocks
  : (prime : ℕ) (rest : List ℕ) (cutoff : ℕ)
  → (options : List ℕ)
  → All (λ exponent → exponent < cutoff) options
  → (tails : List (ExponentAssignment rest))
  → All (Bounded cutoff rest) tails
  → All (Bounded cutoff (prime ∷ rest))
      (concatMap (λ exponent →
        map (λ tail → exponent , tail) tails) options)
bounded-blocks prime rest cutoff [] [] tails tail-bounds = []
bounded-blocks prime rest cutoff (exponent ∷ options)
               (bound ∷ bounds) tails tail-bounds =
  all-append (Bounded cutoff (prime ∷ rest))
    (map (λ tail → exponent , tail) tails)
    (concatMap (λ index → map (λ tail → index , tail) tails) options)
    (bounded-block prime rest cutoff exponent bound tails tail-bounds)
    (bounded-blocks prime rest cutoff options bounds tails tail-bounds)

-- The actual enumeration never generates an out-of-range exponent.
all-bounded-assignments
  : (basis : List ℕ) (cutoff : ℕ)
  → All (Bounded cutoff basis) (bounded-assignments basis cutoff)
all-bounded-assignments [] cutoff = tt ∷ []
all-bounded-assignments (prime ∷ rest) cutoff =
  bounded-blocks prime rest cutoff (downFrom cutoff)
    (downFrom-bounded cutoff)
    (bounded-assignments rest cutoff)
    (all-bounded-assignments rest cutoff)

-- Every actual integer in the list satisfies the independent
-- PrimeFactorisation-based support and exponent-count predicate.
all-encoded-supported
  : (basis : List ℕ) (cutoff : ℕ)
  → All Prime basis → Distinct basis
  → (assignments : List (ExponentAssignment basis))
  → All (Bounded cutoff basis) assignments
  → All (BoundedSmoothInteger basis cutoff)
      (map (encode basis) assignments)
all-encoded-supported basis cutoff primes distinct [] [] = []
all-encoded-supported basis cutoff primes distinct
                      (assignment ∷ assignments) (bounded ∷ bounds) =
  bounded-assignment-gives-supported-integer basis cutoff primes distinct
    assignment bounded
  ∷ all-encoded-supported basis cutoff primes distinct assignments bounds

bounded-integers-supported
  : (basis : List ℕ) (cutoff : ℕ)
  → All Prime basis → Distinct basis
  → All (BoundedSmoothInteger basis cutoff) (bounded-integers basis cutoff)
bounded-integers-supported basis cutoff primes distinct =
  all-encoded-supported basis cutoff primes distinct
    (bounded-assignments basis cutoff)
    (all-bounded-assignments basis cutoff)

-- Membership in the block for one exponent lifts to membership
-- in the flattened list of blocks.
member-in-blocks
  : (rest : List ℕ) (cutoff exponent : ℕ)
  → (tail : ExponentAssignment rest)
  → (options : List ℕ)
  → exponent ∈ options
  → tail ∈ bounded-assignments rest cutoff
  → Any (λ option →
      (exponent , tail) ∈
      map (λ other → option , other)
          (bounded-assignments rest cutoff)) options
member-in-blocks rest cutoff exponent tail (option ∷ options)
                 (here Equality.refl) tail-member =
  here (Membership.∈-map⁺ (λ other → exponent , other) tail-member)
member-in-blocks rest cutoff exponent tail (option ∷ options)
                 (there member) tail-member =
  there (member-in-blocks rest cutoff exponent tail options member tail-member)

bounded-assignment-occurs
  : (basis : List ℕ) (cutoff : ℕ)
  → (assignment : ExponentAssignment basis)
  → Bounded cutoff basis assignment
  → assignment ∈ bounded-assignments basis cutoff
bounded-assignment-occurs [] cutoff tt tt = here Equality.refl
bounded-assignment-occurs (prime ∷ rest) cutoff
                          (exponent , tail) (exp-bound , tail-bound) =
  Membership.∈-concatMap⁺
    (λ index → map (λ other → index , other)
      (bounded-assignments rest cutoff))
    (member-in-blocks rest cutoff exponent tail
      (downFrom cutoff) (Membership.∈-downFrom⁺ exp-bound)
      (bounded-assignment-occurs rest cutoff tail tail-bound))

-- Completeness against the INDEPENDENT factorisation-based predicate.
bounded-smooth-integer-occurs
  : (basis : List ℕ) (cutoff : ℕ)
  → All Prime basis → Distinct basis
  → (number : ℕ) → BoundedSmoothInteger basis cutoff number
  → number ∈ bounded-integers basis cutoff
bounded-smooth-integer-occurs basis cutoff primes distinct number evidence
  with supported-integer-gives-bounded-assignment basis cutoff
    primes distinct number evidence
... | assignment , (encoded-number , bounded) =
  Equality.subst
    (λ value → value ∈ bounded-integers basis cutoff)
    encoded-number
    (Membership.∈-map⁺ (encode basis)
      (bounded-assignment-occurs basis cutoff assignment bounded))

-- The following lemmas identify the source's iterated finite sum with
-- a conventional fold over the explicitly enumerated list of integers.
open import Algebra.Bundles using (CommutativeRing)
import Euler.BoundedArithmeticSums
import Euler.FiniteExpansion

module OverRing {c ℓ} (R : CommutativeRing c ℓ) where
  open CommutativeRing R hiding (zero)
  open import Relation.Binary.Reasoning.Setoid setoid
  open Euler.BoundedArithmeticSums.OverRing R
    using (sum-exponents; sum-assignments)

  -- Fold right over a finite list, with the ring zero at the end.
  sum-list : {A : Set} → List A → (A → Carrier) → Carrier
  sum-list [] f = 0#
  sum-list (value ∷ rest) f = f value + sum-list rest f

  sum-list-cong
    : {A : Set} (items : List A) (f g : A → Carrier)
    → ((item : A) → f item ≈ g item)
    → sum-list items f ≈ sum-list items g
  sum-list-cong [] f g pointwise = refl
  sum-list-cong (value ∷ rest) f g pointwise =
    +-cong (pointwise value) (sum-list-cong rest f g pointwise)

  sum-list-append
    : {A : Set} (left right : List A) (f : A → Carrier)
    → sum-list (left ++ right) f
      ≈ sum-list left f + sum-list right f
  sum-list-append [] right f = sym (+-identityˡ (sum-list right f))
  sum-list-append (value ∷ rest) right f = begin
    f value + sum-list (rest ++ right) f
      ≈⟨ +-congˡ (sum-list-append rest right f) ⟩
    f value + (sum-list rest f + sum-list right f)
      ≈⟨ sym (+-assoc (f value) (sum-list rest f) (sum-list right f)) ⟩
    (f value + sum-list rest f) + sum-list right f
      ∎

  sum-list-map
    : {A B : Set} (items : List A) (g : A → B) (f : B → Carrier)
    → sum-list (map g items) f
      ≈ sum-list items (λ item → f (g item))
  sum-list-map [] g f = refl
  sum-list-map (item ∷ rest) g f =
    +-congˡ (sum-list-map rest g f)

  sum-list-concatMap
    : {A B : Set} (items : List A) (g : A → List B) (f : B → Carrier)
    → sum-list (concatMap g items) f
      ≈ sum-list items (λ item → sum-list (g item) f)
  sum-list-concatMap [] g f = refl
  sum-list-concatMap (item ∷ rest) g f = begin
    sum-list (g item ++ concatMap g rest) f
      ≈⟨ sum-list-append (g item) (concatMap g rest) f ⟩
    sum-list (g item) f + sum-list (concatMap g rest) f
      ≈⟨ +-congˡ (sum-list-concatMap rest g f) ⟩
    sum-list (g item) f
      + sum-list rest (λ other → sum-list (g other) f)
      ∎

  sum-list-downFrom
    : (cutoff : ℕ) (f : ℕ → Carrier)
    → sum-list (downFrom cutoff) f ≈ sum-exponents cutoff f
  sum-list-downFrom zero f = refl
  sum-list-downFrom (suc cutoff) f = begin
    f cutoff + sum-list (downFrom cutoff) f
      ≈⟨ +-congˡ (sum-list-downFrom cutoff f) ⟩
    f cutoff + sum-exponents cutoff f
      ≈⟨ +-comm (f cutoff) (sum-exponents cutoff f) ⟩
    sum-exponents cutoff f + f cutoff
      ≈⟨ refl ⟩
    sum-exponents (suc cutoff) f
      ∎

  -- The list of bounded assignments has precisely the same sum as
  -- the abstract nested-exponent summation, for every possible weight.
  sum-list-assignments
    : (basis : List ℕ) (cutoff : ℕ)
    → (f : ExponentAssignment basis → Carrier)
    → sum-list (bounded-assignments basis cutoff) f
      ≈ sum-assignments basis cutoff f
  sum-list-assignments [] cutoff f = +-identityʳ (f tt)
  sum-list-assignments (prime ∷ rest) cutoff f = begin
    sum-list (bounded-assignments (prime ∷ rest) cutoff) f
      ≈⟨ refl ⟩
    sum-list (concatMap
      (λ exponent → map (λ tail → exponent , tail)
        (bounded-assignments rest cutoff))
      (downFrom cutoff)) f
      ≈⟨ sum-list-concatMap (downFrom cutoff)
            (λ exponent → map (λ tail → exponent , tail)
              (bounded-assignments rest cutoff)) f ⟩
    sum-list (downFrom cutoff)
      (λ exponent → sum-list
        (map (λ tail → exponent , tail)
          (bounded-assignments rest cutoff)) f)
      ≈⟨ sum-list-cong (downFrom cutoff)
           (λ exponent → sum-list
             (map (λ tail → exponent , tail)
               (bounded-assignments rest cutoff)) f)
           (λ exponent → sum-list (bounded-assignments rest cutoff)
             (λ tail → f (exponent , tail)))
           (λ exponent → sum-list-map (bounded-assignments rest cutoff)
             (λ tail → exponent , tail) f) ⟩
    sum-list (downFrom cutoff)
      (λ exponent → sum-list (bounded-assignments rest cutoff)
        (λ tail → f (exponent , tail)))
      ≈⟨ sum-list-cong (downFrom cutoff)
           (λ exponent → sum-list (bounded-assignments rest cutoff)
             (λ tail → f (exponent , tail)))
           (λ exponent → sum-assignments rest cutoff
             (λ tail → f (exponent , tail)))
           (λ exponent → sum-list-assignments rest cutoff
             (λ tail → f (exponent , tail))) ⟩
    sum-list (downFrom cutoff)
      (λ exponent → sum-assignments rest cutoff
        (λ tail → f (exponent , tail)))
      ≈⟨ sum-list-downFrom cutoff
          (λ exponent → sum-assignments rest cutoff
            (λ tail → f (exponent , tail))) ⟩
    sum-assignments (prime ∷ rest) cutoff f
      ∎

  module ForCompletelyMultiplicative
    (coefficient : ℕ → Carrier)
    (coefficient-one : coefficient 1 ≈ 1#)
    (coefficient-times : (left right : ℕ)
      → coefficient (Nat._*_ left right)
        ≈ coefficient left * coefficient right) where

    module Arith = Euler.BoundedArithmeticSums.OverRing R
    open Arith.ForCompletelyMultiplicative
      coefficient coefficient-one coefficient-times
      using (finite-euler-arithmetic-sum)

    open Euler.FiniteExpansion.OverRing R
      using (finite-local-product)

    -- ACTUAL FINITE INTEGER-LIST EULER IDENTITY.
    -- Distinct-prime / support hypotheses are not needed for this equality,
    -- but separately establish that the listed natural numbers are unique
    -- and exactly the bounded smooth integers of the selected prime set.
    finite-euler-integer-list
      : (basis : List ℕ) (cutoff : ℕ)
      → finite-local-product (map coefficient basis) cutoff
        ≈ sum-list (bounded-integers basis cutoff) coefficient
    finite-euler-integer-list basis cutoff = begin
      finite-local-product (map coefficient basis) cutoff
        ≈⟨ finite-euler-arithmetic-sum basis cutoff ⟩
      sum-assignments basis cutoff
        (λ assignment → coefficient (encode basis assignment))
        ≈⟨ sym (sum-list-assignments basis cutoff
            (λ assignment → coefficient (encode basis assignment))) ⟩
      sum-list (bounded-assignments basis cutoff)
        (λ assignment → coefficient (encode basis assignment))
        ≈⟨ sym (sum-list-map (bounded-assignments basis cutoff)
                  (encode basis) coefficient) ⟩
      sum-list (bounded-integers basis cutoff) coefficient
        ∎
