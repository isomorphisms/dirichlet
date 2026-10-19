# Character ingestion and the native complex boundary

The required producer is the existing ICK C library. A replacement Idriç
evaluator would not exercise that named compiler, library, or C ABI. This
attempt repairs the existing C implementation; no alternate producer is used.

## Values and interfaces

`n_to_minus_s(unsigned n, double complex s) -> double complex` is an internal
mathematical function, with positive n supplied by the bounded sum/prime
callers. It computes n to the negative complex exponent s. Logarithm, real
exponential, sine and cosine cross the external libm interface as scalars;
the compiler constructs and operates on its own complex representation.
No foreign Cartesian complex ABI is assumed. The public library's complex
entrypoints still require an explicitly compatible caller representation.

The seven catalogue tables are exact pairs of signed Gaussian-integer
coordinates. Their support, normalization and multiplication laws are checked
with bounded integer arithmetic. Numerical evaluation remains floating-point;
it is not an exact arithmetic theorem or a foreign ABI certificate.

The finite geometric producer's repeated multiplication/sum is checked against
an independent polar closed form at the same original q and unchanged error
bound. The previous external `cpow` reference assumed the same unqualified
foreign complex ABI as `cexp`; neither external complex call is used now.

## Executed evidence and first remaining failure

The declared ICK native scalar host profile at source
`c61e448251744a2f40ad743ebef1a027bdcd2f9d` was used for actual consumer builds.
Its driver SHA-256 is
`45805e3295f2709737fcc87985a8a2341aa8663ff8e4e398d2a9d78dc1283e10`.
The prior generated sum for modulus 1, cutoff 3 and exponent 2 produced about
-14 rather than 1 + 1/4 + 1/9. The same observed failure was reproduced with
the separately source-built fbe86e23 compiler profile. This is evidence about
these precise host profiles and calls, not a compiler-wide diagnosis.

After the scalar libm repair, all 3,019 independent generated C/JavaScript
numerical comparisons pass (worst scaled error 1.700e-15), as do the exhaustive
bounded generated C fixtures, the native viewport/uniform fixtures, and 243
legacy/generated numerical comparisons (worst scaled error 3.001e-14).
The descriptor JavaScript suite passes all eleven tests. Running its new
adverse fixtures against the old parent rejects the old implementation at
the expected malformed-descriptor assertions.

The complete legacy C host test still fails its exact assertion
`dirichlet_character_value(DIRICHLET_CHI5_PLUS,2) == I` at line 64 in the
current test. The exact integer catalogue check passes; the actual host
profile's dynamically constructed floating complex value does not compare
equal to the literal. This assertion is retained, not changed to a tolerance.
The full host qualification is therefore FAIL, and merge acceptance remains
blocked on resolving that exact native complex construction/equality
observation through the intended compiler/runtime boundary. This does not
prove that a proper source-built native polar-runtime profile has the same
behavior; that profile has not been replayed here.

No GPU, APK, installation, physical device or analytic-continuation acceptance
follows. The failed and passing logs are retained beside this account. The
next meaningful acceptance is the unchanged complete legacy C test passing
under the declared, qualified compiler/runtime profile, followed by rerunning
both independent numerical grids and the actual shared-library boundary.
