{-# OPTIONS --safe --without-K #-}
module Euler.FiniteIntegerNoDuplicates where

-- The explicitly enumerated bounded Euler-product integers have no
-- repetitions if the selected basis consists of distinct certified primes.
-- This is the final finite-list accounting requirement. Neither numerical
-- testing nor a quotient/set implementation is substituted for uniqueness.

open import Data.Nat.Base using (ℕ; zero; suc; _<_)
import Data.Nat.Properties as NatProperties
open import Data.List.Base
  using (List; []; _∷_; _++_; map; concatMap; downFrom)
open import Data.List.Relation.Unary.All using (All; []; _∷_)
open import Data.Product.Base using (_×_; _,_; proj₁; proj₂)
open import Data.Unit.Base using (⊤; tt)
open import Relation.Binary.PropositionalEquality.Core
  using (_≡_; _≢_; refl; sym; cong)
open import Data.Nat.Primality using (Prime)
open import Euler.PrimeExponentInjectivity
  using (ExponentAssignment; Distinct; encode; prime-exponent-injective)
open import Euler.FiniteIntegerEnumeration
  using (bounded-assignments; bounded-integers; downFrom-bounded; all-append)

-- A normal finite list with pairwise unequal entries. Defined directly
-- to avoid treating a list containing repeated values as a finite set.
NoDuplicates : {A : Set} → List A → Set
NoDuplicates [] = ⊤
NoDuplicates (value ∷ rest) =
  All (λ other → value ≢ other) rest × NoDuplicates rest

-- Natural-number cutoff choices contain every value only once.
all-different-from-limit
  : (values : List ℕ) (cutoff : ℕ)
  → All (λ value → value < cutoff) values
  → All (λ value → cutoff ≢ value) values
all-different-from-limit [] cutoff [] = []
all-different-from-limit (value ∷ values) cutoff
                         (less ∷ less-rest) =
  (λ same → NatProperties.<⇒≢ less (sym same))
  ∷ all-different-from-limit values cutoff less-rest

no-duplicate-downFrom
  : (cutoff : ℕ) → NoDuplicates (downFrom cutoff)
no-duplicate-downFrom zero = tt
no-duplicate-downFrom (suc cutoff) =
  (all-different-from-limit (downFrom cutoff) cutoff
     (downFrom-bounded cutoff) ,
   no-duplicate-downFrom cutoff)

-- Appending unique lists preserves uniqueness when the two lists have
-- explicitly proved pairwise disjoint entries.
no-duplicate-append
  : {A : Set} (left right : List A)
  → NoDuplicates left → NoDuplicates right
  → All (λ value → All (λ other → value ≢ other) right) left
  → NoDuplicates (left ++ right)
no-duplicate-append [] right tt unique-right [] = unique-right
no-duplicate-append (value ∷ rest) right
                    (away-from-rest , unique-rest)
                    unique-right (away-from-right ∷ other-pairs) =
  (all-append (λ other → value ≢ other)
      rest right away-from-rest away-from-right ,
   no-duplicate-append rest right unique-rest unique-right other-pairs)

-- A fixed exponent index is an injective map on tail assignments.
different-fixed-head
  : {T : Set} (exponent : ℕ) (tail : T) (others : List T)
  → All (λ other → tail ≢ other) others
  → All (λ pair → (exponent , tail) ≢ pair)
      (map (λ other → exponent , other) others)
different-fixed-head exponent tail [] [] = []
different-fixed-head exponent tail (other ∷ others)
                     (different ∷ more) =
  (λ equal-pair → different (cong proj₂ equal-pair))
    ∷ different-fixed-head exponent tail others more

no-duplicate-fixed-head
  : {T : Set} (exponent : ℕ) (tails : List T)
  → NoDuplicates tails
  → NoDuplicates (map (λ tail → exponent , tail) tails)
no-duplicate-fixed-head exponent [] tt = tt
no-duplicate-fixed-head exponent (tail ∷ tails) (different , unique) =
  (different-fixed-head exponent tail tails different ,
   no-duplicate-fixed-head exponent tails unique)

-- Different leading exponents always distinguish pairs, regardless
-- of the values of their tail assignments.
different-other-block
  : {T : Set} (exponent : ℕ) (tail : T)
  → (other-exponent : ℕ) (other-tails : List T)
  → exponent ≢ other-exponent
  → All (λ candidate → (exponent , tail) ≢ candidate)
      (map (λ other-tail → other-exponent , other-tail) other-tails)
different-other-block exponent tail other-exponent [] diff = []
different-other-block exponent tail other-exponent (other-tail ∷ other-tails)
                      diff =
  (λ equal-pair → diff (cong proj₁ equal-pair))
    ∷ different-other-block exponent tail other-exponent other-tails diff

different-other-blocks
  : {T : Set} (exponent : ℕ) (tail : T)
  → (other-exponents : List ℕ) (all-tails : List T)
  → All (λ other → exponent ≢ other) other-exponents
  → All (λ candidate → (exponent , tail) ≢ candidate)
      (concatMap (λ other → map (λ t → other , t) all-tails)
        other-exponents)
different-other-blocks exponent tail [] all-tails [] = []
different-other-blocks exponent tail
                       (other ∷ others) all-tails (diff ∷ more) =
  all-append
    (λ candidate → (exponent , tail) ≢ candidate)
    (map (λ t → other , t) all-tails)
    (concatMap (λ index → map (λ t → index , t) all-tails) others)
    (different-other-block exponent tail other all-tails diff)
    (different-other-blocks exponent tail others all-tails more)

different-full-block
  : {T : Set} (exponent : ℕ) (other-exponents : List ℕ)
  → (all-tails first-block-tails : List T)
  → All (λ other → exponent ≢ other) other-exponents
  → All
      (λ item → All (λ candidate → item ≢ candidate)
        (concatMap (λ other → map (λ t → other , t) all-tails)
          other-exponents))
      (map (λ t → exponent , t) first-block-tails)
different-full-block exponent others all-tails [] away = []
different-full-block exponent others all-tails (tail ∷ tails) away =
  different-other-blocks exponent tail others all-tails away
    ∷ different-full-block exponent others all-tails tails away

-- Unique exponent choices × unique tails gives unique tuple enumeration.
no-duplicate-blocks
  : {T : Set} (options : List ℕ) (tails : List T)
  → NoDuplicates options → NoDuplicates tails
  → NoDuplicates
      (concatMap (λ option → map (λ tail → option , tail) tails) options)
no-duplicate-blocks [] tails tt unique-tails = tt
no-duplicate-blocks (option ∷ options) tails
                    (different-options , unique-options) unique-tails =
  no-duplicate-append
    (map (λ tail → option , tail) tails)
    (concatMap (λ index → map (λ tail → index , tail) tails) options)
    (no-duplicate-fixed-head option tails unique-tails)
    (no-duplicate-blocks options tails unique-options unique-tails)
    (different-full-block option options tails tails different-options)

no-duplicate-assignments
  : (basis : List ℕ) (cutoff : ℕ)
  → NoDuplicates (bounded-assignments basis cutoff)
no-duplicate-assignments [] cutoff = [] , tt
no-duplicate-assignments (prime ∷ rest) cutoff =
  no-duplicate-blocks (downFrom cutoff)
    (bounded-assignments rest cutoff)
    (no-duplicate-downFrom cutoff)
    (no-duplicate-assignments rest cutoff)

-- Injective integer encoding transports pairwise distinctness.
encoded-different
  : (basis : List ℕ)
  → All Prime basis → Distinct basis
  → (assignment : ExponentAssignment basis)
  → (others : List (ExponentAssignment basis))
  → All (λ other → assignment ≢ other) others
  → All (λ number → encode basis assignment ≢ number)
      (map (encode basis) others)
encoded-different basis primes distinct assignment [] [] = []
encoded-different basis primes distinct assignment (other ∷ others)
                  (different ∷ more) =
  (λ same-integer →
      different (prime-exponent-injective basis primes distinct
        assignment other same-integer))
    ∷ encoded-different basis primes distinct assignment others more

no-duplicate-encoded
  : (basis : List ℕ)
  → All Prime basis → Distinct basis
  → (assignments : List (ExponentAssignment basis))
  → NoDuplicates assignments
  → NoDuplicates (map (encode basis) assignments)
no-duplicate-encoded basis primes distinct [] tt = tt
no-duplicate-encoded basis primes distinct
                     (assignment ∷ assignments)
                     (different , unique-rest) =
  (encoded-different basis primes distinct assignment assignments different ,
   no-duplicate-encoded basis primes distinct assignments unique-rest)

-- MAIN: A distinct-prime basis produces an honest list of distinct
-- integers. Together with the independent support+completeness results
-- and finite sum theorem, this is a checked finite integer SET sum.
no-duplicate-bounded-integers
  : (basis : List ℕ) (cutoff : ℕ)
  → All Prime basis → Distinct basis
  → NoDuplicates (bounded-integers basis cutoff)
no-duplicate-bounded-integers basis cutoff primes distinct =
  no-duplicate-encoded basis primes distinct
    (bounded-assignments basis cutoff)
    (no-duplicate-assignments basis cutoff)
