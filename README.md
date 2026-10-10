# Dirichlet — symbolic L-function foundations

The first experiment is the *equivalence* between a finite geometric polynomial, its rational quotient, its infinite limit, and one prime's Euler factor. These are **different theorems with different hypotheses**. Work-control record: [Flexible Pipes #72](https://github.com/isomorphisms/flexible-pipes/issues/72).

## Finite geometric series: the ring identity

For any commutative ring R with 1, element q and natural number N, define

    G(0,q) = 0
    G(N+1,q) = G(N,q) + q^N
    G(N,q) = 1 + q + ... + q^(N-1)   (N > 0)

The first type-level theorem is the **division-free** identity

    (1-q) * G(N,q) = 1 - q^N.        (GEOMETRIC-FINITE)

Proof by induction: at N=0, both sides vanish. Assuming the law at N,

    (1-q)G(N+1,q) = (1-q)G(N,q) + (1-q)q^N
                   = (1-q^N) + q^N - q^(N+1)
                   = 1-q^(N+1).

This proof uses only ring laws, and remains valid at q=1.

## Quotient, removable holes and the analytic limit

For **a field** and q != 1, the preceding identity permits division:

    G(N,q) = (1-q^N)/(1-q).

But G(N,1)=N. The apparent zero/pole pair at q=1 cancels. It is **not** a pole of the finite polynomial.

Example:

    G(4,q) = 1+q+q^2+q^3 = (1+q)(1+q^2).
    zeros: -1, +i, -i; no poles; G(4,1)=4.

The other Nth roots of unity are the zeros of G(N,q). As N increases they become dense on the unit circle.

Only when q is complex with **|q| < 1** does N -> infinity yield

    sum_{k=0}^infinity q^k = 1/(1-q).

The rational continuation has a pole at q=1, on the **boundary**, not in the disk of convergence. Do not conflate the finite cancellation with a pole of the limiting continuation.

A raw numerator/denominator is not unique: multiplying both by a common nonzero polynomial inserts spurious zero/pole pairs. A reduced rational fraction is unique up to a nonzero constant. Mathematical and rendered singularities must be invariant under this algebraic rewriting.

## The local Euler factor and the global L-function

For a Dirichlet character chi, complex s and a prime p, let

    q_p(s) = chi(p) * p^(-s)
    local(p,s) = sum_{k=0}^infinity q_p(s)^k
               = 1/(1 - chi(p)*p^(-s)).

In Re(s) > 1, absolute convergence, character multiplicativity and unique prime factorization justify

    L(s,chi) = sum_{n=1}^infinity chi(n)*n^(-s)
             = product_{p prime} local(p,s).

**The prime product is infinite.** The geometric trick collapses each *local prime-power series* to one denominator factor; it does not turn the whole zeta or L-function into a single finite rational denominator. For the trivial weight chi(n)=1, the displayed identity is the Riemann zeta function in Re(s)>1.

First character: chi4, modulo 4,

    chi4(even n) = 0
    chi4(n mod 4 = 1) = +1
    chi4(n mod 4 = 3) = -1.

At p=3, q_3(s) = -3^(-s), so local(3,s) = 1/(1+3^(-s)).
At s=2, this **one** factor is 9/10. The complete L(2,chi4) is Catalan's constant.

**Do not** apply the Euler product outside its convergence half-plane to claim values or zeros in the critical strip. A finite Dirichlet sum and a finite Euler product with unrelated cutoffs are different approximants.

## Intended Idriç propositions (design signatures, not compiled source)

