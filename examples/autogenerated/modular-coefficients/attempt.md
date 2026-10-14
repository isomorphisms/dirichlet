# Exact finite modular coefficients

Campaign: STAR DIRICHLET-ADVANCE-01; bounded slice SUN DIR-10A / DIR-13.

## Contract before implementation

Compute finite coefficient lists over signed arbitrary-precision integers. A list
starts at degree zero; the requested length is the number of retained degrees.
The mathematical values are independent of input/output or a graphics backend.

Types: coefficient → ±Number; degree and length → Number;
finite coefficient data → List ±Number.
Central operations: coefficient-wise addition, finite convolution, truncation,
finite product. Every recursive operation must terminate by structural recursion.
No unchecked casts, postulates, floating point or partial definitions.

First closed obligations: multiply the normalized E₄ and E₆ prefixes through
q³ and compare E₄³ − E₆² with 1728 times the prefix of
q ∏(1−qⁿ)²⁴. Independent expected Δ prefix: 0, 1, −24, 252.
The two sides must use distinct constructions; do not define Δ by the identity
and then call that a test of the identity. Reject a changed coefficient witness.

Source: William Stein, Modular Forms, A Computational Approach, chapter
Modular Forms of Level 1, Proposition 2.4, Fourier expansions and Lemma 2.20:
https://wstein.org/books/modform/modform/level_one.html
His F₄/F₆ convention has constant coefficient 1, whereas his Eₖ convention has
q coefficient 1. Our E₄/E₆ names use constant coefficient 1 as requested.

## Scope and runtime

This first slice checks closed finite identities in the Idriç compiler. It
does not prove modularity, infinite product convergence, a general coefficient
formula, or compiler correctness. The evaluator remains finite exact algebra.
L's existing Float32 rendering arrays remain unchanged.

Candidate compiler: Idric source 94dfd99bd3e376507fedc8611053b7173b2519f0,
Linux x86_64 candidate archive SHA256
0be57deab9410e8d4c09c7198bf7e8ee0ec3e24121f76640147efa4a53d120da.
Use its check-only mode. No RefC or generated-C backend is accepted.
FP must control commands through a Kitchen/Ike task. A command receipt must
not be promoted to trusted lease, visible delivery, or independent AI-CI approval.

## Actual result, 2026-10-14

The signed Idriç candidate was executed through FP → Kitchen/Grease → Ike.
It failed elaboration: `Undefined name ±Number` and `Undefined name −`.
The existing `idric/GeometricFinite.idric` independently hit the same boundary.
No native signed-coefficient theorem is claimed. Both source attempts remain.

The narrow fallback `modular-coefficients.mjs` uses JavaScript BigInt, the existing
language used by L's coefficient layer. Its `order` is the highest retained
degree, so each output contains order+1 coefficients including degree zero.
It implements exact E₄/E₆ divisor sums, Δ from its truncated product, truncated
convolution, and level-one prime Hecke operators with explicit input precision.
No float or analytic function-value result is inferred from these arrays.

`test-modular-coefficients.mjs` passed through the same FP/Kitchen/Ike route:
the identity through q³², T₂ and T₃ eigenform examples through q³², published
initial coefficients, independent divisor enumeration, and malformed-input/
insufficient-precision/corrupted-coefficient rejection cases. The test is the
producer test; independent AI-CI oracle acceptance is tracked separately.
Source module SHA256: 1e88f85f72f9ab58b71b3934767056bae263c582524511e9595af8bd4930597e.
Producer test SHA256: ff9106f35451e80cdedbe0d1bcf731c26550292dfacdd71e9151b57baa8afa44.

Smallest owner follow-up: make the canonical signed-number name and Unicode
subtraction resolve consistently in Idriç, then check this preserved module and
reject a changed Δ coefficient witness. Typechecking remains distinct from
native machine-code/backend qualification. Trusted service dispatch and platform
delivery are NOT_VERIFIED; no receipt is reconstructed for earlier work.
