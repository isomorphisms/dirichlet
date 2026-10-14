# Closed natural-number geometric witnesses

Campaign: SUN DIR-13A, STAR DIRICHLET-ADVANCE-01.

## Type sketch and contract

Ratio, exponent and sum are Number. The operations are natural-number addition,
multiplication and structural recursion. No effects, division, casts or axioms.
This deliberately separate semiring example requires neither signed coefficients
nor subtraction. It does not replace the signed GeometricFinite.idric candidate.

Check G(4,1)=4, G(4,2)=15 and the subtraction-free finite identity
G(4,2)+2⁴=1+2G(4,2) using Refl normalization. Reject the false equality G(4,1)=5
in a separate fresh compiler build. The closed identities are native compiler
checks; no general theorem, compiler correctness, or code-generation acceptance
follows from them.

Runtime: Idriç 94dfd99bd3e376507fedc8611053b7173b2519f0 Linux x86_64
candidate; exact archive SHA256
0be57deab9410e8d4c09c7198bf7e8ee0ec3e24121f76640147efa4a53d120da.
FP controls compilation through Kitchen/Ike. Independent AI-CI acceptance and
trusted live dispatch must be reported separately from command execution.

## Actual result, 2026-10-14

The original signed source is preserved and failed on undefined `±Number` and
Unicode `−`. This independent natural-number module passed check-only execution
through FP → Kitchen/Grease → Ike, producing a fresh GeometricNatural.ttc.
It also proves the quantified theorem G(length,1)=length by induction, using
the pinned base library's Data.Nat addition lemma. This is a small native
Idriç theorem, not a substitute for the general commutative-ring proof.

`GeometricFalse.idric` was checked in another fresh build and rejected while
unifying its false Refl witness; it produced no accepted theorem artifact.
The rejection is semantic, not a parser/import failure. The separate pipeline
correctly records FAIL for that deliberately invalid source.

Final passing source SHA256:
7abe3c6ba04fff33d9dd387ce4b2ec78f4a794eb907c3a3fda0387aeaebf9151.
False-witness SHA256:
2df0170bd34ad3516ddc04a98e006738a3b04671c2418aada12f5e589f517f7b.
Archive and internal payload checksums matched. Independent AI-CI promotion,
trusted service dispatch, physical execution and compiler correctness are not
established by these compiler runs.
