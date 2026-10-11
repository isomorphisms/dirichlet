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
import Data.Nat.Properties as NatProperties
open import Relation.Nullary.Decidable using (yes; no)
open import Data.Empty using (⊥-elim)
open Nat using (ℕ; zero; suc)
open import Data.Nat.ListAction using (product)
open import Data.Nat.ListAction.Properties using (product-++)
open import Data.Nat.Primality using (Prime)
open import Data.Nat.Primality.Factorisation
  using (PrimeFactorisation; factorisationUnique)
open import Data.List.Base using (List; []; _∷_; _++_; replicate)
open import Data.List.Relation.Unary.All using (All; []; _∷_)
open import Data.List.Relation.Binary.Permutation.Propositional using (_↭_)
import Data.List.Relation.Binary.Permutation.Propositional as Permutation
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

-- A multiplicity is defined in elementary natural arithmetic, with
-- a decidable equality test. It counts each prime once per repetition,
-- never just once per *distinct* prime.
indicator : ℕ → ℕ → ℕ
indicator key value with NatProperties._≟_ key value
... | yes _ = 1
... | no  _ = 0

multiplicity : ℕ → List ℕ → ℕ
multiplicity key [] = 0
multiplicity key (p ∷ ps) =
  Nat._+_ (indicator key p) (multiplicity key ps)

-- Every permutation preserves the count of every fixed prime.
-- In the swap case this follows from natural-number commutativity;
-- no equality of the *order* of the lists is assumed.
multiplicity-permutation
  : (key : ℕ) → ∀ {xs ys : List ℕ}
  → xs ↭ ys → multiplicity key xs ≡ multiplicity key ys
multiplicity-permutation key Permutation.refl = Eq.refl
multiplicity-permutation key (Permutation.prep p permutation) =
  Eq.cong (Nat._+_ (indicator key p))
    (multiplicity-permutation key permutation)
multiplicity-permutation key
  (Permutation.swap p q {ys = ys} permutation) =
  Eq.trans
    (Eq.cong
      (λ tail-count →
        Nat._+_ (indicator key p)
          (Nat._+_ (indicator key q) tail-count))
      (multiplicity-permutation key permutation))
    (Eq.trans
      (Eq.sym (NatProperties.+-assoc
        (indicator key p) (indicator key q) (multiplicity key ys)))
      (Eq.trans
        (Eq.cong
          (λ first-two → Nat._+_ first-two (multiplicity key ys))
          (NatProperties.+-comm (indicator key p) (indicator key q)))
        (NatProperties.+-assoc
          (indicator key q) (indicator key p) (multiplicity key ys))))
multiplicity-permutation key (Permutation.trans left right) =
  Eq.trans (multiplicity-permutation key left)
           (multiplicity-permutation key right)

-- This exact theorem isolates the arithmetic content of unique prime
-- exponents: whenever two certified prime-power assignments represent
-- the same natural number, every prime occurs with the same multiplicity
-- in their expanded lists. The distinct-base/vector corollary is next.
same-number⇒same-prime-multiplicities
  : (key : ℕ) (left right : List (ℕ × ℕ))
  → All (λ pair → Prime (proj₁ pair)) left
  → All (λ pair → Prime (proj₁ pair)) right
  → prime-power-number left ≡ prime-power-number right
  → multiplicity key (expanded-primes left)
    ≡ multiplicity key (expanded-primes right)
same-number⇒same-prime-multiplicities key left right left-prime right-prime eq =
  multiplicity-permutation key
    (same-number⇒same-prime-multiset
      left right left-prime right-prime eq)

-- The count contribution of a base equal to the chosen prime is 1,
-- and that of a provably different base is zero.
indicator-self : (p : ℕ) → indicator p p ≡ 1
indicator-self p with NatProperties._≟_ p p
... | yes _ = Eq.refl
... | no p≢p = ⊥-elim (p≢p Eq.refl)

indicator-other : (p q : ℕ) → p Eq.≢ q → indicator p q ≡ 0
indicator-other p q p≢q with NatProperties._≟_ p q
... | yes p≡q = ⊥-elim (p≢q p≡q)
... | no _ = Eq.refl

