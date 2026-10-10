{-# OPTIONS --safe --without-K #-}
module Geometric.Finite where

-- Agda reference proof, in the exact integers. No postulates, holes,
-- floating-point arithmetic, or assumptions about convergence.
--
-- The universal commutative-ring generalization is a separate target:
-- this file proves the identity for all integers q and all natural N.

open import Data.Nat.Base using (ℕ; zero; suc)
open import Data.Integer using (ℤ; +_; -_; _+_; _-_; _*_)
open import Data.List.Base using (_∷_; [])
open import Relation.Binary.PropositionalEquality
  using (_≡_; refl; cong; module ≡-Reasoning)
open import Data.Integer.Tactic.RingSolver using (solve)

open ≡-Reasoning

-- q^0=1, q^(N+1)=q*q^N.
power : ℤ → ℕ → ℤ
power ratio zero = + 1
power ratio (suc count) = ratio * power ratio count

-- G(0,q)=0; G(N+1,q)=G(N,q)+q^N.
-- Unlike (1-q^N)/(1-q), this polynomial is defined at q=1.
geometric : ℤ → ℕ → ℤ
geometric ratio zero = + 0
geometric ratio (suc count) =
  geometric ratio count + power ratio count

-- The finite identity is an *equality type*, established for every ratio
-- and every count by induction. The solver only discharges ring algebra;
-- it does not supply the induction hypothesis.
finite-geometric
  : (ratio : ℤ) (count : ℕ)
  → ((+ 1 - ratio) * geometric ratio count)
    ≡ (+ 1 - power ratio count)
finite-geometric ratio zero = solve (ratio ∷ [])
finite-geometric ratio (suc count) = begin
  (+ 1 - ratio) * geometric ratio (suc count)
    ≡⟨⟩
  (+ 1 - ratio) * (geometric ratio count + power ratio count)
    ≡⟨ solve (ratio ∷ geometric ratio count ∷ power ratio count ∷ []) ⟩
  ((+ 1 - ratio) * geometric ratio count)
    + ((+ 1 - ratio) * power ratio count)
    ≡⟨ cong
         (λ left → left + ((+ 1 - ratio) * power ratio count))
         (finite-geometric ratio count) ⟩
  (+ 1 - power ratio count)
    + ((+ 1 - ratio) * power ratio count)
    ≡⟨ solve (ratio ∷ power ratio count ∷ []) ⟩
  + 1 - (ratio * power ratio count)
    ≡⟨⟩
  + 1 - power ratio (suc count)
    ∎

-- Closed sanity witnesses also exercise the removable q=1 point.
at-one-four : geometric (+ 1) 4 ≡ + 4
at-one-four = refl

at-negative-one-four : geometric (- (+ 1)) 4 ≡ + 0
at-negative-one-four = refl

at-two-four : geometric (+ 2) 4 ≡ + 15
at-two-four = refl
