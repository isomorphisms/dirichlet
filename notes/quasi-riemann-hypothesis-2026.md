# Reading notes — The Quasi-Riemann Hypothesis (OpenAI, 2026)

**Source:** OpenAI, *The Quasi-Riemann Hypothesis: A Zero-Free Half-Plane \(\Re s>7/8\)*, dated 30 September 2026 (199 pages).

- [Original PDF](https://github.com/openai/math/blob/main/preprints/The-Quasi-Riemann-Hypothesis-September-30-2026/paper.pdf)
- [Full LaTeX manuscript](https://github.com/openai/math/blob/main/preprints/The-Quasi-Riemann-Hypothesis-September-30-2026/build/paper.tex); inspected source blob **268c4e3206d460c617d3d2129742a72b831b3def**.
- [Authors' description of the Lean formalization](https://github.com/openai/math/blob/main/lean/docs/003.md), including comparator statements.
- [Related alternate proof of the \(11/12\) bound](https://github.com/openai/math/blob/main/preprints/The-Quasi-Riemann-Hypothesis-October-5-2026/paper2.pdf) — a *different manuscript*, not Part I of the present 199-page paper.
- [Uniform exclusion of Landau–Siegel zeros](https://github.com/openai/math/blob/main/preprints/Uniform-exclusion-of-Landau-Siegel-zeros-October-1-2026/paper.pdf) — separate companion.
- [Reading task and delivery boundary](https://github.com/isomorphisms/flexible-pipes/issues/80).

**Status of these notes (10 October 2026):** A mathematical reading map based on the full manuscript's sections, displayed claims and central estimates, not an independent line-by-line refereeing report or a local rebuild of its Lean formalization. The algebraic identity behind the final endpoint certificate in Section 20.4 was also checked independently by symbolic expansion. This limited check must not be confused with proof verification. Page numbers below are the PDF's printed page numbers.

## 1. Exact claim, with its quantifiers (pp. 4–7)

Write \(F=\mathbb Q(\sqrt{-3})\). For every finite-order Hecke character \(\eta\) of \(F\), and for **every** Dirichlet character \(\chi\), the manuscript's Theorem 1.1 asserts

\[
 L_F(s,\eta)\ne0,\qquad L(s,\chi)\ne0
 \quad\text{whenever }\Re s>7/8.
\]

The principal-character pole at \(s=1\) is permitted. The real threshold \(7/8\) does **not** depend on the conductor, the character or \(|\Im s|\). The strict inequality matters: it makes no assertion that the line \(\Re s=7/8\) is zero-free.

The *quasi*-Riemann hypothesis asks only for **some fixed** \(\theta<1\) with \(\zeta(s)\ne0\) throughout \(\Re s>\theta\). The paper claims \(\theta=7/8\), for a stronger entire family. This differs fundamentally from a conventional zero-free region whose width shrinks with the imaginary height or conductor. It also differs from a zero-density estimate, which bounds the *number* of zeros rather than excluding all zeros from one region.

It does **not** establish RH or GRH at the critical line \(\Re s=1/2\). For zeta, functional-equation symmetry, together with the claimed exclusion, confines its nontrivial zeros to

\[
 1/8\le\Re\rho\le7/8.
\]

The statement is nonvanishing, not a quantitative lower bound on \(|L(s,\chi)|\) uniform in all parameters.

The proof works first in the larger finite-order Hecke family over the Eisenstein field, *even to prove the consequence for zeta*. The cubic-theta and sextic-character transforms do not close within the family consisting only of \(\zeta\).

### A consequence worth remembering (pp. 7–8)

Corollary 1.2 derives, for odd primes \(p\), a polylogarithmic bound for the least positive quadratic nonresidue,

\[
 n(p)\le C(\log p)^A
\]

with absolute constants; the manuscript says \(A=32\) is permissible without optimization. Hence \(n(p)\ll_\delta p^\delta\) for every \(\delta>0\), the stated Vinogradov least-nonresidue conjecture. By combining the nonresidue search with Tonelli–Shanks, it further obtains a deterministic algorithm polynomial in \(\log p\) to find square roots in \(\mathbb F_p\) or report their absence. These applications use a cited theorem of Bhargava, Ivanyos, Mittal and Saxena; they do not follow from drawing a zero-free strip alone. The Lean scope document expressly does **not** include the paper's later applications.

## 2. The common contradiction mechanism: Proposition 2.1 (pp. 8–9)

This is the clearest place to begin studying the proof itself.

Let \(\beta_*\) be the supremum of \(1/2\) and the real parts of zeros of **all primitive finite-order Hecke \(L\)-functions over \(F\)** lying between \(1/2\) and \(1\). Thus \(1/2\le\beta_*\le1\). Crucially, a supremum need not be attained: no single “rightmost zero” is assumed to exist.

Fix a proposed boundary \(\sigma_0\in(1/2,1)\) and suppose for contradiction that

\[
 \Delta_0=\beta_*-\sigma_0>0.
\]

For each primitive target \(\eta\), delete a *finite* set \(S\) of Euler factors to obtain \(L_F^S(s,\eta)\). Each deleted factor is nonzero for \(\Re s>0\). Choose a holomorphic \(H_\eta\) on \(\Re s>\sigma_0\) satisfying

\[
 \sup_{\Re s>\sigma_0}|H_\eta(s)-1|\le1/2.
\]

In particular, \(H_\eta(s)\) never vanishes there. Let \(C(s)=s+c\), where \(c\) is a fixed real number, and introduce the Mellin signal

\[
 f_\eta(Z)=\frac{1}{2\pi i}
 \int_{\Re s=2}Z^{C(s)}
 e^{(s-5/6)^2}\frac{H_\eta(s)}{L_F^S(s,\eta)}\,ds.
\]

A separately constructed **finite physical character sum** \(J_\eta(Z)\) must satisfy two independent comparisons:

\[
 |J_\eta(Z)|\ll_\eta Z^{C(\sigma_0)+\omega},
 \quad 0<\omega<\Delta_0,
\]

\[
 |J_\eta(Z)-f_\eta(Z)|
 \ll_\eta Z^{C(\beta_*)-\sigma},\quad \sigma>0.
\]

Both **positive power margins** \(\omega,\sigma\) must be selected independently of the target character. Constants, finite excluded sets, cutoff heights and sufficiently large thresholds may depend on the target. That distinction is not cosmetic: the contradiction concerns the supremum over *the whole family*.

The triangle inequality now gives a common \(\varepsilon_*=\min(\Delta_0-\omega,\sigma)>0\) and

\[
 |f_\eta(Z)|\ll_\eta Z^{C(\beta_*)-\varepsilon_*}.
\]

The Gaussian controls the opposite endpoint \(Z\downarrow0\). Mellin inversion (recast as Fourier inversion after \(Z=e^u\)) identifies the Mellin transform of \(f_\eta\) with \(e^{(s-5/6)^2}H_\eta(s)/L_F^S(s,\eta)\) on \(\Re s>1\). The improved decay extends the transform holomorphically into \(\Re s>\beta_*-\varepsilon_*\). Since \(H_\eta\) is nonzero, so does \(1/L_F^S(s,\eta)\). By the definition of a **supremum**, some character has a zero to the right of this new boundary; its reciprocal would have a pole. Contradiction.

This continuation is obtained by integrability and inversion, **not** by shifting a contour blindly through an \(L\)-zero.

The two uses of the proposition change the actual sum and affine exponent:

| Stage | \(\sigma_0\) | \(C(s)\) | Low scale \(C(\sigma_0)\) |
| --- | --- | --- | --- |
| Part I | \(11/12\) | \(s-2/3\) | \(1/4\) |
| Part II | \(7/8\) | \(s-11/16\) | \(3/16\) |

**Do not identify the normalized sums \(J_{\mathrm I,\eta}\) and \(J_{\mathrm{II},\eta}\).** The continuation *principle* is shared, but their definitions and estimates differ.

## 3. Arithmetic conventions and why they matter (§§3–5, pp. 10–45)

The Eisenstein integers are \(\mathcal O=\mathbb Z[\omega]\), \(\omega=e^{2\pi i/3}\). They form a triangular Euclidean lattice. Every ideal prime to \(3\) has a unique **primary** generator congruent to \(1\bmod3\). Write \(q_a=|a|^2=N_{F/\mathbb Q}(a)\). Arithmetic is over ideals (and their chosen generators), not just ordinary positive integers.

For a good prime ideal \(p\) of norm \(P\equiv1\bmod6\), the sextic symbol \(\chi_p(a)\) is the sixth root of unity corresponding to \(a^{(P-1)/6}\), with \(\chi_p(a)=0\) when \(p\mid a\). The paper retains these zero extensions for every exponent. Thus a sixth power of a residue character equals the **coprimality indicator**, not the constant function one:

\[
 \chi_c(a)^6=1_{(a,c)=1}.
\]

This is a recurring potential trap. It applies also to formal cancellations of characters and to factors whose exponent happens to be divisible by six.

Section 4 establishes Gauss-sum normalization, sextic reciprocity phases, smooth-profile calculus, fixed-numerator ray characters and bounds for Hecke \(L\)-functions in zero-free regions. A “fixed character” includes its complete zero-extended presentation and modulus support. A numerator containing a **moving** good prime does not magically become a fixed ray character.

Section 5 uses cubic theta coefficients and their reflection. After completion the relevant arithmetic index is

\[
 A=cn^3,\qquad c\ \text{squarefree},
\]

with \(c,n\) primary. **They may share prime factors.** The full \(n^3\) is retained rather than discarding its powerful part. The target and supplementary ray phases act on the entire product \(cn^3\), not on two incorrectly separated coprime pieces.

The reflection gives a second representation of these rows; quadratic large-sieve estimates and an unmarked completed-row energy bound control its mean square. The paper explicitly tracks primary generators, bad-prime masks, Gauss phases and common smooth weights in this reduction. This is the background for estimating the *same* probe in two mathematically different ways.

## 4. Part I — the balanced \(11/12\) proof (§§3–11, pp. 10–85)

### §6: Direct or “low” bound (pp. 45–50)

The base probe \(I_\eta(X,Y,Z)\) averages a completed cubic-theta row over an auxiliary variable and a finite Fourier transform. For the first stage the two averaging scales are balanced:

\[
 X=Y=Z^{1/2}.
\]

The paper separates the sum into an additive polynomial and a reflected completed-theta row. For the former it proves a planar additive large sieve on \(\mathbb C/\mathcal O\), including the separation of reduced Eisenstein fractions. The reflected mean-square bound controls the latter. Cauchy–Schwarz gives Proposition 6.3:

\[
 |I_\eta(Z^{1/2},Z^{1/2},Z)|\ll_{\eta,\varepsilon}Z^{1/4+\varepsilon}.
\]

This is *one* inequality about the actual physical sum, not an estimate of an arbitrary approximate functional equation.

### §7: Poisson expansion and Euler factors (pp. 50–55)

Poisson summation in the averaging variable produces nonzero frequencies

\[
 H=ua^6,\quad u\ \text{sixth-power-free}.
\]

The auxiliary primitive character removes the zero frequency and those meeting the excluded primes. The row \(u=1\) is special. After exact local Gauss calculations, the high-side series takes the scalar shape

\[
 \frac{\zeta_F^S(6z)\,
  L_F^S(w,\chi_\bullet(u))}
 {L_F^S(x,\eta\,\overline{\chi_\bullet(u)})}
 \mathcal H_{\eta,u}(x,w,z).
\]

Here \(\chi_\bullet(u)\) means the character of the *varying ideal* defined by the fixed row numerator \(u\), including its zero masks. The correction \(\mathcal H\) is an Euler product, not something safely replaced by \(1\) before checking local factors. The \(u=1\) row contains \(1/L_F^S(x,\eta)\) and ultimately the desired Mellin signal. Its principal residues must be taken with their precise factors.

This local computation is where the prime-power completion and reciprocal character phases earn their keep. In particular, the **same probe** has both the direct representation in §6 and the exact Poisson representation in §7.

### §§8–9: Zeros create large witnesses; the large sieve limits such rows (pp. 55–70)

The zero detector partitions possible zero locations into buffered height rectangles. The floor is \(a=51/100\). Above it, a row with a selected zero yields **two simultaneous large polynomials for one common row character and twist height**:

\[
 M_\psi(D;W)=D^{-1/2}\sum_{\mathfrak a}
   \mu(\mathfrak a)\psi(\mathfrak a)W(N\mathfrak a/D),
\]

\[
 S_\psi(D;W)=D^{-1/2}\sum_{\mathfrak a}
   \psi(\mathfrak a)W(N\mathfrak a/D).
\]

The first is a truncated-inverse or Möbius polynomial; the second is plain. The detector also chooses usable length ranges and controls the effects of smoothing and height cutoffs. It does not assert that a formal Euler product converges in the critical strip.

Part I exploits the inverse witness, after splitting off powerful factors of the sixth-power-free row. The sextic large sieve in Lemma 9.1, schematically, is

\[
 \sum_{\substack{k\ \mathrm{sf}\\q_k\le K}}
 \left|\sum_{\substack{n\ \mathrm{sf}\\q_n\le D}}
 c_n\chi_n(k)^{\pm1}\right|^2
 \ll_{\varepsilon,S}(KD)^\varepsilon
 [K+D+(KD)^{2/3}]\sum_n|c_n|^2.
\]

That counts the possible rows carrying the detector witnesses. The proof uses sextic-character reciprocity and the relevant higher-order large-sieve recursion; the \(2/3\) term is part of the particular strength being invoked.

### §§10–11: Principal extraction, errors and transfer (pp. 70–85)

The nonprincipal row count is inserted into the high expansion. Principal residues are extracted separately; intermediate, small and large row norms and contour tails have separate bounds. The cutoff \(T_1\) is a tool for analysis, *not* part of the physical sum or signal.

The final first-stage high comparison is Proposition 11.2:

\[
 |J_{\mathrm I,\eta}(Z)-f_{\mathrm I,\eta}(Z)|
 \ll_\eta Z^{C_{\mathrm I}(\beta_*)-1/4800}.
\]

The direct side is \(O_\eta(Z^{1/4+\omega})\), with \(\omega=(\beta_*-11/12)/2\) in the contradiction. The margins meet Proposition 2.1, so \(\beta_*\le11/12\). The very small \(1/4800\) is a **proof margin**, not an improved zero-free boundary.

Proposition 11.3 transfers the Hecke statement to Dirichlet characters. If \(\chi_{-3}\) is the quadratic character associated with \(F/\mathbb Q\), and \(\eta(\mathfrak a)=\chi(N\mathfrak a)\), then away from the finite bad set,

\[
 L_F^{S_F}(s,\eta)
 =L^{S_{\mathbb Q}}(s,\chi)\,
  L^{S_{\mathbb Q}}(s,\chi\chi_{-3}).
\]

At a split rational prime, the two prime ideals both have norm \(p\); at an inert prime, the one ideal has norm \(p^2\). These produce exactly the two factors. Deleted Euler factors are nonzero for \(\Re s>0\). Thus a Dirichlet zero in the proposed half-plane would force a Hecke zero. Principal poles receive separate treatment.

## 5. Part II — what changes to reach \(7/8\) (§§12–20, pp. 85–197)

Part I supplies \(\beta_*\le11/12\). Assuming for contradiction \(\beta_*>7/8\), define

\[
 \Delta=\beta_*-7/8,\quad
 0<\Delta\le1/24,\quad
 \kappa=2\beta_*-1=3/4+2\Delta\le5/6.
\]

For each selected zero-bin \(a\), write \(\delta=2a-1\). Then \(\delta\le\kappa\). The fact that \(\kappa\) is the *actual dynamic value* \(2\beta_*-1\), not always its upper bound \(5/6\), will matter to the fourth-moment capacity.

### §12: A different, prime-compensated physical probe (pp. 85–87)

The geometry is asymmetric and exact:

\[
 h=13/16,\quad \ell=1/6,\quad b=1/8,
 \qquad l_x=17/48,\quad l_y=23/48,
\]

\[
 X=Z^{17/48},\quad Y=Z^{23/48},\quad
 l_x+l_y=5/6,\quad l_x+l_y+\ell=1.
\]

Choose finitely many disjoint annular **prime slots** with positive lengths \(\ell_i\) summing to \(\ell=1/6\). They lie in the identity ray class of a fixed finite group \(T\). The construction is a finite inclusion–exclusion-like sum over subsets of slots. For one selected prime \(p\), the operation is

\[
 \overline{\eta(p)}I_{\eta;p}(X,Y,Zq_p)
 -
 q_p^{-3/2}I_\eta(X/q_p,Y/q_p,Z).
\]

In the first term the completed index is marked by \(p\mid cn^3\); in the second both averaging scales are rescaled. Each prime window stays at its original size even when a different slot is rescaled. The subtraction cancels an unwanted *local scalar* term on the Poisson side and leaves a character-sensitive prime contribution that can be estimated by the new moment machinery. This is **not** merely putting prime weights on the Part I sum.

The new Mellin exponent is

\[
 C_{\mathrm{II}}(s)=s-11/16,\qquad C_{\mathrm{II}}(7/8)=3/16.
\]

### §§13–14: Finite correlations and marked reflection (pp. 87–101)

The exact finite Fourier correlations of complete sextic Gauss sums must accommodate common prime powers, not just coprime squarefree moduli. Prime counting in one fixed ray class supplies the later **nonzero normalization**, without invoking a moving-modulus prime asymptotic.

The whole-index reflection is extended to conditions like \(p\mid cn^3\). Marked sums are decomposed into product-form constraints, and the reflected row energy is estimated with quadratic–cubic norms. This is the technical bridge between the low estimate and the marked inverse moments. All marked slots must keep their zero extensions, fixed-ray phases and full index.

### §15: The improved low estimate (pp. 101–108)

The marked reflected energy controls one Hilbert-space factor; an additive **Gram estimate** controls the other. Cauchy–Schwarz gives Proposition 15.3,

\[
 |I_{\eta,\mathrm{modified}}(Z)|
 \ll Z^{l_x/2+b/12+\varepsilon}
 =Z^{3/16+\varepsilon}.
\]

The same finite modified sum goes into the high expansion. The particular exponent \(3/16\) is matched to \(C_{\mathrm{II}}(7/8)\); it is not borrowed from the first-stage \(Z^{1/4}\) bound.

### §16: Exact local compensation and a holomorphic correction (pp. 108–114)

The high-side correction cannot naively be expressed everywhere by dividing by a local Euler factor, because a factor used as a denominator may itself vanish. The paper explicitly combines the two selected-prime operations into a **quotient-free** local \(G_p\), holomorphic even at such points. The full correction is a finite tuple sum of products of these \(G_p\) and normally convergent unselected Euler factors.

This yields an *exact* modified Poisson identity with the same scalar \(L\)-quotient as above and a new holomorphic \(\mathfrak H_{\eta,u,Z}\). Distinguish (i) the original high-side identity, (ii) its central-contour factorization into main slots and errors, and (iii) the special principal-residue factorization. None justifies freely dividing by an arbitrary local factor on all contours.

### §17: Marked inverse second moment (pp. 114–152)

With a single row character and products \(Q_u\) of marked prime polynomials, Lemma 17.1 proves (under **strict positive gaps**)

\[
 r+2z\le m-c_1,\qquad
 2r+8z\le3m-c_2,\qquad c_1,c_2>0,
\]

\[
 \sum_{0<q_u\ll Z^m}
   |M_u(Z^r;W)Q_u|^2\ll Z^{m+\varepsilon}.
\]

The number of slots and real ranges are fixed; the bound is uniform in admissible moving prime supports and coefficients. The proof is not a one-line use of the sextic sieve. It passes to a canonical family involving a fourth-power residue symbol, recursively applies **two finite masked Poisson transforms**, and uses reflected energy as a terminal bound. A finite propagation lemma prevents external smooth seminorms and height orders from silently growing with arbitrary recursion depth. A later amplification supplies a no-slot bound for longer inverse polynomials on sixth-power-free rows.

The inequalities express the **cost** of attaching prime factors to an inverse witness. “We have an inverse polynomial” is not enough: the length and slot capacities must fit these regions.

### §18: Fourth moment for two plain polynomials (pp. 152–180)

This is a distinct, substantial induction. For a row character \(\psi_k\), two plain polynomials \(S_{\psi_k}(n_1)\), \(S_{\psi_k}(n_2)\), and short disjoint prime-slot product \(Q\), the key target is

\[
 \sum_{k\in\mathcal R_z}
 |S_{\psi_k}(n_1)S_{\psi_k}(n_2)Q|^2
 \ll Z^{M+\varepsilon},\qquad M=m+q_{\mathrm{cond}},
\]

where \(q_{\mathrm{cond}}\) denotes the exponent bounding the moving conductor/radical *in this lemma*, not the mean prime amplitude called \(q\) in §19. For positive total prime-slot length \(z\), the allowed affine region is

\[
 n_1+n_2+6\kappa z\le M.
\]

If \(\kappa<1\), the lemma assumes \(\beta_*\le(1+\kappa)/2\); the application sets \(\kappa=2\beta_*-1\), so this hypothesis is met. With **zero** slot length, the paper allows unrestricted bounded \(n_1,n_2\) and excludes only principal inducing rows. With positive slots, it excludes the fixed finite family \(\Theta\) of inducing characters. These cases must not be interchanged.

The recursion uses reflection and two finite Poisson transforms. Transformed rows whose inducing characters lie in \(\Theta\) may carry full volume-sized main terms. For the long-length cases, the proof subtracts a second product with **the same product of scales** \(X_1X_2=Y_1Y_2\) and the same characters, norm powers, masks and profiles, so the leading terms cancel. This cancellation belongs to the **centered difference only**. It is false to say that every exceptional-family row automatically has its main term canceled.

### §19: From simultaneous witnesses to a refined row count (pp. 180–186)

Prime amplitudes are partitioned into bins. If \(\delta=2a-1\), the prime-slot mean amplitude satisfies \(0\le q_{\mathrm{amp}}\le\delta/2\). Put \(x=q_{\mathrm{amp}}/\delta\in[0,1/2]\), \(\alpha=5/6\), and

\[
 D_x=3-\frac{17x}{9},\qquad
 P_x=\left(2-\frac{8x}{9}\right)(1-x).
\]

The inverse and plain moment estimates lead to competing row-count exponents

\[
 R_{\rm short}(t)=1-\delta+
       \frac{\delta P_x}{D_x}(3/2-t),
 \qquad
 L(t)=1-\delta+(\alpha-\delta)(t-1),
\]

with \(1\le t\le3/2\). Proposition 19.2 bounds the count of rows in a bin by approximately

\[
 U^{\max(R_{\rm short}(t),L(t))+\Delta/4+\varepsilon}.
\]

The \(\Delta/4\) allowance records the cost of replacing an ideal capacity by the actual one; it cannot be omitted in the final contradiction. If no slots are selected, the paper has a separate \(U^{1-2\delta/3+\varepsilon}\) estimate. Near zero capacities and the endpoint \(\delta=5/6\), it invokes the appropriate no-slot statements rather than applying a moment theorem with zero strict margin.

### §20: The final power inequality (pp. 186–197)

Prime counting gives a nonzero scalar normalizer \(A_T(Z)\), with a *fixed even number* \(K\) of slots and

\[
 A_T(Z)\asymp(\log Z)^{-K},\qquad
 A_T(Z)^{-1}\ll_\varepsilon Z^\varepsilon.
\]

Thus the normalized \(J_{\mathrm{II},\eta}=I_{\eta,\mathrm{modified}}/(c_SA_T(Z))\) has the required \(3/16+\varepsilon\) low bound. The principal row approximates the target signal; the other rows must be smaller by a common power.

For a row norm \(U=Z^d\), count exponent \(R\) and amplitude \(q=q_{\mathrm{amp}}\), Lemma 20.1 obtains the relative exponent

\[
 E(d)=-\frac1{48}+\frac23\delta+\frac q6
      -h(1-R)
      +(d-h)\left(R+\frac\delta2-\frac{17}{50}\right).
\]

One cannot just assert that \(E(d)<0\): \(R\) and \(q\) are correlated through the two witness capacities. At the main endpoint \(d=h=13/16\), balance the two row-count options by choosing a crossing \(t\). Lemma 20.2 supplies an explicit nonnegative-polynomial certificate for the optimized value \(E_*\):

\[
 -E_*\ge\frac{49}{440640}>\frac1{10000}.
\]

**Limited independent check performed for these notes:** symbolic expansion confirms the stated quadratic identity and its completion-of-the-square identity in §20.4. This only checks that displayed algebra; it does not validate the analytic estimates or the rest of the 199-page argument.

After restoring the \(\Delta/4\) capacity allowance, the paper records the critical comparison

\[
 E_{\rm actual}(h)-\Delta
 \le-\frac{49}{440640}
      -\frac{51}{64}\Delta+\varepsilon_{\rm total}.
\]

The subtraction of \(\Delta=C(\beta_*)-C(7/8)\) is essential. The remaining row-frequency ranges, principal residues and contour tails have separate positive margins.

Finally (§20.6), all **real margins and the finite slot geometry** are selected *before* the target \(\eta\); only then are target-specific seminorm orders, height exponent \(\tau_\eta\), external tail order and \(Z\)-threshold chosen. The height is \(T_1=Z^{\tau_\eta}\), but neither \(J_{\mathrm{II},\eta}\) nor \(f_{\mathrm{II},\eta}\) depends on \(T_1\). The final estimates have

\[
 |J_{\mathrm{II},\eta}(Z)|
 \ll_\eta Z^{3/16+\omega},\quad
 \omega=\Delta/2,
\]

\[
 |J_{\mathrm{II},\eta}(Z)-f_{\mathrm{II},\eta}(Z)|
 \ll_\eta Z^{C_{\mathrm{II}}(\beta_*)-\sigma},
 \quad\sigma>0
\]

with \(\omega,\sigma\) independent of \(\eta\). Proposition 2.1 contradicts \(\beta_*>7/8\); Proposition 11.3 then transfers the result to Dirichlet \(L\)-functions.

## 6. Dependencies and distinction from the Lean report

The manuscript draws on Kubota's metaplectic theory and Patterson's cubic-theta coefficients; the unconditional cusp-expansion material cited from Dunn and Radziwiłł; Hecke and sextic large sieves developed by Heath-Brown, Goldmakher and Louvel, Blomer, Goldmakher and Louvel, and others; planar large-sieve and character-moment methods; ordinary Hecke functional equations; and fixed-ray-class prime counting. The original reference list on pp. 198–199 is the source for exact bibliographic entries and author attributions. In particular the paper says the GRH-conditional prime asymptotic in Dunn–Radziwiłł is **not** an input to its proof.

The authors' [Lean scope note](https://github.com/openai/math/blob/main/lean/docs/003.md) covers the \(7/8\) zero-free assertions for zeta, Dirichlet and finite-order Hecke over \(\mathbb Q(\sqrt{-3})\), and a companion *logarithmic* Landau–Siegel real-zero exclusion; it expressly excludes the paper's later applications. The note lists comparator statements for these four claims. A comparator statement is not, by itself, a local verification of the linked Lean build; no such build was performed in preparing these notes.

The 2026-10-05 alternative \(11/12\) manuscript also proves a fixed half-plane, but should not be conflated with the **first stage inside this 199-page \(7/8\) manuscript**.

## 7. Points requiring special care on a deeper reading

1. **Which zeros are quantified?** \(\beta_*\) is a supremum over *all primitive finite-order Hecke characters*, not the zeros of just the target, nor just those of zeta. It need not be attained.
2. **Zero extensions never disappear.** In a sextic character, an exponent divisible by six still enforces coprimality; partial cancellation or treating \(cn^3\) as coprime factors can break the exact identities.
3. **Do the two representations concern one exact sum?** In both stages, yes. Stage II changes the physical sum before carrying out the matched low and high estimates.
4. **Where does the reciprocal actually appear?** In the \(u=1\) principal Poisson row, through the locally factored reciprocal of \(L_F^S(s,\eta)\). The other rows are Hecke twists and must be controlled family-wide.
5. **When is a local quotient legal?** The full compensated correction is defined without division by possibly vanishing local \(P_p\) or \(H_p\). A central factorization is not a globally valid one.
6. **What are the two witness estimates?** Part I principally uses an inverse witness and sextic sieve. Part II needs both a marked inverse second moment and a separate plain fourth-moment theorem, with exact capacity inequalities.
7. **What does “uniform” mean?** Uniform **power exponents** precede the target; the arithmetic presentations, constants, analysis heights and tail orders may depend on it. An assertion with \(\sigma_\eta\downarrow0\) would not prove the common contradiction.
8. **Does the final endpoint inequality by itself finish the proof?** No. It requires all physical row ranges, the principal normalizer, finite slots, holomorphic local errors, contour tails and the late height selection.
9. **What is established versus asserted?** These notes explain the manuscript's claimed proof architecture and verify one algebraic subidentity; an independent analysis of the long recursive lemmas and a Lean rebuild would be separate work.

## 8. Reasonable next mathematical checks, in order

- Work through **Proposition 2.1** independently: derive the Mellin/Fourier inversion and show exactly why common positive margins contradict a family supremum.
- Work through **§7's local Euler table** at a few prime valuations \(v_p(u)=0,\ldots,5\), preserving zeros on nonunits. This is the bridge from a physical sum to \(1/L_F\).
- Read the proof of the sextic sieve specialization (§9), then the two recursive moment proofs (§17 and §18). Check the term-by-term masks, common-character conditions, and strict capacity margins; a 199-page manuscript cannot be refereed from the final statement alone.
- Derive the exact **Hecke-to-Dirichlet quadratic factorization** at a split prime and an inert prime; this is approachable with the Dirichlet code already in the repository.
- Reproduce the scalar normalizer and final \(E(d)\) optimization (§§19–20), distinguishing \(q_{\mathrm{cond}}\) and \(q_{\mathrm{amp}}\), and check all endpoints and parameter ordering.
- Compare each formalized theorem **statement and hypotheses** against the Lean comparator and implementation, before describing any computer verification as independently reproduced.

## 9. Relation to Dirichlet and a possible video

Dirichlet already distinguishes a Dirichlet series, one local Euler factor, a finite product, and analytic continuation. Keep that distinction: neither an Euler product outside \(\Re s>1\) nor a finite truncated sum proves the \(7/8\) assertion. A Wegert-style domain-colouring visual could show the critical line \(1/2\), the claimed \(7/8\) boundary, and reflected \(1/8\) boundary; **no picture numerically certifies the absence of zeros at every height**.

For a serious video, the mathematical plot is the **two views of a constructed sum**, with the principal Poisson row exposing \(1/L\), not merely a news headline saying “AI proved part of RH.” The first video can cover the theorem and Proposition 2.1, followed by a longer treatment of cubic completion, the \(11/12\) stage, and why the prime-compensated second stage obtains \(7/8\). The thesis walkthroughs can follow afterward.

---

*Source note: OpenAI is credited as author as specified by the manuscript. Please use the original paper's bibliography for the names, spellings, titles and precise attributions of all works it cites. No text of the paper is claimed to have been independently certified in full by this notebook.*
