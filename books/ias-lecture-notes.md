# IAS lectures: working notes on weights, cusp forms, and L-functions

Research notes prepared 2026-10-10. Companion to [the bibliography](README.md).

**Evidence boundary:** These are expanded interpretations of the linked IAS abstracts
and event descriptions, supplemented by the cited research papers and some
explicit mathematical background. **They are not transcripts or claims that
the recordings have been watched in full.** Results proved in papers published
after a talk are marked as subsequent reading, not retroactively attributed
to its speaker on the day. This is an exploratory reading notebook, not a
specification or an implementation commitment.

## A dictionary of four different meanings of "weight"

1. **Classical holomorphic weight.** An integral weight k occurs in the
   transformation law f((az+b)/(cz+d)) = (cz+d)^k f(z), with an additional
   character or multiplier where required. A modular form can be cuspidal
   or noncuspidal at a fixed k. Its weight, level N, and nebentypus psi
   are separate choices.
2. **Half-integral weight.** A weight such as 1/2 is not obtained safely
   by naively taking a square root of (cz+d); one needs a suitable
   multiplier system or metaplectic cover. Generalizations on exceptional
   groups require their own representation theory.
3. **Serre weights in characteristic p.** A mod-p automorphic *weight*
   can be an irreducible representation of a finite reductive group over
   a finite field. The weight part of Serre's conjecture asks which
   such weights occur for a given mod-p Galois representation. This is
   not merely reducing the integer k modulo p.
4. **p-adic weight space and cohomological weights.** Families vary
   p-adically across a space of weights; in the familiar GL(2) case,
   characters of Z_p^× provide the elementary model. For larger groups,
   weights can have several components and regularity conditions.
   Nonregular or singular weights can cause higher coherent cohomology
   and classicality issues.

The lectures below cross these categories; they do not all study the
same parameter.

## 1. Bao V. Le Hung — Weights of mod p automorphic forms (2017-10-02)

**Recording:** https://www.ias.edu/video/postdoc/20171002-BaoV.LeHung

**What is documented:** IAS lists this as a 15-minute postdoctoral short
talk, but supplies no substantive abstract. Therefore the following is
a *contextual explanation of the subject*, not a reconstruction of
Le Hung's specific arguments or slides.

A mod-p Galois representation can contribute Hecke eigenvalues to
spaces of automorphic forms with different coefficient representations.
The **weight part of Serre's conjecture** seeks a prediction, using
local information at primes above p, for the precise collection of
weights in which that Galois representation is modular.
"Weight elimination" proves that no unexpected weights occur;
showing that each predicted weight occurs is the converse problem.

His closely related 2016 IAS seminar discusses Serre-weight conjectures
in dimension greater than two and tame-type deformation rings.
The joint 2016 works by Daniel Le, Bao V. Le Hung, Brandon Levin,
and Stefano Morra prove forms of weight elimination, and establish
generic cases via potentially crystalline deformation rings and
patching. These papers supply mathematical background but do not
certify the contents of the shorter 2017 lecture.

**Conceptual point for Dirichlet:** Some "weights" are *representations*,
not integers to insert into a modular-form transformation law.
If a common abstraction is eventually useful, it needs tagged,
mathematically distinct kinds of weight.

**Read next:**
- IAS short-talk program: https://www.ias.edu/math/events/short-talks-postdoctoral-members-408
- Le Hung's longer 2016 IAS talk: https://www.ias.edu/video/iaspujnt/2016/0922-BaoLeHung
- Daniel Le, Bao V. Le Hung, Brandon Levin, *Weight elimination in
  Serre-type conjectures*: https://arxiv.org/abs/1610.04819
- Daniel Le, Bao V. Le Hung, Brandon Levin, Stefano Morra,
  *Potentially crystalline deformation rings and Serre weight conjectures*:
  https://arxiv.org/abs/1512.06380

## 2. Vincent Pilloni — Higher Hida theory (2017-11-07)

**Recording and abstract:**
https://www.ias.edu/video/MotivesGaloisRepsandCohomology/2017/1107-VincentPilloni

Traditional Hida theory studies p-adic families of *ordinary* modular
forms. Algebraically, it produces a module over weight space whose
specialization at sufficiently regular arithmetic weights recovers
classical ordinary forms. The problem in Pilloni's abstract is that,
for **nonregular weights**, the appropriate geometric information may
live in *several cohomological degrees*. A single module for sections
in degree zero cannot capture it.

The proposed replacement is a **perfect complex** over a part of
weight space. Roughly, this is a bounded complex that locally has a
finite-projective model, so specialization retains derived information.
At suitable classical nonregular weights, the resulting specialized
complex computes coherent cohomology of the relevant Shimura variety.
Pilloni outlines this for GSp(4) and certain irregular-weight families.
This is not just adding a variable k to an existing evaluator.

