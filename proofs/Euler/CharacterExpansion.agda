{-# OPTIONS --safe --without-K #-}
module Euler.CharacterExpansion where

-- Algebraic finite Euler expansion with the coefficient of each integer
-- recovered from its prime-power exponent tuple. This is stronger than
-- expanding an arbitrary list of formal local ratios: the arithmetic
-- integer attached to a tuple appears explicitly in the RHS.
--
-- No unique-factorization enumeration, primality, analytic convergence,
-- Euler product at an infinite cutoff, or character table verification
-- is assumed or asserted by this theorem.

open import Algebra.Bundles using (CommutativeRing)
import Data.Nat.Base as Nat
open Nat using (ℕ; zero; suc)
open import Data.List.Base using (List; []; _∷_)
open import Geometric.General
import Euler.PrimeFactorWeights as PrimeFactorWeights

module OverRing {c ℓ} (R : CommutativeRing c ℓ) where

  open CommutativeRing R hiding (zero)
  open import Relation.Binary.Reasoning.Setoid setoid
  open Geometric.General.OverCommutativeRing R using (power; geometric)

  -- An ordinary bounded additive sum, evaluated in increasing order.
  finite-sum : (ℕ → Carrier) → ℕ → Carrier
  finite-sum f zero = 0#
  finite-sum f (suc n) = finite-sum f n + f n

  finite-sum-cong
    : (f g : ℕ → Carrier) (n : ℕ)
    → ((k : ℕ) → f k ≈ g k)
    → finite-sum f n ≈ finite-sum g n
  finite-sum-cong f g zero pointwise = refl
  finite-sum-cong f g (suc n) pointwise =
    +-cong (finite-sum-cong f g n pointwise) (pointwise n)

  -- Pull a fixed coefficient and tail through a finite geometric sum.
  -- The proof is purely ring-level: no division by (1-ratio).
  scaled-geometric-sum
    : (scalar ratio tail : Carrier) (n : ℕ)
    → finite-sum (λ k → (scalar * power ratio k) * tail) n
      ≈ (scalar * geometric ratio n) * tail
  scaled-geometric-sum scalar ratio tail zero = begin
    finite-sum (λ k → (scalar * power ratio k) * tail) zero
      ≈⟨ refl ⟩
    0#
      ≈⟨ sym (zeroˡ tail) ⟩
    0# * tail
      ≈⟨ *-congʳ (sym (zeroʳ scalar)) ⟩
    (scalar * 0#) * tail
      ≈⟨ refl ⟩
    (scalar * geometric ratio zero) * tail
      ∎
  scaled-geometric-sum scalar ratio tail (suc n) = begin
    finite-sum (λ k → (scalar * power ratio k) * tail) (suc n)
      ≈⟨ refl ⟩
    finite-sum (λ k → (scalar * power ratio k) * tail) n
      + ((scalar * power ratio n) * tail)
      ≈⟨ +-congʳ (scaled-geometric-sum scalar ratio tail n) ⟩
    ((scalar * geometric ratio n) * tail)
      + ((scalar * power ratio n) * tail)
      ≈⟨ sym (distribʳ tail
                   (scalar * geometric ratio n)
                   (scalar * power ratio n)) ⟩
    ((scalar * geometric ratio n) + (scalar * power ratio n))
      * tail
      ≈⟨ *-congʳ (sym (distribˡ scalar
                           (geometric ratio n)
                           (power ratio n))) ⟩
    (scalar * (geometric ratio n + power ratio n)) * tail
      ≈⟨ refl ⟩
    (scalar * geometric ratio (suc n)) * tail
      ∎

  module ForCompletelyMultiplicative
    (coefficient : ℕ → Carrier)
    (coefficient-one : coefficient 1 ≈ 1#)
    (coefficient-times : (left right : ℕ)
      → coefficient (Nat._*_ left right)
        ≈ coefficient left * coefficient right) where

    module PrimeRing = PrimeFactorWeights.OverRing R
    module Weights =
      PrimeRing.ForCompletelyMultiplicative
        coefficient coefficient-one coefficient-times
    open Weights using (natural-power; coefficient-of-power)

    -- A product of FINITE local geometric factors. The input list is
    -- allowed to contain repeated primes, composites, or 1. The theorem
    -- below is then an identity of a *multiset of exponent assignments*,
    -- not the unrestricted Dirichlet partial sum for integers <= N.
    finite-local-product : List ℕ → ℕ → Carrier
    finite-local-product [] cutoff = 1#
    finite-local-product (p ∷ ps) cutoff =
      geometric (coefficient p) cutoff * finite-local-product ps cutoff

    -- An exponent assignment (k_1,...,k_r) contributes
    --   coefficient(accumulator * p_1^k_1 * ... * p_r^k_r).
    -- The accumulator makes the induction precise and exposes the
    -- *arithmetic integer*, rather than only formal ratio products.
    arithmetic-exponent-sum : List ℕ → ℕ → ℕ → Carrier
    arithmetic-exponent-sum [] cutoff accumulator = coefficient accumulator
    arithmetic-exponent-sum (p ∷ ps) cutoff accumulator =
      finite-sum
        (λ k → arithmetic-exponent-sum ps cutoff
          (Nat._*_ accumulator (natural-power p k)))
        cutoff

    coefficient-at-prime-power
      : (accumulator p exponent : ℕ)
      → coefficient (Nat._*_ accumulator (natural-power p exponent))
        ≈ coefficient accumulator * power (coefficient p) exponent
    coefficient-at-prime-power accumulator p exponent = begin
      coefficient (Nat._*_ accumulator (natural-power p exponent))
        ≈⟨ coefficient-times accumulator (natural-power p exponent) ⟩
      coefficient accumulator * coefficient (natural-power p exponent)
        ≈⟨ *-congˡ (coefficient-of-power p exponent) ⟩
      coefficient accumulator * power (coefficient p) exponent
        ∎

    -- All individual exponent assignments use exactly the coefficient
    -- at the attached integer. Induction proves the finite Euler
    -- product equals that arithmetic sum for arbitrary lists and cutoff.
    arithmetic-exponent-sum-factor
      : (ps : List ℕ) (cutoff accumulator : ℕ)
      → arithmetic-exponent-sum ps cutoff accumulator
        ≈ coefficient accumulator * finite-local-product ps cutoff
    arithmetic-exponent-sum-factor [] cutoff accumulator = begin
      arithmetic-exponent-sum [] cutoff accumulator
        ≈⟨ refl ⟩
      coefficient accumulator
        ≈⟨ sym (*-identityʳ (coefficient accumulator)) ⟩
      coefficient accumulator * 1#
        ≈⟨ refl ⟩
      coefficient accumulator * finite-local-product [] cutoff
        ∎
    arithmetic-exponent-sum-factor (p ∷ ps) cutoff accumulator = begin
      arithmetic-exponent-sum (p ∷ ps) cutoff accumulator
        ≈⟨ refl ⟩
      finite-sum
        (λ k → arithmetic-exponent-sum ps cutoff
          (Nat._*_ accumulator (natural-power p k)))
        cutoff
        ≈⟨ finite-sum-cong
              (λ k → arithmetic-exponent-sum ps cutoff
                (Nat._*_ accumulator (natural-power p k)))
              (λ k → (coefficient accumulator * power (coefficient p) k)
                * finite-local-product ps cutoff)
              cutoff
              (λ k →
                trans
                  (arithmetic-exponent-sum-factor ps cutoff
                    (Nat._*_ accumulator (natural-power p k)))
                  (*-congʳ (coefficient-at-prime-power accumulator p k))) ⟩
      finite-sum
        (λ k → (coefficient accumulator * power (coefficient p) k)
          * finite-local-product ps cutoff)
        cutoff
        ≈⟨ scaled-geometric-sum
              (coefficient accumulator) (coefficient p)
              (finite-local-product ps cutoff) cutoff ⟩
      (coefficient accumulator * geometric (coefficient p) cutoff)
        * finite-local-product ps cutoff
        ≈⟨ *-assoc (coefficient accumulator)
              (geometric (coefficient p) cutoff)
              (finite-local-product ps cutoff) ⟩
      coefficient accumulator
        * (geometric (coefficient p) cutoff * finite-local-product ps cutoff)
        ≈⟨ refl ⟩
      coefficient accumulator * finite-local-product (p ∷ ps) cutoff
        ∎

    finite-character-euler-expansion
      : (ps : List ℕ) (cutoff : ℕ)
      → finite-local-product ps cutoff
        ≈ arithmetic-exponent-sum ps cutoff 1
    finite-character-euler-expansion ps cutoff = begin
      finite-local-product ps cutoff
        ≈⟨ sym (*-identityˡ (finite-local-product ps cutoff)) ⟩
      1# * finite-local-product ps cutoff
        ≈⟨ *-congʳ (sym coefficient-one) ⟩
      coefficient 1 * finite-local-product ps cutoff
        ≈⟨ sym (arithmetic-exponent-sum-factor ps cutoff 1) ⟩
      arithmetic-exponent-sum ps cutoff 1
        ∎