multiplicity-append : (key : ℕ) (xs ys : List ℕ)
  → multiplicity key (xs ++ ys)
    ≡ Nat._+_ (multiplicity key xs) (multiplicity key ys)
multiplicity-append key [] ys = Eq.refl
multiplicity-append key (x ∷ xs) ys =
  Eq.trans
    (Eq.cong (Nat._+_ (indicator key x))
      (multiplicity-append key xs ys))
    (Eq.sym (NatProperties.+-assoc
      (indicator key x) (multiplicity key xs) (multiplicity key ys)))

multiplicity-replicate-self : (p exponent : ℕ)
  → multiplicity p (replicate exponent p) ≡ exponent
multiplicity-replicate-self p zero = Eq.refl
multiplicity-replicate-self p (suc exponent)
  rewrite indicator-self p
        | multiplicity-replicate-self p exponent = Eq.refl

multiplicity-replicate-other : (p q exponent : ℕ)
  → p Eq.≢ q → multiplicity p (replicate exponent q) ≡ 0
multiplicity-replicate-other p q zero different = Eq.refl
multiplicity-replicate-other p q (suc exponent) different
  rewrite indicator-other p q different
        | multiplicity-replicate-other p q exponent different = Eq.refl

-- A base excluded from every input pair never occurs in its
-- expanded prime list. This is independent of primality of the bases.
multiplicity-absent : (p : ℕ) (pairs : List (ℕ × ℕ))
  → All (λ pair → p Eq.≢ proj₁ pair) pairs
  → multiplicity p (expanded-primes pairs) ≡ 0
multiplicity-absent p [] [] = Eq.refl
multiplicity-absent p ((q , exponent) ∷ rest) (p≢q ∷ absent-rest) =
  Eq.trans
    (multiplicity-append p (replicate exponent q) (expanded-primes rest))
    (Eq.trans
      (Eq.cong₂ Nat._+_
        (multiplicity-replicate-other p q exponent p≢q)
        (multiplicity-absent p rest absent-rest))
      Eq.refl)

-- If a prime p occurs once in the *base list*, its exact exponent
-- is recovered by counting p in the expanded factorisation.
multiplicity-head : (p exponent : ℕ) (rest : List (ℕ × ℕ))
  → All (λ pair → p Eq.≢ proj₁ pair) rest
  → multiplicity p (expanded-primes ((p , exponent) ∷ rest)) ≡ exponent
multiplicity-head p exponent rest p-absent =
  Eq.trans
    (multiplicity-append p (replicate exponent p) (expanded-primes rest))
    (Eq.trans
      (Eq.cong₂ Nat._+_
        (multiplicity-replicate-self p exponent)
        (multiplicity-absent p rest p-absent))
      (NatProperties.+-identityʳ exponent))

-- An actual injectivity theorem for one chosen exponent coordinate.
-- The two assignments may have differently ordered *other* primes,
-- but each excludes p. Exact equality of the represented integers
-- forces equality of p's exponents.
same-number⇒same-head-exponent
  : (p left-exponent right-exponent : ℕ)
  → (left-rest right-rest : List (ℕ × ℕ))
  → All (λ pair → Prime (proj₁ pair))
      ((p , left-exponent) ∷ left-rest)
  → All (λ pair → Prime (proj₁ pair))
      ((p , right-exponent) ∷ right-rest)
  → All (λ pair → p Eq.≢ proj₁ pair) left-rest
  → All (λ pair → p Eq.≢ proj₁ pair) right-rest
  → prime-power-number ((p , left-exponent) ∷ left-rest)
    ≡ prime-power-number ((p , right-exponent) ∷ right-rest)
  → left-exponent ≡ right-exponent
same-number⇒same-head-exponent p left-exponent right-exponent
  left-rest right-rest left-primes right-primes
  left-distinct right-distinct eq =
  Eq.trans
    (Eq.sym (multiplicity-head p left-exponent left-rest left-distinct))
    (Eq.trans
      (same-number⇒same-prime-multiplicities p
        ((p , left-exponent) ∷ left-rest)
        ((p , right-exponent) ∷ right-rest)
        left-primes right-primes eq)
      (multiplicity-head p right-exponent right-rest right-distinct))