**Why L-functions enter:** Later work by David Loeffler, Vincent
Pilloni, Christopher Skinner, and Sarah Livia Zerbes uses higher Hida
theory on Siegel threefolds to interpolate periods coming from
positive-degree cohomology. It constructs p-adic L-functions for the
degree-4 spin L-function of GSp(4), and the degree-8 L-function of
GSp(4) × GL(2). That later result is useful context, **not a claim**
about what was proved live in November 2017.

**Conceptual point for Dirichlet:** Weight variation sometimes needs a
*complex with cohomology*, not a scalar field in a form record.
This is relevant to the exploration of types and reductions, but does
not impose a coding task.

**Read next:** David Loeffler, Vincent Pilloni, Christopher Skinner,
Sarah Livia Zerbes, *Higher Hida theory and p-adic L-functions for
GSp(4)*: https://arxiv.org/abs/1905.08779

## 3. Chandrashekhar Khare — Automorphy of mod 3 representations over CM fields (2017-11-07)

**Recording and abstract:**
https://www.ias.edu/video/MotivesGaloisRepsandCohomology/2017/1107-ChandrashekharKhare

The guiding question is how to show that a two-dimensional mod-3
Galois representation over a **CM field** comes from a cohomological
cuspidal automorphic representation. One example of a CM field is
K = Q(i). Khare compares this with the modularity strategy over Q
associated with Wiles.

The obstruction is not that a weight-1 form simply lacks an L-function.
Rather, the traditional modularity argument over Q uses a starting
automorphy result involving mod-3 representations and passage between
weights. The corresponding Langlands–Tunnell route does not directly
supply the needed starting point over general CM fields. Khare's
abstract instead describes a route using **2-adic automorphy lifting**
in the residually dihedral case, plus a Diophantine **2–3 switch**
that helps relate mod-6 representations to elliptic curves.

The **weight distinction** is between low-weight starting points
and the cohomological cusp forms of weight at least two needed in
the lifting argument. "Cohomological" is a genuine hypothesis, not
another synonym for "cusp".

**Subsequent result, not asserted as a complete theorem in the 2017
talk:** Patrick B. Allen, Chandrashekhar Khare, and Jack A. Thorne
later proved modularity statements for many mod-3 representations
over CM fields, alongside analogous results at p=2 and 5, and
consequences for modular elliptic curves.

**Read next:** Patrick B. Allen, Chandrashekhar Khare, Jack A. Thorne,
*Modularity of GL_2(F_p)-representations over CM fields*:
https://arxiv.org/abs/1910.12986
A later explanation of the missing weight-one congruences:
https://www.math.princeton.edu/events/automorphy-mod-3-representations-over-cm-fields-2019-02-21t213000

## 4. Spencer Leslie — Modular forms of half-integral weight on exceptional groups (2022-04-28)

**Recording and abstract:**
https://www.ias.edu/video/modular-forms-half-integral-weight-exceptional-groups

For classical half-integral-weight forms, the automorphic setting
involves the metaplectic double cover of SL(2). Leslie describes
extending this kind of structure to double covers of quaternionic
exceptional groups, rather than assuming all modular-form theories
live on GL(2) or on an ordinary subgroup of SL(2).

The central example is a **weight-1/2 modular form on the double
cover of G2**, constructed using a minimal automorphic representation
on the double cover of F4. Its Fourier coefficients record information
about the **2-torsion of narrow class groups of totally real cubic
fields**. Thus coefficients of an automorphic form are linked to
arithmetic invariants of number fields.

The ensuing joint paper by **Spencer Leslie and Aaron Pollack** makes
a subtle point: the Fourier coefficients in this half-integral-weight
setting are complex numbers **defined only up to sign**. That
ambiguity should not be hidden by pretending the coefficients are
canonical complex scalars in the simplest sense.

**Conceptual point for Dirichlet:** It is valuable to compare coefficient
systems and associated L-functions, but a half-integral weight here
includes metaplectic and group-specific structure; it is not obtained
by setting classical k = 0.5 in a holomorphic-form data structure.

**Read next:** Spencer Leslie and Aaron Pollack,
*Modular forms of half-integral weight on exceptional groups*:
https://arxiv.org/abs/2205.15391

## 5. Wen-Ching Winnie Li — Modular curves, modular forms and Hecke operators: old and new (2022-10-13)

**Recording:** https://www.ias.edu/video/modular-curves-modular-forms-and-hecke-operators-old-and-new

