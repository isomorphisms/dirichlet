{-# OPTIONS --safe --without-K #-}
module Euler.PrimeExponentInjectivity where

-- Unique prime-exponent encodings, independent of complex arithmetic.
-- A finite basis must consist of pairwise distinct, certified primes.
-- Exponent assignments are dependent on the length of that basis.
--
-- The output integer is positive: its list of prime factors is obtained
-- by repeating each basis prime the specified number of times.
-- Uniqueness follows from the Agda stdlib's factorisationUnique and
-- an independently proved permutation-invariance of occurrence counts.
--
-- This proves INJECTIVITY, not the surjectivity onto smooth integers
-- needed for the global formal Euler/Dirichlet identity.

open import Data.Nat.Base using (ℕ; zero; suc; _+_; _*_)
import Data.Nat.Properties as NatProperties
open import Data.List.Base using (List; []; _∷_; _++_; replicate)
open import Data.List.Relation.Unary.All using (All; []; _∷_)
open import Data.Nat.ListAction using (product)
open import Data.Nat.ListAction.Properties using (product-++)
open import Data.Nat.Primality using (Prime)
open import Data.Nat.Primality.Factorisation
  using (PrimeFactorisation; factorisationUnique)
open import Data.Product.Base using (_×_; _,_)
open import Data.Unit.Base using (⊤; tt)
open import Data.Empty using (⊥-elim)
open import Relation.Nullary.Decidable using (yes; no)
open import Relation.Binary.PropositionalEquality.Core
  using (_≡_; _≢_; refl; sym; trans; cong; cong₂)
open import Relation.Binary.PropositionalEquality.Properties
  using (module ≡-Reasoning)
import Data.List.Relation.Binary.Permutation.Propositional as Perm

open ≡-Reasoning

-- There is exactly one exponent per basis prime, by construction.
ExponentAssignment : List ℕ → Set
ExponentAssignment [] = ⊤
ExponentAssignment (_ ∷ bases) = ℕ × ExponentAssignment bases

-- Pairwise distinct bases; this condition is separate from primality.
Distinct : List ℕ → Set
Distinct [] = ⊤
Distinct (prime ∷ rest) =
  All (λ other → prime ≢ other) rest × Distinct rest

expanded-primes : (basis : List ℕ) → ExponentAssignment basis → List ℕ
expanded-primes [] tt = []
expanded-primes (prime ∷ rest) (exponent , assignment) =
  replicate exponent prime ++ expanded-primes rest assignment

encode : (basis : List ℕ) → ExponentAssignment basis → ℕ
encode basis assignment = product (expanded-primes basis assignment)

-- The encoder is literally the product of prime powers, not a positional
-- numeral encoding or hash. This lemma makes that interpretation explicit.
natural-power : ℕ → ℕ → ℕ
natural-power base zero = 1
natural-power base (suc exponent) = base * natural-power base exponent

product-replicate : (prime exponent : ℕ)
  → product (replicate exponent prime) ≡ natural-power prime exponent
product-replicate prime zero = refl
product-replicate prime (suc exponent) =
  cong (prime *_) (product-replicate prime exponent)

encode-cons : (prime : ℕ) (rest : List ℕ)
  → (exponent : ℕ) (tail : ExponentAssignment rest)
  → encode (prime ∷ rest) (exponent , tail)
    ≡ natural-power prime exponent * encode rest tail
encode-cons prime rest exponent tail =
  trans (product-++ (replicate exponent prime) (expanded-primes rest tail))
        (cong (_* encode rest tail) (product-replicate prime exponent))

-- Every expanded factor really is prime when the basis entries are prime.
prepend-prime-copies
  : (prime exponent : ℕ) {factors : List ℕ}
  → Prime prime → All Prime factors
  → All Prime (replicate exponent prime ++ factors)
prepend-prime-copies prime zero prime-proof factor-proofs = factor-proofs
prepend-prime-copies prime (suc exponent) prime-proof factor-proofs =
  prime-proof ∷ prepend-prime-copies prime exponent prime-proof factor-proofs

expanded-primes-are-prime
  : (basis : List ℕ) → All Prime basis
  → (assignment : ExponentAssignment basis)
  → All Prime (expanded-primes basis assignment)
expanded-primes-are-prime [] [] tt = []
expanded-primes-are-prime (prime ∷ rest) (prime-proof ∷ rest-proofs)
                            (exponent , tail) =
  prepend-prime-copies prime exponent prime-proof
    (expanded-primes-are-prime rest rest-proofs tail)

-- An occurrence counter with an explicit, decidable equality question.
indicator : ℕ → ℕ → ℕ
indicator target item with NatProperties._≟_ target item
... | yes _ = 1
... | no  _ = 0

count : ℕ → List ℕ → ℕ
count target [] = 0
count target (item ∷ rest) = indicator target item + count target rest

indicator-same : (prime : ℕ) → indicator prime prime ≡ 1
indicator-same prime with NatProperties._≟_ prime prime
... | yes _ = refl
... | no unequal = ⊥-elim (unequal refl)

indicator-other : (target item : ℕ) → target ≢ item
  → indicator target item ≡ 0
indicator-other target item unequal with NatProperties._≟_ target item
... | yes equal = ⊥-elim (unequal equal)
... | no _ = refl

count-append : (target : ℕ) (left right : List ℕ)
  → count target (left ++ right) ≡ count target left + count target right
count-append target [] right = refl
count-append target (item ∷ rest) right = begin
  indicator target item + count target (rest ++ right)
    ≡⟨ cong (indicator target item +_)
           (count-append target rest right) ⟩
  indicator target item + (count target rest + count target right)
    ≡⟨ sym (NatProperties.+-assoc
            (indicator target item) (count target rest) (count target right)) ⟩
  (indicator target item + count target rest) + count target right
    ∎

count-repeated-same : (prime exponent : ℕ)
  → count prime (replicate exponent prime) ≡ exponent
count-repeated-same prime zero = refl
count-repeated-same prime (suc exponent)
  rewrite indicator-same prime
        | count-repeated-same prime exponent = refl

count-repeated-other : (target prime : ℕ)
  → target ≢ prime → (exponent : ℕ)
  → count target (replicate exponent prime) ≡ 0
count-repeated-other target prime unequal zero = refl
count-repeated-other target prime unequal (suc exponent)
  rewrite indicator-other target prime unequal
        | count-repeated-other target prime unequal exponent = refl

-- A prime absent from the basis has zero occurrences in its expansion.
count-outside-basis
  : (target : ℕ) (basis : List ℕ)
  → (assignment : ExponentAssignment basis)
  → All (λ prime → target ≢ prime) basis
  → count target (expanded-primes basis assignment) ≡ 0
count-outside-basis target [] tt [] = refl
count-outside-basis target (prime ∷ rest) (exponent , tail)
                    (unequal ∷ rest-unequal) = begin
  count target (replicate exponent prime ++ expanded-primes rest tail)
    ≡⟨ count-append target (replicate exponent prime)
          (expanded-primes rest tail) ⟩
  count target (replicate exponent prime)
    + count target (expanded-primes rest tail)
    ≡⟨ cong₂ _+_
          (count-repeated-other target prime unequal exponent)
          (count-outside-basis target rest tail rest-unequal) ⟩
  0 + 0
    ≡⟨ refl ⟩
  0 ∎

count-head-prime
  : (prime : ℕ) (rest : List ℕ) (exponent : ℕ)
  → (tail : ExponentAssignment rest)
  → All (λ other → prime ≢ other) rest
  → count prime (expanded-primes (prime ∷ rest) (exponent , tail))
    ≡ exponent
count-head-prime prime rest exponent tail absent = begin
  count prime (replicate exponent prime ++ expanded-primes rest tail)
    ≡⟨ count-append prime (replicate exponent prime)
          (expanded-primes rest tail) ⟩
  count prime (replicate exponent prime)
    + count prime (expanded-primes rest tail)
    ≡⟨ cong₂ _+_
          (count-repeated-same prime exponent)
          (count-outside-basis prime rest tail absent) ⟩
  exponent + 0
    ≡⟨ NatProperties.+-identityʳ exponent ⟩
  exponent ∎

-- Additive commutativity turns a transposition into count equality.
add-swap : (first second remainder : ℕ)
  → first + (second + remainder)
    ≡ second + (first + remainder)
add-swap first second remainder = begin
  first + (second + remainder)
    ≡⟨ sym (NatProperties.+-assoc first second remainder) ⟩
  (first + second) + remainder
    ≡⟨ cong (_+ remainder) (NatProperties.+-comm first second) ⟩
  (second + first) + remainder
    ≡⟨ NatProperties.+-assoc second first remainder ⟩
  second + (first + remainder)
    ∎

count-permutation
  : (target : ℕ) {left right : List ℕ}
  → Perm._↭_ left right → count target left ≡ count target right
count-permutation target Perm.refl = refl
count-permutation target (Perm.prep item permutation) =
  cong (indicator target item +_) (count-permutation target permutation)
count-permutation target (Perm.swap first second permutation) =
  trans
    (cong (λ n → indicator target first + (indicator target second + n))
          (count-permutation target permutation))
    (add-swap (indicator target first) (indicator target second) _)
count-permutation target (Perm.trans first second) =
  trans (count-permutation target first) (count-permutation target second)

-- Count equality for *every* possible prime recovers the complete exponent
-- assignment on a distinct basis. Induction removes one shared prime power
-- from both sides by cancellation in natural addition.
counts-determine-assignment
  : (basis : List ℕ) → Distinct basis
  → (left right : ExponentAssignment basis)
  → ((target : ℕ)
     → count target (expanded-primes basis left)
       ≡ count target (expanded-primes basis right))
  → left ≡ right
counts-determine-assignment [] tt tt tt equal-counts = refl
counts-determine-assignment (prime ∷ rest) (absent , rest-distinct)
                            (left-exponent , left-tail)
                            (right-exponent , right-tail) equal-counts
  with trans (sym (count-head-prime prime rest left-exponent left-tail absent))
             (trans (equal-counts prime)
                    (count-head-prime prime rest right-exponent right-tail absent))
... | refl =
  cong (λ tail → left-exponent , tail)
    (counts-determine-assignment rest rest-distinct left-tail right-tail
       tail-counts)
  where
    tail-counts : (target : ℕ)
      → count target (expanded-primes rest left-tail)
        ≡ count target (expanded-primes rest right-tail)
    tail-counts target =
      NatProperties.+-cancelˡ-≡
        (count target (replicate left-exponent prime))
        (count target (expanded-primes rest left-tail))
        (count target (expanded-primes rest right-tail))
        (trans
          (sym (count-append target (replicate left-exponent prime)
                                  (expanded-primes rest left-tail)))
          (trans (equal-counts target)
                 (count-append target (replicate left-exponent prime)
                                      (expanded-primes rest right-tail))))

-- Main theorem. Any two exponent assignments over the SAME distinct-prime
-- basis producing the same integer are equal. No numerical testing, axiom,
-- postulate or unchecked cast occurs in this module.
prime-exponent-injective
  : (basis : List ℕ) → All Prime basis → Distinct basis
  → (left right : ExponentAssignment basis)
  → encode basis left ≡ encode basis right
  → left ≡ right
prime-exponent-injective basis prime-proofs distinct left right equal-number =
  counts-determine-assignment basis distinct left right
    (λ target → count-permutation target (factorisationUnique left-f right-f))
  where
    left-f : PrimeFactorisation (encode basis left)
    left-f = record
      { factors = expanded-primes basis left
      ; isFactorisation = refl
      ; factorsPrime = expanded-primes-are-prime basis prime-proofs left
      }

    right-f : PrimeFactorisation (encode basis left)
    right-f = record
      { factors = expanded-primes basis right
      ; isFactorisation = equal-number
      ; factorsPrime = expanded-primes-are-prime basis prime-proofs right
      }
