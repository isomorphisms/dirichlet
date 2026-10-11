{-# OPTIONS --safe --without-K #-}
module Euler.DistinctPrimeExponentVectors where

-- The finite Euler exponent assignments become injective when the list
-- of bases is certified prime and pairwise distinct. A bounded vector
-- of exponents cannot alias another vector at the same integer.
--
-- The proof is about ALL natural exponents. It uses actual stdlib prime
-- factorisations and a proved multiplicity count; it is not a search,
-- C11 test, numeric comparison, axiom, or unchecked cast.

import Data.Nat.Base as Nat
import Data.Nat.Properties as NatProperties
open Nat using (ℕ; zero; suc)
open import Data.Nat.Primality using (Prime)
open import Data.List.Base as List using (List; []; _∷_; replicate; _++_)
open import Data.List.Relation.Unary.All using (All; []; _∷_)
open import Data.Product.Base using (_×_; _,_; proj₁)
import Data.Vec.Base as Vec
import Relation.Binary.PropositionalEquality as Eq
open Eq using (_≡_; _≢_)
open import Euler.PrimeExponentUniqueness
  using (prime-power-number; expanded-primes;
         same-number⇒same-prime-multiplicities;
         multiplicity; multiplicity-head; multiplicity-append)

-- An actual mathematical predicate, not a Boolean "distinct" flag:
-- every base is proven prime and differs from every subsequent base.
data DistinctPrimeBases : List ℕ → Set where
  empty : DistinctPrimeBases []
  cons : ∀ {p ps}
    → Prime p
    → All (λ q → p ≢ q) ps
    → DistinctPrimeBases ps
    → DistinctPrimeBases (p ∷ ps)

-- Ordered list of (prime, exponent) pairs, with one exponent for every
-- base. The type forces equal lengths and identical prime order.
assignment : (ps : List ℕ) → Vec.Vec ℕ (List.length ps) → List (ℕ × ℕ)
assignment [] Vec.[] = []
assignment (p ∷ ps) (e Vec.∷ es) = (p , e) ∷ assignment ps es

prime-assignment
  : (ps : List ℕ) → DistinctPrimeBases ps
  → (es : Vec.Vec ℕ (List.length ps))
  → All (λ pair → Prime (proj₁ pair)) (assignment ps es)
prime-assignment [] empty Vec.[] = []
prime-assignment (p ∷ ps) (cons prime rest-different rest-prime)
                 (e Vec.∷ es) =
  prime ∷ prime-assignment ps rest-prime es

head-absent-from-tail
  : ∀ {p ps} → All (λ q → p ≢ q) ps
  → (es : Vec.Vec ℕ (List.length ps))
  → All (λ pair → p ≢ proj₁ pair) (assignment ps es)
head-absent-from-tail [] Vec.[] = []
head-absent-from-tail (neq ∷ rest) (e Vec.∷ es) =
  neq ∷ head-absent-from-tail rest es

-- Cancellation here is only ordinary ℕ addition, not an illicit
-- cancellation of a zero coefficient or of a complex Euler factor.
remove-common-head
  : (key p exponent : ℕ) (left right : List ℕ)
  → multiplicity key (replicate exponent p ++ left)
    ≡ multiplicity key (replicate exponent p ++ right)
  → multiplicity key left ≡ multiplicity key right
remove-common-head key p exponent left right full =
  NatProperties.+-cancelˡ-≡
    (multiplicity key (replicate exponent p))
    (multiplicity key left) (multiplicity key right)
    (Eq.trans
      (Eq.sym (multiplicity-append key (replicate exponent p) left))
      (Eq.trans full
        (multiplicity-append key (replicate exponent p) right)))

-- Head recovery is a standalone lemma because Agda's with-expression
-- is elaborated before a branch-local where block becomes available.
head-count-equal
  : (p : ℕ) {ps : List ℕ}
  → All (λ q → p ≢ q) ps
  → (e₁ e₂ : ℕ)
  → (es₁ es₂ : Vec.Vec ℕ (List.length ps))
  → ((key : ℕ)
    → multiplicity key
        (expanded-primes (assignment (p ∷ ps) (e₁ Vec.∷ es₁)))
      ≡ multiplicity key
        (expanded-primes (assignment (p ∷ ps) (e₂ Vec.∷ es₂))))
  → e₁ ≡ e₂
head-count-equal p absent-in-ps e₁ e₂ es₁ es₂ counts =
  Eq.trans
    (Eq.sym
      (multiplicity-head p e₁ (assignment _ es₁)
        (head-absent-from-tail absent-in-ps es₁)))
    (Eq.trans
      (counts p)
      (multiplicity-head p e₂ (assignment _ es₂)
        (head-absent-from-tail absent-in-ps es₂)))

-- For a fixed pairwise-distinct prime basis, equality of *all* prime
-- multiplicity counts forces equality of every exponent coordinate.
multiplicities⇒equal-vectors
  : (ps : List ℕ) → (bases : DistinctPrimeBases ps)
  → (left right : Vec.Vec ℕ (List.length ps))
  → ((key : ℕ)
    → multiplicity key (expanded-primes (assignment ps left))
      ≡ multiplicity key (expanded-primes (assignment ps right)))
  → left ≡ right
multiplicities⇒equal-vectors [] empty Vec.[] Vec.[] counts = Eq.refl
multiplicities⇒equal-vectors (p ∷ ps)
  (cons p-prime absent-in-ps ps-prime)
  (e₁ Vec.∷ es₁) (e₂ Vec.∷ es₂) counts
  with head-count-equal p absent-in-ps e₁ e₂ es₁ es₂ counts
... | Eq.refl =
  Eq.cong (Vec._∷_ e₁)
    (multiplicities⇒equal-vectors ps ps-prime es₁ es₂
      (λ key → remove-common-head key p e₁
        (expanded-primes (assignment ps es₁))
        (expanded-primes (assignment ps es₂))
        (counts key)))

-- This is the injectivity of the entire exponent vector over a fixed
-- distinct-prime basis, not just one coordinate or a prime multiset.
same-number⇒same-exponent-vector
  : (ps : List ℕ) → (bases : DistinctPrimeBases ps)
  → (left right : Vec.Vec ℕ (List.length ps))
  → prime-power-number (assignment ps left)
    ≡ prime-power-number (assignment ps right)
  → left ≡ right
same-number⇒same-exponent-vector ps bases left right same-number =
  multiplicities⇒equal-vectors ps bases left right
    (λ key → same-number⇒same-prime-multiplicities key
      (assignment ps left) (assignment ps right)
      (prime-assignment ps bases left)
      (prime-assignment ps bases right)
      same-number)
