{-# OPTIONS --safe --without-K #-}
module Euler.PrimeExponentSurjectivity where

-- A constructive converse to prime-exponent injectivity.
-- Given *any* certified factorisation of a positive integer whose
-- prime factors lie in a finite basis, increment the corresponding
-- exponent counters. The resulting prime-power product is the integer.
--
-- This supports genuinely arithmetic smooth integers, defined using
-- independent prime-factorisation evidence rather than "is in the
-- image of encode". Pairwise distinctness is only needed for uniqueness,
-- not for existence of an encoding.
--
-- No unproved axiom, infinite product, number-theoretic approximation
-- or complex analytic continuation is used.

open import Data.Nat.Base using (ℕ; zero; suc; _*_)
import Data.Nat.Properties as NatProperties
open import Data.List.Base using (List; []; _∷_)
open import Data.List.Membership.Propositional using (_∈_)
open import Data.List.Relation.Unary.All using (All; []; _∷_)
open import Data.List.Relation.Unary.Any using (here; there)
open import Data.Nat.Primality using (Prime)
open import Data.Nat.Primality.Factorisation using (PrimeFactorisation)
open import Data.Product.Base using (Σ; _,_)
open import Data.Unit.Base using (tt)
open import Relation.Binary.PropositionalEquality.Core
  using (_≡_; refl; sym; trans; cong)
open import Relation.Binary.PropositionalEquality.Properties
  using (module ≡-Reasoning)
open import Euler.PrimeExponentInjectivity
  using (ExponentAssignment; Distinct; encode; natural-power; encode-cons;
         prime-exponent-injective)

open ≡-Reasoning

zero-exponents : (basis : List ℕ) → ExponentAssignment basis
zero-exponents [] = tt
zero-exponents (_ ∷ rest) = zero , zero-exponents rest

encode-zero-exponents
  : (basis : List ℕ) → encode basis (zero-exponents basis) ≡ 1
encode-zero-exponents [] = refl
encode-zero-exponents (prime ∷ rest) = begin
  encode (prime ∷ rest) (zero , zero-exponents rest)
    ≡⟨ encode-cons prime rest zero (zero-exponents rest) ⟩
  natural-power prime zero * encode rest (zero-exponents rest)
    ≡⟨ refl ⟩
  1 * encode rest (zero-exponents rest)
    ≡⟨ NatProperties.*-identityˡ (encode rest (zero-exponents rest)) ⟩
  encode rest (zero-exponents rest)
    ≡⟨ encode-zero-exponents rest ⟩
  1 ∎

-- Multiply the encoded value by a basis prime by increasing just
-- one exponent. The membership proof chooses the coordinate.
increment-at
  : (basis : List ℕ) {prime : ℕ}
  → prime ∈ basis → ExponentAssignment basis
  → ExponentAssignment basis
increment-at [] ()
increment-at (_ ∷ rest) (here same) (exponent , tail) =
  suc exponent , tail
increment-at (_ ∷ rest) (there member) (exponent , tail) =
  exponent , increment-at rest member tail

multiply-swap
  : (first second remainder : ℕ)
  → first * (second * remainder)
    ≡ second * (first * remainder)
multiply-swap first second remainder = begin
  first * (second * remainder)
    ≡⟨ sym (NatProperties.*-assoc first second remainder) ⟩
  (first * second) * remainder
    ≡⟨ cong (_* remainder) (NatProperties.*-comm first second) ⟩
  (second * first) * remainder
    ≡⟨ NatProperties.*-assoc second first remainder ⟩
  second * (first * remainder) ∎

-- This proof is independent of primality and distinctness:
-- it works for a list of arbitrary natural-number bases.
increment-multiplies
  : (basis : List ℕ) {prime : ℕ}
  → (membership : prime ∈ basis)
  → (assignment : ExponentAssignment basis)
  → encode basis (increment-at basis membership assignment)
    ≡ prime * encode basis assignment
increment-multiplies [] ()
increment-multiplies (prime ∷ rest) (here refl) (exponent , tail) = begin
  encode (prime ∷ rest) (suc exponent , tail)
    ≡⟨ encode-cons prime rest (suc exponent) tail ⟩
  natural-power prime (suc exponent) * encode rest tail
    ≡⟨ refl ⟩
  (prime * natural-power prime exponent) * encode rest tail
    ≡⟨ NatProperties.*-assoc prime (natural-power prime exponent)
          (encode rest tail) ⟩
  prime * (natural-power prime exponent * encode rest tail)
    ≡⟨ cong (prime *_) (sym (encode-cons prime rest exponent tail)) ⟩
  prime * encode (prime ∷ rest) (exponent , tail) ∎
increment-multiplies (head ∷ rest) {prime = prime}
                      (there membership) (exponent , tail) = begin
  encode (head ∷ rest) (exponent , increment-at rest membership tail)
    ≡⟨ encode-cons head rest exponent (increment-at rest membership tail) ⟩
  natural-power head exponent * encode rest (increment-at rest membership tail)
    ≡⟨ cong (natural-power head exponent *_) 
         (increment-multiplies rest membership tail) ⟩
  natural-power head exponent * (prime * encode rest tail)
    ≡⟨ multiply-swap (natural-power head exponent) prime (encode rest tail) ⟩
  prime * (natural-power head exponent * encode rest tail)
    ≡⟨ cong (prime *_) (sym (encode-cons head rest exponent tail)) ⟩
  prime * encode (head ∷ rest) (exponent , tail) ∎

-- An independently supplied list of factors, each accompanied by a
-- membership proof in the basis, constructs an exponent assignment.
assignment-from-supported-factors
  : (basis factors : List ℕ)
  → All (λ prime → prime ∈ basis) factors
  → ExponentAssignment basis
assignment-from-supported-factors basis [] [] = zero-exponents basis
assignment-from-supported-factors basis (prime ∷ factors)
                                  (member ∷ supported) =
  increment-at basis member
    (assignment-from-supported-factors basis factors supported)

-- The constructed assignment encodes the exact product of the factors.
assignment-encodes-factor-product
  : (basis factors : List ℕ)
  → (supported : All (λ prime → prime ∈ basis) factors)
  → encode basis (assignment-from-supported-factors basis factors supported)
    ≡ Data.Nat.ListAction.product factors
assignment-encodes-factor-product basis [] [] =
  encode-zero-exponents basis
assignment-encodes-factor-product basis (prime ∷ factors)
                                  (member ∷ supported) = begin
  encode basis
    (increment-at basis member
      (assignment-from-supported-factors basis factors supported))
    ≡⟨ increment-multiplies basis member
          (assignment-from-supported-factors basis factors supported) ⟩
  prime * encode basis (assignment-from-supported-factors basis factors supported)
    ≡⟨ cong (prime *_) (assignment-encodes-factor-product basis factors supported) ⟩
  prime * Data.Nat.ListAction.product factors
    ≡⟨ refl ⟩
  Data.Nat.ListAction.product (prime ∷ factors) ∎

-- Constructive surjectivity onto the independently characterized
-- positive integers having a certified factorisation supported in
-- the chosen finite basis. It does not use surjectivity as a premise.
encode-supported-factorisation
  : (basis : List ℕ) (number : ℕ)
  → (factorisation : PrimeFactorisation number)
  → (supported :
        All (λ prime → prime ∈ basis)
            (PrimeFactorisation.factors factorisation))
  → Σ (ExponentAssignment basis) (λ assignment → encode basis assignment ≡ number)
encode-supported-factorisation basis number factorisation supported =
  assignment ,
  trans (assignment-encodes-factor-product basis
           (PrimeFactorisation.factors factorisation) supported)
        (sym (PrimeFactorisation.isFactorisation factorisation))
  where
    assignment : ExponentAssignment basis
    assignment =
      assignment-from-supported-factors basis
        (PrimeFactorisation.factors factorisation) supported

-- Together with the previous module's injectivity theorem, the
-- reconstructed assignment is the UNIQUE encoding of the number
-- over a distinct-prime basis.
unique-supported-assignment
  : (basis : List ℕ) → All Prime basis → Distinct basis
  → (number : ℕ)
  → (factorisation : PrimeFactorisation number)
  → (supported :
        All (λ prime → prime ∈ basis)
            (PrimeFactorisation.factors factorisation))
  → (candidate : ExponentAssignment basis)
  → encode basis candidate ≡ number
  → candidate ≡
      assignment-from-supported-factors basis
        (PrimeFactorisation.factors factorisation) supported
unique-supported-assignment basis primes distinct number factorisation
                            supported candidate candidate-encodes =
  prime-exponent-injective basis primes distinct candidate reconstructed
    (trans candidate-encodes (sym reconstructed-encodes))
  where
    reconstructed : ExponentAssignment basis
    reconstructed =
      assignment-from-supported-factors basis
        (PrimeFactorisation.factors factorisation) supported

    reconstructed-encodes : encode basis reconstructed ≡ number
    reconstructed-encodes =
      trans (assignment-encodes-factor-product basis
               (PrimeFactorisation.factors factorisation) supported)
            (sym (PrimeFactorisation.isFactorisation factorisation))
