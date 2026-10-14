# From Dirichlet characters to a finite Euler expansion

This is the proof boundary after draft character generator
[PR #12](https://github.com/isomorphisms/dirichlet/pull/12) and the
previous Agda proof chain [#1](https://github.com/isomorphisms/dirichlet/pull/1),
[#3](https://github.com/isomorphisms/dirichlet/pull/3), and
[#4](https://github.com/isomorphisms/dirichlet/pull/4).

## What Agda proves in this branch

All Agda files are checked under Agda 2.8.0 and stdlib 2.3, with
`--safe --without-K`; code still needs that exact CI evidence at its
final commit before anyone calls the proof verified.

`Euler.CharacterExpansion` works over an arbitrary commutative ring
R, with coefficient `a : ℕ → R` equipped with *supplied proofs*
of `a(1)=1` and `a(m*n)=a(m)*a(n)`. It constructs two distinct
finite expressions:

1. A product of finite geometric factors, for any finite integer
   list `[p₁,...,pᵣ]` and natural cutoff `K`:
   `∏ⱼ ∑_{k=0}^{K-1} a(pⱼ)^k`.
2. A nested sum over the same bounded exponent tuples, with the
   *arithmetic coefficient* at the actual associated integer:
   `∑_{0≤eⱼ<K} a(∏ⱼ pⱼ^{eⱼ})`.

The theorem
`finite-character-euler-expansion` proves they are equal **in R's
setoid equality**. Its strengthened accumulator induction shows
`arithmetic-exponent-sum ps K n =
a(n) * finite-local-product ps K`, and uses the separately proved
prime-power coefficient lemma from `PrimeFactorWeights`.

This equality holds even if the input list repeats a prime or contains
composites. In that case repeated exponent assignments can represent
the *same* integer: this is an exponent-tuple sum, **not** a Dirichlet
partial sum over distinct n. The proof does not silently claim that
every integer appears exactly once.

`Euler.DirichletCertificate` defines the actual requirements of a
character over R: a positive modulus, normalization at 1,
complete multiplicativity, periodicity with that modulus, and vanishing
on non-units (defined using gcd). Supplying a mathematical proof of
all these fields allows the finite Euler theorem to be instantiated.
This Agda module also proves that at any integer not coprime to the
modulus, each nonempty finite local geometric factor has value 1.

## A constructed character, not a postulated one

`Euler.TrivialCharacter` supplies a complete certificate for the genuine
modulus-one character χ₁(n)=1 over an arbitrary commutative ring. Its
nonunit-support obligation follows from `gcd(n,1)=1`, and its
multiplicativity from the ring's identity law. Thus
`finite-trivial-character-euler` is an actual specialization of
the finite arithmetic identity without an unproved character field.
This is the finite geometric precursor to ζ; no infinite analytic
claim follows from the certificate.

## How the C11/JS-generated characters are related, and what is missing

The generator in draft #12 emits `q`, a root-of-unity denominator
`D`, and exact integer phase exponents `phase[r]` for the q residue
classes. It verifies phase addition under multiplication numerically
*as finite integer arithmetic*, not as an Agda theorem. The next
independent proof needs a **checked certificate**:

- q>0 and D>0, with each residue either a nonunit/-1 or a unit
  phase in [0,D);
- normalization `phase[1 mod q]=0`;
- for every pair of unit residues a,b, the phase at ab mod q agrees
  with `(phase[a]+phase[b]) mod D`;
- nonunits multiply to nonunits, and support is exactly the unit group;
- the phase table is periodic for all natural inputs, not only for
  machine unsigned integers;
- the root-of-unity interpretation in a genuine coefficient ring
  maps phase addition to ring multiplication.

A host test reporting `PASS` does not fill the Agda proof fields.
A future import should first certify finite natural residue tables in
Agda/Rocq, then obtain infinite-natural periodic and multiplicative
laws from modular arithmetic, then map exact root-of-unity exponents
into an appropriate ring. Avoid turning finite-precision `cos` and
`sin` values into supposed proofs of equality.

## What still separates this from the global Euler product

For a list of **distinct primes**, the unique-factorization theorem
can show that exponent tuples represent distinct integers whose prime
divisors belong to that list. A separate enumeration theorem is
needed to turn this into a sum over those integers. Taking the list
and exponents to infinity additionally needs control of absolute
convergence when Re(s)>1, with weights `χ(n)n^{-s}`. The finite
algebraic theorem alone does not establish a complex analytic limit
or continuation outside the convergence half-plane.

Agda is the currently qualified reference proof checker. Idriç is
the intended later proof destination only when its compiler/backend
can typecheck the relevant ring laws. The specialized mathematics
belongs in Dirichlet or its proof systems, not in the general-purpose
Idriç language core.

## Work-control boundary

This is a draft stacked on PR #4, separate from the visualization
branch. No direct GitHub source write, CI pass, or issue comment counts
as a non-bypassable Flexible Pipes dispatch/delivery receipt or
independent ai-ci acceptance. Keep all candidates unmerged until
that requirement is satisfied.

## New Agda residue-table lifting boundary (draft PR #19)

The generated finite character tables can now be treated as finite
proof obligations, not as trusted executable output.

`Euler.ResidueCharacter` defines `FiniteResidueCharacter R (q−1)` with
only finite residue premises:

1. the table at `1 % q` is the multiplicative unit of R;
2. for *residues* `a,b<q`, the table at `ab % q` is the product of
   the table values at a and b;
3. at residues `a<q` not coprime to q, the table value is zero.

The proof `gcd-residue` establishes
`gcd(n % q,q)=gcd(n,q)` for **all natural n** from the standard-library
divisibility universal property. The rest of the lifting uses the
standard-library modulo-product/periodicity lemmas. The resulting
`CertifiedFromTable.certified` is an actual
`DirichletCharacterCertificate R` on **all natural numbers**, without
an assumed extension step from machine unsigned integers.

`Euler.QuadraticCharacterThree` and
`Euler.QuadraticCharacterFour` give *constructed* certificates:
their exact integer residue tables have respectively 9 and 16
multiplication cases. Nonunits are proved zero and unit residues
are checked against the gcd. The resulting χ₃ and χ₄ specialize
the existing finite arithmetic Euler-expansion theorem. This gives
genuinely nonprincipal character instances, rather than only the
previous χ₁(n)=1 example.

`Euler.MultiplicativeTwist` then proves that the product of a certified
character and a second certified completely multiplicative coefficient
is again completely multiplicative in an arbitrary commutative ring.
This is the algebraic route to the actual Dirichlet-series coefficient

    a_s(n) = χ(n) · n^(−s).

Its analytic use **still requires a proof** that n↦n^(−s) takes
positive integers into the intended complex coefficient ring and
is completely multiplicative, followed by absolute convergence
for Re(s)>1. A finite twisted identity is not an infinite Euler product.

**Unfinished certification:** the generated χ₅± quartic tables have
complex, not just integer, values. A root-of-unity representation needs
a proved compatible complex/cyclotomic ring and a mechanically checked
finite phase-addition table. Neither C11 code nor a GLSL readback
is accepted as an Agda witness. Likewise the generated conductor and
parity labels still require their own formal statements and proofs.
The 128-residue cap on the C ABI is irrelevant to Agda's all-natural
lifting theorem.
