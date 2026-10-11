{-# OPTIONS --safe --without-K #-}
module Euler.PrimeExponentUniqueness where

-- A certified bridge from bounded prime-exponent assignments to the
-- standard library's uniqueness-of-prime-factorisation theorem.
--
-- This proves equality of expanded PRIME MULTISETS whenever their
-- represented integers are equal. It deliberately does not yet state
-- injection of ordered exponent vectors: that additional corollary
-- needs distinct prime bases and counting repeated elements.

import Data.Nat.Base as Nat
open Nat using (ℕ; zero; suc)
open import Data.Nat.ListAction using (product)
open import Data.Nat.ListAction.Properties using (product-++)
open import Data.Nat.Primality using (Prime)
open import Data.Nat.Primality.Factorisation
  using (PrimeFactorisation; factorisationUnique)
open import Data.List.Base using (List; []; _∷_; _++_; replicate)
open import Data.List.Relation.Unary.All using (All; []; _∷_)
open import Data.List.Relation.Binary.Permutation.Propositional using (_↭_)
open import Data.Product.Base using (_×_; _,_; proj₁)
import Relation.Binary.PropositionalEquality as Eq
open Eq using (_≡_)

-- Prime-exponent assignments are represented by a finite list of
-- (base,exponent) pairs. No distinctness is presumed at this layer.
prime-power-number : List (ℕ × ℕ) → ℕ
prime-power-number [] = 1
prime-power-number ((p , exponent) ∷ rest) =
  Nat._*_ (Nat._^_ p exponent) (prime-power-number rest)

-- The expanded list contains exactly e copies of p for each (p,e).
expanded-primes : List (ℕ × ℕ) → List ℕ
expanded-primes [] = []
expanded-primes ((p , exponent) ∷ rest) =
  replicate exponent p ++ expanded-primes rest

product-of-replicate : (p exponent : ℕ)
  → product (replicate exponent p) ≡ Nat._^_ p exponent
product-of-replicate p zero = Eq.refl
product-of-replicate p (suc exponent) =
  Eq.cong (Nat._*_ p) (product-of-replicate p exponent)

-- Invariant that connects the expanded list and the represented
-- arithmetic integer. This proof works even for zero exponents.
product-of-expanded-primes : (ps : List (ℕ × ℕ))
  → product (expanded-primes ps) ≡ prime-power-number ps
product-of-expanded-primes [] = Eq.refl
product-of-expanded-primes ((p , exponent) ∷ rest) =
  Eq.trans
    (product-++ (replicate exponent p) (expanded-primes rest))
    (Eq.cong₂ Nat._*_
       (product-of-replicate p exponent)
       (product-of-expanded-primes rest))

-- A corresponding proof that every element of the expanded list is
-- prime, supplied only when the original bases carry prime witnesses.
all-append : ∀ {xs ys : List ℕ}
  → All Prime xs → All Prime ys → All Prime (xs ++ ys)
all-append [] all-ys = all-ys
all-append (p-prime ∷ all-xs) all-ys =
  p-prime ∷ all-append all-xs all-ys

all-replicate : (p exponent : ℕ)
  → Prime p → All Prime (replicate exponent p)
all-replicate p zero p-prime = []
all-replicate p (suc exponent) p-prime =
  p-prime ∷ all-replicate p exponent p-prime

all-expanded : (ps : List (ℕ × ℕ))
  → All (λ pair → Prime (proj₁ pair)) ps
  → All Prime (expanded-primes ps)
all-expanded [] [] = []
all-expanded ((p , exponent) ∷ rest) (p-prime ∷ rest-prime) =
  all-append (all-replicate p exponent p-prime)
             (all-expanded rest rest-prime)

-- No invented "unique factorisation" axiom: this is an actual
-- standard-library PrimeFactorisation certificate, constructed from
-- the prime bases, exponent expansion and equality proved above.
factorisation-of-assignment
  : (ps : List (ℕ × ℕ))
  → All (λ pair → Prime (proj₁ pair)) ps
  → PrimeFactorisation (prime-power-number ps)
factorisation-of-assignment ps primes = record
  { factors = expanded-primes ps
  ; isFactorisation = Eq.sym (product-of-expanded-primes ps)
  ; factorsPrime = all-expanded ps primes
  }

-- Standard-library uniqueness applies to two index-equal certified
-- prime factorizations. Equality transport is only on natural indices;
-- no untrusted cast or assumed theorem is involved.
factorisation-permutation
  : ∀ {m n} (same-number : m ≡ n)
  → (first : PrimeFactorisation m)
  → (second : PrimeFactorisation n)
  → PrimeFactorisation.factors first
    ↭ PrimeFactorisation.factors second
factorisation-permutation Eq.refl first second =
  factorisationUnique first second

-- A real partial step toward unique exponent enumeration:
-- equal arithmetic numbers have identical prime MULTISETS.
same-number⇒same-prime-multiset
  : (left right : List (ℕ × ℕ))
  → All (λ pair → Prime (proj₁ pair)) left
  → All (λ pair → Prime (proj₁ pair)) right
  → prime-power-number left ≡ prime-power-number right
  → expanded-primes left ↭ expanded-primes right
same-number⇒same-prime-multiset left right left-prime right-prime same-number =
  factorisation-permutation same-number
    (factorisation-of-assignment left left-prime)
    (factorisation-of-assignment right right-prime)
