{-# OPTIONS --safe --without-K #-}
module Euler.MultiplicativeTwist where

-- The coefficient of a Dirichlet series is not just chi(n): it is
-- chi(n) * n^(-s). This module proves the purely algebraic prerequisite:
-- multiplying two certified completely multiplicative functions produces
-- another completely multiplicative coefficient, and the existing finite
-- Euler theorem applies to that product.
--
-- Weight n^(-s) and its multiplicativity/convergence must be constructed
-- in the eventual complex analytic development. This module does not
-- assume analytic continuation or an infinite Euler product.

open import Algebra.Bundles using (CommutativeRing)
import Data.Nat.Base as Nat
open Nat using (ℕ)
open import Data.List.Base using (List)
open import Euler.DirichletCertificate using (DirichletCharacterCertificate)
import Euler.CharacterExpansion as Expansion

module OverCertifiedCharacter {c ℓ}
  (R : CommutativeRing c ℓ)
  (certificate : DirichletCharacterCertificate R) where

  open CommutativeRing R hiding (zero)

  module WithMultiplicativeWeight
    (weight : ℕ → Carrier)
    (weight-one : weight 1 ≈ 1#)
    (weight-product : (m n : ℕ)
      → weight (Nat._*_ m n) ≈ weight m * weight n) where

    open import Relation.Binary.Reasoning.Setoid setoid
    open DirichletCharacterCertificate certificate
      renaming (value to character; value-one to character-one;
                value-product to character-product)

    -- A commutative-ring interchange, proved from associativity and
    -- commutativity rather than an untrusted symbolic rewrite.
    interchange : (a b c d : Carrier)
      → (a * b) * (c * d) ≈ (a * c) * (b * d)
    interchange a b c d = begin
      (a * b) * (c * d)
        ≈⟨ *-assoc a b (c * d) ⟩
      a * (b * (c * d))
        ≈⟨ *-congˡ (sym (*-assoc b c d)) ⟩
      a * ((b * c) * d)
        ≈⟨ *-congˡ (*-congʳ (*-comm b c)) ⟩
      a * ((c * b) * d)
        ≈⟨ *-congˡ (*-assoc c b d) ⟩
      a * (c * (b * d))
        ≈⟨ sym (*-assoc a c (b * d)) ⟩
      (a * c) * (b * d)
        ∎

    twisted : ℕ → Carrier
    twisted n = character n * weight n

    twisted-one : twisted 1 ≈ 1#
    twisted-one = begin
      character 1 * weight 1
        ≈⟨ *-cong character-one weight-one ⟩
      1# * 1#
        ≈⟨ *-identityˡ 1# ⟩
      1#
        ∎

    twisted-product : (m n : ℕ)
      → twisted (Nat._*_ m n) ≈ twisted m * twisted n
    twisted-product m n = begin
      twisted (Nat._*_ m n)
        ≈⟨ refl ⟩
      character (Nat._*_ m n) * weight (Nat._*_ m n)
        ≈⟨ *-cong (character-product m n) (weight-product m n) ⟩
      (character m * character n) * (weight m * weight n)
        ≈⟨ interchange (character m) (character n)
             (weight m) (weight n) ⟩
      (character m * weight m) * (character n * weight n)
        ≈⟨ refl ⟩
      twisted m * twisted n
        ∎

    module ExpansionRing = Expansion.OverRing R
    module Weighted =
      ExpansionRing.ForCompletelyMultiplicative
        twisted twisted-one twisted-product

    -- A valid finite arithmetic Euler identity for a character times any
    -- genuinely certified multiplicative weight. In particular it becomes
    -- the FINITE Dirichlet-Euler identity when an analytic development has
    -- certified weight(n)=n^(-s).
    finite-weighted-euler
      : (bases : List ℕ) (cutoff : ℕ)
      → Weighted.finite-local-product bases cutoff
        ≈ Weighted.arithmetic-exponent-sum bases cutoff 1
    finite-weighted-euler = Weighted.finite-character-euler-expansion