The canonical language is [Idriç](https://github.com/isomorphisms/Idric); its maintained files use the .idric surface, not C macros. These are symbolic *obligations* to implement and independently verify, not invented compiler APIs or completed proofs.

    finite_geometric_identity
      : (R : CommutativeRing) -> (N : Number) -> (q : Carrier R)
      -> ((1-q) * G(N,q) = 1 - q^N)

    finite_geometric_quotient
      : (K : Field) -> (N : Number) -> (q : Carrier K)
      -> (q != 1) -> (G(N,q) = (1-q^N)/(1-q))

    infinite_geometric_identity
      : (q : Complex) -> (norm q < 1)
      -> (limit(N -> infinity, G(N,q)) = 1/(1-q))

    dirichlet_euler_equivalence
      : (chi : DirichletCharacter) -> (s : Complex)
      -> (real_part s > 1)
      -> (DirichletSeries(chi,s) = EulerProduct(chi,s))

A checked induction proves the first obligation. The quotient uses nonvanishing; the complex limit needs completeness and bounds; the Euler product needs multiplicativity, prime factorization and analytic convergence. Never implement a proof by unchecked casts or numeric equality tests.

## Wegert: present the mathematical value, not an invented zero/pole list

[Wegert](https://github.com/isomorphismes/wegert) currently renders rational functions represented by zeros/poles. Its genuinely reusable boundary is [code/wegert_color.glsl](https://github.com/isomorphismes/wegert/blob/main/code/wegert_color.glsl), taking complex values or phase and logarithmic modulus.

First visualization: draw G(N,q) in the q-plane, preserving the canceled pair at q=1 and the nontrivial roots of unity. Then display one Euler local factor through q=chi(p)p^(-s). Later supply bounded Dirichlet sums and bounded Euler products, with truncation and the evaluated domain visible. A GPU shader cannot replace the theorem about infinite products.

Do not silently copy Wegert's GPL-3.0-or-later color code into this initially unlicensed repository: make any future reuse and license explicit. No shader execution, proof checking, ICK build, device GPU rendering, numerical evaluator, or APK is asserted by this source-only document.

## Independent rejection fixtures to develop

1. N=0: G=0; N=1: G=1; N=4: G(4,1)=4.
2. Symbolic coefficients satisfy (1-q)G(N,q) = 1-q^N, including q=1.
3. For N=4, zero markers at -1, +i, -i; **reject** a pole marker at +1.
4. chi4(3)=-1; chi4(2)=0; local(3,2)=9/10.
5. Reject misuse of Euler products as critical-strip approximations.
6. Any claimed GPU acceptance must capture the selected, running shader and device renderer, not merely a plausible rendering or passing generated tests.

## Interactive Wegert controls (draft)

The unmerged [WebGL2 viewer](web/index.html) evaluates **finite mathematics** and passes
the resulting complex number to Wegert's actual GPL-3.0-or-later phase/log-modulus
color core. The viewer fetches the source at runtime from
[Wegert revision 873d03e](https://github.com/isomorphismes/wegert/blob/873d03e86ec2e4a9236bb2d253fee3c8fde83b6c/code/wegert_color.glsl).
No copy of Wegert GLSL is embedded in this unlicensed repository.

To run: serve the repository root with a local HTTP server such as
Python 3's http.server on port 8000, then visit http://localhost:8000/web/.
The first page load needs network access to the pinned Wegert source.
WebGL2 is required; there is no misleading CPU substitute.

Controls: finite geometric G(N,q), a selected character's Euler factor,
finite Dirichlet sum, or finite Euler product; character/N/P/prime selectors; drag/pan,
pinch/scroll zoom, point probing, and camera reset. Switching among s-plane
models preserves camera; switching q-plane to s-plane resets it.

The maintained scalar reference is code/dirichlet_eval.c (C11 complex),
with a parallel JS probe evaluator in web/eval.mjs. Independent tests:

    cc -std=c11 -Wall -Wextra -Werror -pedantic code/dirichlet_eval.c tests/dirichlet_host.c -lm -o /tmp/dirichlet-host
    /tmp/dirichlet-host
    node --test tests/eval.test.mjs

These models are deliberately distinct. G(N,1)=N without a pole. The
chi4 Dirichlet series converges to L(s,chi4) for Re(s)>0 (absolutely for
Re(s)>1); the Euler product represents L(s,chi4) in Re(s)>1.
Finite prime products outside this half-plane are not analytic continuation.

**Still unqualified:** no physical MIRO A1 shader selection, CPU/GPU
grid agreement, APK, ICK build, verified proof, or independent ai-ci
acceptance. The direct loading of GPL Wegert code is explicit; any
combined offline or bundled distribution needs licensing resolved.
Flexible Pipes #72 is a tracking issue, not a dispatched job receipt.
Do not merge/release until the actual work-control gate accepts it.


## Numerical C11 / JavaScript / WebGL2 parity

The viewer has an opt-in numerical-capture variant of the **same**
fragment shader. It carries the raw IEEE-754 float32 real and imaginary
results through two WebGL2 draws into an offscreen 1x1 RGBA8 buffer
using four byte-encoded color channels per component. The reader
decodes actual GLSL numbers; screenshot colors are not treated as
numerical evidence.

A reproducible 141-case grid (tests/numeric-cases.mjs) retains all original
81 chi4 cases and adds 60 non-default-character cases across local factors,
finite Dirichlet sums and Euler products. It includes ±i coefficients,
principal characters, primes including 2, and complex coordinates. A separately
implemented C11 evaluator must match the JavaScript evaluator to
scaled error below 2e-11; running WebGL2 shader values must agree
within absolute error 0.0002 + 0.0003 times the reference modulus.

The shader test accepts only moderate, finite, nonsingular test points.
No bound is claimed near local-factor poles, for huge complex
magnitudes, or beyond the bounded truncation ranges. Do not replace a
failed shader with CPU-generated colors. The browser test uses
software/SwiftShader and does **not** certify physical PowerVR or
native Android GLES selection.

To run independently, compile code/dirichlet_eval.c with
tests/numeric-grid-cli.c using C11 and -lm, then pass that binary to
node tests/cpu-grid.mjs. For real shader execution run
bash tests/browser-smoke.sh; it also records four normal browser
portraits. This remains separate from proof checking and full L-function
analytic continuation.

## Native-control integration seam

The portable C11 camera/control state in code/dirichlet_view.c and
code/dirichlet_view.h supplies the same six GLSL uniforms used by the
WebGL2 viewer. It validates bounded mode/cutoff/prime transitions and
preserves the camera anchor during pan/pinch without any Android or
OpenGL dependency. See ANDROID.md for the inspected L NativeActivity
reuse boundary, the ABI, outstanding licensing, and physical-device
acceptance. This is not a built or qualified APK.

## Explicit Dirichlet characters (draft implementation)

The seven choices below are actual multiplicative, periodic Dirichlet
characters, **not modular-form weights**. A nebentypus may be a Dirichlet
character in a separate modular-form context, but no modular-form
constructors or weight semantics are added here.

| Character | Modulus | Nonzero residues and values |
| --- | ---: | --- |
| χ₄ | 4 | χ(1)=1; χ(3)=−1 |
| χ₃ | 3 | χ(1)=1; χ(2)=−1 |
| χ₅⁺ | 5 | χ(1)=1; χ(2)=i; χ(3)=−i; χ(4)=−1 |
| χ₅⁻ | 5 | χ(1)=1; χ(2)=−i; χ(3)=i; χ(4)=−1 |
| χ₈ | 8 | χ(1)=1; χ(3)=−1; χ(5)=−1; χ(7)=1 |
| χ₀,₄ (principal) | 4 | χ(odd)=1; χ(even)=0 |
| χ₁ (principal) | 1 | χ(n)=1 for all integers n |

Entries on non-units vanish for moduli greater than 1. The coefficients
are represented exactly as Gaussian integers 0, ±1, ±i; this finite
catalogue is **not** a generic construction of characters for all moduli.
The C11 and JS suites independently test χ(1)=1, unit support,
periodicity and complete multiplicativity on *every* pair of residue
classes. That checks the tables, not a general mathematical proof in
Idriç or Agda.

The evaluator uses χ(n)n^(−s) in bounded sums and
(1−χ(p)p^(−s))^(−1) in bounded Euler products, preserving complex values.
Original χ₄ entry points remain supported. A nonprincipal character's
infinite Dirichlet series converges for Re(s)>0 (absolutely for Re(s)>1).
For principal characters the unmodified Dirichlet series converges for
Re(s)>1 and L(s,χ) has a pole at s=1. In all cases the *infinite*
Euler-product identity is justified in Re(s)>1. The finite evaluators
work elsewhere but do **not** analytically continue L(s,χ).

View code and tests:
- `code/dirichlet_eval.[ch]`, `web/eval.mjs`, `web/dirichlet.frag.in`
- `tests/dirichlet_host.c`, `tests/eval.test.mjs`
- `tests/numeric-cases.mjs` (C11 ↔ JS ↔ running WebGL2 shader)

The portable GLES uniform interface adds `u_character`; an Android host
must bind it, and existing Android-source-only limitations still apply.
No general character-group enumeration, Idriç character theorem, global
L-function analytic continuation, device acceptance, or release is
claimed. Keep this stacked draft unmerged pending trustworthy Flexible
Pipes delivery and separate ai-ci acceptance.
