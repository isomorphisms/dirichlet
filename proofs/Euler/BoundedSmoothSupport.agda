{-# OPTIONS --safe --without-K #-}
module Euler.BoundedSmoothSupport where

-- A bounded, finite-prime arithmetic indexing domain characterised
-- INDEPENDENTLY of the Euler-product exponent enumeration.
--
-- Given a basis of distinct certified primes, a natural number n belongs
-- to this domain iff it has a certified factorisation using only basis
-- primes and no basis prime occurs cutoff or more times.
--
-- The constructive forward/backward theorems below establish existence
-- and uniqueness of its bounded exponent representation. They use prime
-- factorisation, counting and arithmetic, not complex analytic limits.

open import Data.Nat.Base using (ℕ; zero; suc; _<_ ; _+_)
open import Data.List.Base using (List; []; _∷_; _++_; replicate)
open import Data.List.Relation.Unary.All using (All; []; _∷_)
open import Data.List.Membership.Propositional using (_∈_)
open import Data.List.Relation.Unary.Any using (here; there)
open import Data.Nat.Primality using (Prime)
open import Data.Nat.Primality.Factorisation
  using (PrimeFactorisation; factorisationUnique)
open import Data.Product.Base using (Σ; _×_; _,_; proj₁)
open import Data.Unit.Base using (⊤; tt)
open import Relation.Binary.PropositionalEquality.Core
  using (_≡_; _≢_; refl; sym; trans)
import Relation.Binary.PropositionalEquality as Equality

open import Euler.PrimeExponentInjectivity
  using (ExponentAssignment; Distinct; expanded-primes; encode;
         count; count-append; count-repeated-other; count-head-prime;
         count-permutation; expanded-primes-are-prime;
         prime-exponent-injective)
open import Euler.PrimeExponentSurjectivity
  using (encode-supported-factorisation)

-- One strict exponent bound for every position in the basis.
-- This definition is indexed by the actual exponent assignment.
Bounded : (cutoff : ℕ) (basis : List ℕ)
  → ExponentAssignment basis → Set
Bounded cutoff [] tt = ⊤
Bounded cutoff (prime ∷ rest) (exponent , tail) =
  (exponent < cutoff) × Bounded cutoff rest tail

-- Independent description: the prime factorisation of an integer n
-- has no factor outside the supplied basis, and its multiplicity at
-- each basis prime is strictly smaller than cutoff.
BoundedSmoothInteger : (basis : List ℕ) (cutoff number : ℕ) → Set
BoundedSmoothInteger basis cutoff number =
  Σ (PrimeFactorisation number)
    (λ factorisation →
      All (λ prime → prime ∈ basis)
          (PrimeFactorisation.factors factorisation)
      ×
      All (λ prime →
        count prime (PrimeFactorisation.factors factorisation) < cutoff)
          basis)

-- Counting another basis prime does not change when the new head prime
-- is inserted with an arbitrary exponent.
count-past-other-prime
  : (head target : ℕ) (rest : List ℕ)
  → (exponent : ℕ) (tail : ExponentAssignment rest)
  → head ≢ target
  → count target (expanded-primes (head ∷ rest) (exponent , tail))
    ≡ count target (expanded-primes rest tail)
count-past-other-prime head target rest exponent tail different =
  trans
    (count-append target (replicate exponent head)
       (expanded-primes rest tail))
    (trans
      (Equality.cong
        (λ count-head → count-head +
          count target (expanded-primes rest tail))
        (count-repeated-other target head
           (λ same → different (sym same)) exponent))
      refl)
 

-- Produce an equality of occurrence counts for each target different
-- from head. The stored tail assignment is fixed while we traverse
-- the list of target primes.
count-equalities-after-new-head
  : (head : ℕ) (rest : List ℕ)
  → (exponent : ℕ) (tail : ExponentAssignment rest)
  → (targets : List ℕ)
  → All (λ target → head ≢ target) targets
  → All (λ target →
       count target (expanded-primes (head ∷ rest) (exponent , tail))
       ≡ count target (expanded-primes rest tail)) targets
count-equalities-after-new-head head rest exponent tail [] [] = []
count-equalities-after-new-head head rest exponent tail
                               (target ∷ targets) (different ∷ others) =
  count-past-other-prime head target rest exponent tail different
    ∷ count-equalities-after-new-head head rest exponent tail targets others

reverse-count-equalities
  : (targets : List ℕ) (left right : List ℕ)
  → All (λ target → count target left ≡ count target right) targets
  → All (λ target → count target right ≡ count target left) targets
reverse-count-equalities [] left right [] = []
reverse-count-equalities (target ∷ targets) left right (eq ∷ rest) =
  sym eq ∷ reverse-count-equalities targets left right rest

-- Transfer a bound along certified equality of occurrence counts.
transfer-count-bounds
  : (targets : List ℕ) (cutoff : ℕ)
  → (left right : List ℕ)
  → All (λ target → count target left ≡ count target right) targets
  → All (λ target → count target right < cutoff) targets
  → All (λ target → count target left < cutoff) targets
transfer-count-bounds [] cutoff left right [] [] = []
transfer-count-bounds (target ∷ targets) cutoff left right
                      (equal-count ∷ rest-equalities)
                      (bounded-count ∷ rest-bounds) =
  Equality.subst (λ value → value < cutoff) (sym equal-count) bounded-count
    ∷ transfer-count-bounds targets cutoff left right
          rest-equalities rest-bounds

-- Conversely, an explicit exponent bound proves that the independently
-- defined occurrence-count bound holds at every selected basis prime.
bounds-imply-count-bounds
  : (basis : List ℕ) (cutoff : ℕ) → Distinct basis
  → (assignment : ExponentAssignment basis)
  → Bounded cutoff basis assignment
  → All (λ target →
      count target (expanded-primes basis assignment) < cutoff) basis
bounds-imply-count-bounds [] cutoff tt tt tt = []
bounds-imply-count-bounds (head ∷ rest) cutoff
                          (distinct-head , distinct-rest)
                          (exponent , tail) (bounded-head , bounded-tail) =
  Equality.subst (λ value → value < cutoff)
    (sym (count-head-prime head rest exponent tail distinct-head))
    bounded-head
  ∷
  transfer-count-bounds rest cutoff
    (expanded-primes (head ∷ rest) (exponent , tail))
    (expanded-primes rest tail)
    (count-equalities-after-new-head head rest exponent tail
       rest distinct-head)
    (bounds-imply-count-bounds rest cutoff distinct-rest tail bounded-tail)

-- Recover every exponent bound from the independently stated count bounds
-- (using the distinctness of the basis primes).
count-bounds-imply-bounds
  : (basis : List ℕ) (cutoff : ℕ) → Distinct basis
  → (assignment : ExponentAssignment basis)
  → All (λ target →
      count target (expanded-primes basis assignment) < cutoff) basis
  → Bounded cutoff basis assignment
count-bounds-imply-bounds [] cutoff tt tt [] = tt
count-bounds-imply-bounds (head ∷ rest) cutoff
                          (distinct-head , distinct-rest)
                          (exponent , tail) (bounded-head ∷ bounded-rest) =
  Equality.subst (λ value → value < cutoff)
    (count-head-prime head rest exponent tail distinct-head)
    bounded-head
  ,
  count-bounds-imply-bounds rest cutoff distinct-rest tail
    (transfer-count-bounds rest cutoff
      (expanded-primes rest tail)
      (expanded-primes (head ∷ rest) (exponent , tail))
      (reverse-count-equalities rest
        (expanded-primes (head ∷ rest) (exponent , tail))
        (expanded-primes rest tail)
        (count-equalities-after-new-head head rest exponent tail
          rest distinct-head))
      bounded-rest)

-- Construct factor membership proofs, not merely a list of factors.
raise-membership
  : (head : ℕ) (rest factors : List ℕ)
  → All (λ factor → factor ∈ rest) factors
  → All (λ factor → factor ∈ (head ∷ rest)) factors
raise-membership head rest [] [] = []
raise-membership head rest (factor ∷ factors) (member ∷ others) =
  there member ∷ raise-membership head rest factors others

repeat-member
  : (head exponent : ℕ) (rest factors : List ℕ)
  → All (λ factor → factor ∈ (head ∷ rest)) factors
  → All (λ factor → factor ∈ (head ∷ rest))
      (replicate exponent head ++ factors)
repeat-member head zero rest factors supporting = supporting
repeat-member head (suc exponent) rest factors supporting =
  here refl ∷ repeat-member head exponent rest factors supporting

expanded-supported
  : (basis : List ℕ) (assignment : ExponentAssignment basis)
  → All (λ factor → factor ∈ basis)
        (expanded-primes basis assignment)
expanded-supported [] tt = []
expanded-supported (head ∷ rest) (exponent , tail) =
  repeat-member head exponent rest (expanded-primes rest tail)
    (raise-membership head rest (expanded-primes rest tail)
       (expanded-supported rest tail))

-- Every bounded exponent tuple produces an integer satisfying the
-- INDEPENDENT prime-factor and occurrence-count characterization.
bounded-assignment-gives-supported-integer
  : (basis : List ℕ) (cutoff : ℕ)
  → All Prime basis → Distinct basis
  → (assignment : ExponentAssignment basis)
  → Bounded cutoff basis assignment
  → BoundedSmoothInteger basis cutoff (encode basis assignment)
bounded-assignment-gives-supported-integer basis cutoff primes distinct
                                           assignment bounded =
  factorisation ,
    (expanded-supported basis assignment ,
     bounds-imply-count-bounds basis cutoff distinct assignment bounded)
  where
    factorisation : PrimeFactorisation (encode basis assignment)
    factorisation = record
      { factors = expanded-primes basis assignment
      ; isFactorisation = refl
      ; factorsPrime = expanded-primes-are-prime basis primes assignment
      }

-- Every independently described bounded smooth integer has a bounded
-- exponent assignment.  Construct it from the supplied factorisation,
-- then transfer its counting bounds through unique factorisation.
supported-integer-gives-bounded-assignment
  : (basis : List ℕ) (cutoff : ℕ)
  → All Prime basis → Distinct basis
  → (number : ℕ)
  → BoundedSmoothInteger basis cutoff number
  → Σ (ExponentAssignment basis)
       (λ assignment →
          (encode basis assignment ≡ number)
          × Bounded cutoff basis assignment)
supported-integer-gives-bounded-assignment basis cutoff primes distinct
  number (factorisation , (supported , bounded-counts))
  with encode-supported-factorisation basis number factorisation supported
... | assignment , encoded-equals-number =
  assignment ,
    (encoded-equals-number ,
     count-bounds-imply-bounds basis cutoff distinct assignment
       (transfer-count-bounds basis cutoff
         (expanded-primes basis assignment)
         (PrimeFactorisation.factors factorisation)
         (counts-equal assignment encoded-equals-number)
         bounded-counts))
  where
    counts-equal
      : (assignment : ExponentAssignment basis)
      → encode basis assignment ≡ number
      → All (λ target →
          count target (expanded-primes basis assignment)
          ≡ count target (PrimeFactorisation.factors factorisation))
          basis
    counts-equal assignment encoded-equals-number =
      equal-for-basis basis
      where
        encoded-factorisation : PrimeFactorisation number
        encoded-factorisation = record
          { factors = expanded-primes basis assignment
          ; isFactorisation = sym encoded-equals-number
          ; factorsPrime = expanded-primes-are-prime basis primes assignment
          }

        equal-for-basis
          : (targets : List ℕ)
          → All (λ target →
              count target (expanded-primes basis assignment)
              ≡ count target (PrimeFactorisation.factors factorisation))
              targets
        equal-for-basis [] = []
        equal-for-basis (target ∷ targets) =
          count-permutation target
            (factorisationUnique encoded-factorisation factorisation)
            ∷ equal-for-basis targets

-- A second encoding for the same integer cannot differ, whether its
-- exponent bounds are available or not. This establishes uniqueness
-- of the bounded representation returned by the preceding theorem.
supported-integer-encoding-unique
  : (basis : List ℕ) → All Prime basis → Distinct basis
  → (number : ℕ)
  → (left right : ExponentAssignment basis)
  → encode basis left ≡ number
  → encode basis right ≡ number
  → left ≡ right
supported-integer-encoding-unique basis primes distinct number
                                  left right left-equal right-equal =
  prime-exponent-injective basis primes distinct left right
    (trans left-equal (sym right-equal))