**Critical source correction:** The abstract currently displayed on
the IAS **video page** describes a talk by Barry Mazur about Ogg's
conjecture on rational points. That is NOT an adequate abstract for
Li's own recording. The IAS **event program** explicitly states her
subject:
https://www.ias.edu/events/celebration-honor-frank-c-and-florence-s-professorship-2

The lecture connects Andrew Ogg's work and Li's personal mathematical
history, especially **newform theory** and **Rankin–Selberg
convolutions**. The new mathematical result in the event description
is a method for computing **traces of Hecke operators** on spaces of
even-weight cusp forms for certain triangle groups. The
**cocompact** case is particularly interesting: the relevant quotient
is a Shimura curve, rather than an ordinary noncompact modular curve
with cusps. Consequently, the term "cusp form" needs attention to
the ambient automorphic setting.

For a finite-dimensional cusp-form space S_k and a Hecke operator T,
the trace tr(T | S_k) is the sum of its eigenvalues with multiplicity.
Later joint work by **Jerome W. Hoffman, Wen-Ching Winnie Li,
Ling Long, and Fang-Ting Tu** expresses traces in arithmetic triangle
group cases by **finite-field hypergeometric character sums**.
That gives a computational bridge from modular-form spectra to
character sums—closely related in spirit to the arithmetic
objects explored in Dirichlet.

**Conceptual point for Dirichlet:** This is the clearest
lecture in this collection for investigating how character sums,
Hecke eigenvalues, spaces of forms, and L-functions are assembled,
without needing to implement every surrounding theory.

**Read next:** Jerome W. Hoffman, Wen-Ching Winnie Li, Ling Long,
Fang-Ting Tu, *Traces of Hecke Operators via Hypergeometric Character
Sums* (subsequent joint paper):
https://arxiv.org/abs/2408.02918

## 6. Xiannan Li — Quadratic twists of modular L-functions (2022-12-08)

**Recording and abstract:**
https://www.ias.edu/video/quadratic-twists-modular-l-functions

Take a modular L-function L(s, f) and twist its coefficients by a
quadratic Dirichlet character chi_D. Schematically,
L(s, f ⊗ chi_D) = sum_{n>=1} a_f(n) chi_D(n) n^(-s)
in an appropriate half-plane. One then studies the family as the
fundamental discriminant D varies, particularly **central values**.
The center is s=1/2 in unitary normalization; another commonly used
normalization places it at s=k/2 for a holomorphic form of weight k.

Xiannan Li's stated result is an **unconditional asymptotic for the
second moment** of these twists, previously available under the
Generalized Riemann Hypothesis through work of Soundararajan and
Young. The technical new input is an **optimal large-sieve-type
bound**. A second moment, schematically an average of
|L(1/2, f ⊗ chi_D)|^2 over D, measures the typical *size in
aggregate*; it does not give an exact formula for each twisted
critical value or a method for analytic continuation by finite
Euler products.

Her abstract also highlights ties to Fourier coefficients of
half-integral-weight modular forms and data on elliptic curves.
This links the half-integral phenomena of Leslie's lecture to
analytic questions about families of L-functions, though the
theorems are quite different.

**Conceptual point for Dirichlet:** A twist by a character is a
different operation from changing the modular-form weight.
A family parameter D, its conductor, the functional equation,
and the choice of central normalization must remain visible.

**Read next:** Xiannan Li, *Moments of quadratic twists of modular
L-functions*: https://arxiv.org/abs/2208.07343

## 7. Jack Thorne — Symmetric power functoriality for Hilbert modular forms (2023-05-18)

**Recording and abstract:**
https://www.ias.edu/video/symmetric-power-functoriality-hilbert-modular-forms

For a cusp form / automorphic representation on GL(2), the unramified
local data can be represented by two Satake parameters alpha_v and
beta_v. The m-th symmetric power has, schematically, the m+1 local
parameters alpha_v^(m-j) beta_v^j for j=0,...,m, and thus a
**degree-(m+1) unramified Euler factor**. Symmetric-power
functoriality asks for an automorphic representation whose local
parameters have this prescribed relationship.

The IAS abstract describes the proof, joint with **James Newton**,
of the existence of **all symmetric-power lifts** for cuspidal
automorphic representations associated to **regular-weight Hilbert
modular forms** over totally real fields. It names automorphy
lifting, automorphic forms on unitary groups, Shimura-variety
geometry, and a property of Spec(Z) as inputs. These are parts of
the proof strategy, not an elementary factor-by-factor proof
obtained by writing a product formula.

Symmetric powers also connect to **Sato–Tate equidistribution**:
one can constrain the distribution of normalized Frobenius
parameters by proving suitable automorphy/analytic properties
for a collection of symmetric-power L-functions.

