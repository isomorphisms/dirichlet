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