**Conceptual point for Dirichlet:** The **degree of a local Euler
factor** and the **weight of the underlying form** are not the
same datum. Symmetric power changes the former even while
preserving a systematic relationship to the latter.

**Read next:** James Newton and Jack A. Thorne,
*Symmetric power functoriality for Hilbert modular forms*:
https://arxiv.org/abs/2212.03595
Later journal version:
https://annals.math.princeton.edu/2026/203-1/p04

## 8. Gyujin Oh — Derived Hecke action for weight one modular forms via classicality (2024-05-09)

**Recording and abstract:**
https://www.ias.edu/video/derived-hecke-action-weight-one-modular-forms-classicality

A p-adic family of modular forms can specialize to **nonclassical**
objects at weight one, even though standard higher-weight
specializations in the setting under discussion are classical.
Oh's abstract treats this failure of classicality as a source
of additional structure, rather than simply a defect to suppress.

The proposed structure is a **derived action** on weight-one
modular forms, understood in the lecture as a **derived Hecke
operator at p**. This is not the ordinary action of a scalar
Hecke eigenvalue on a one-dimensional eigenspace. The talk
connects this derived structure to **p-adic periods of the
adjoint representation** associated with weight-one forms.

This fits a broader development: **Michael Harris and Akshay
Venkatesh** studied a derived Hecke algebra acting on weight-one
forms and conjecturally related its action to **Stark units**.
That is *related literature*, not a claim that Oh reproduced
their particular conjecture in the lecture.

**Conceptual point for Dirichlet:** Specializing a parameter can
lose information if one retains only a scalar value. In a derived
setting, the way a specialization fails to be classical can itself
carry arithmetic information. This is one interesting mathematical
reason to retain transformations and their witnesses rather than
only outputs.

**Read next:** Michael Harris and Akshay Venkatesh, *Derived Hecke
algebra for weight one forms*: https://arxiv.org/abs/1706.03417

## 9. John Bergdall — On the distribution of modular points on deformation rings (IAS video dated 2026-05-01)

**Recording and abstract:**
https://www.ias.edu/video/distribution-modular-points-deformation-rings

**Event date note:** The IAS recording page is dated May 1, 2026;
the event calendar lists the seminar on April 30, 2026. These
appear to distinguish the lecture event from video publication.
https://www.ias.edu/math/events/joint-iaspu-number-theory-12

Weight parameters occur on both the **automorphic** side
(spaces of modular forms) and the **Galois deformation** side
(local deformation rings, with conditions supplied by p-adic
Hodge theory). The comparison is a local–global problem: when
does a locally permitted deformation actually arise from a
global modular/automorphic object?

Bergdall starts with Kisin's result that modular points occur
on **every relevant irreducible component** of certain local
deformation rings. Existence is a coarse statement; the newer
work asks **how many** points lie on a component and describes
a way to count them using the **geometry of the special fiber**.
The work is joint with **Chengyang Bao and Brandon Levin**.
The publicly supplied abstract does not state a general numerical
formula, so these notes do not invent one.

**Conceptual point for Dirichlet:** A parameter space of weights is
often geometry, not merely a list of numbers. Proving *existence*
of a modular point and counting such points are importantly
different operations.

**Read next:** John Bergdall's research page, linking an
Oberwolfach report and the seminar:
https://bergdalljf.github.io/research.html

## Connecting the lectures to the Dirichlet project

For a primitive Dirichlet character chi, the usual local Euler
factor at an unramified prime is degree one:

    L_p(s,chi) = 1 / (1 - chi(p) p^(-s)).

For a normalized holomorphic Hecke eigen-newform f of weight k,
level N, and nebentypus psi, at p not dividing N:

    L_p(s,f) = 1 / (1 - a_p p^(-s) + psi(p) p^(k-1-2s)).

The latter is degree two in p^(-s). At ramified primes the local
factors require separate treatment. In general the variables
*k* (weight), *N* (level), *psi* (nebentypus), *chi* (twist),
the local Satake parameters, and the Euler-factor *degree*
must not be equated.

Useful open questions, **not feature requirements**:

- How should a mathematical library represent weights that are
  integers, highest weights, finite-group representations, or
  p-adic characters without collapsing their differences?
- Which identities between different Euler-product descriptions
  should be proven, and which are only formal expressions that
  require independent convergence or automorphy theorems?
- Where does a construction require coherent cohomology or derived
  specialization rather than ordinary evaluation?
- Could character sums, traces of Hecke operators, and small
  half-integral-weight examples provide concrete objects for
  experimentation before attempting a universal modular-form API?
- How should Dirichlet's exploration distinguish direct characters,
  character twists of degree-two forms, and symmetric-power lifts?

These questions may remain questions. Notes can grow without a
new proof checker, rendering system, build job, or library rewrite.
