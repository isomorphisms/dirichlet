# Dirichlet reading list: PhD theses and IAS lectures on modular weights

This is a source bibliography, not a declaration of features already implemented in Dirichlet.

**Expanded summaries:** [IAS lecture notes on weights, cusp forms and L-functions](ias-lecture-notes.md).
The notes distinguish lecture-page abstracts, supplementary papers, and mathematical context;
no full-video transcript is claimed.
For a classical modular form, the weight k and the character (nebentypus) chi
are separate data. In particular, the coefficients chi(n) in a Dirichlet
L-function are not by themselves the modular-form weight k. Half-integral
weights introduce additional multiplier/metaplectic structure.

## PhD theses

1. Piper Alexis Harron (2016), *The Equidistribution of Lattice Shapes of
   Rings of Integers of Cubic, Quartic, and Quintic Number Fields: An Artist's
   Rendering*. PhD dissertation, Princeton University; adviser Manjul
   Bhargava.
   https://www.theliberatedmathematician.com/wp-content/uploads/2015/11/PiperThesisPostPrint.pdf
   Topic: arithmetic statistics, number fields and lattice shapes. Included
   as an unusually readable and personally distinctive number-theory thesis;
   it is NOT a thesis about modular-form weights.

2. Chandrashekhar B. Khare (1995), *Congruences between Cusp Forms*.
   PhD dissertation, California Institute of Technology.
   https://thesis.caltech.edu/4046/
   DOI: 10.7907/wgmk-nk78
   Topic: congruences between modular forms, weight-2 newforms, modular
   deformations, mod-p forms in varying weights and Hecke algebras.

3. Sever Achimescu (2005), *Hilbert Modular Forms of Weight 1/2*.
   PhD dissertation, California Institute of Technology; adviser Dinakar
   Ramakrishnan.
   https://thesis.caltech.edu/1520/
   DOI: 10.7907/PBNR-3X07
   Topic: half-integral-weight Hilbert modular forms, characters and theta
   series.

4. Tomomi Ozawa (2017), *Classical Weight One Hilbert Cusp Forms in a Hida
   Family and Galois Representations*. Doctoral thesis, Tohoku University.
   https://tohoku.repo.nii.ac.jp/records/124554
   Topic: weight-one specializations of families of Hilbert cusp forms and
   associated Galois representations.

5. Alexander Dunn (2020), *Analytic and Arithmetic Applications of Half
   Integral Weight Automorphic Forms*. PhD dissertation, University of
   Illinois at Urbana-Champaign.
   https://www.ideals.illinois.edu/items/115703
   Topic: half-integral-weight modular/automorphic forms, L-series,
   spectral methods, mock theta functions and Kloosterman sums.

## Recorded IAS lectures

1. Bao V. Le Hung (2017-10-02), *Weights of mod p Automorphic Forms*.
   https://www.ias.edu/video/postdoc/20171002-BaoV.LeHung
   Mod-p automorphic / Serre weights: irreducible coefficient representations,
   rather than merely an integer k. The short-talk listing lacks an abstract;
   interpretive notes cite adjacent talks and papers, not an alleged transcript.

2. Vincent Pilloni (2017-11-07), *Higher Hida Theory*.
   https://www.ias.edu/video/MotivesGaloisRepsandCohomology/2017/1107-VincentPilloni
   Varying weights in p-adic families; specialization over weight space.

3. Chandrashekhar Khare (2017-11-07), *Automorphy of mod 3 Representations
   over CM Fields*.
   https://www.ias.edu/video/MotivesGaloisRepsandCohomology/2017/1107-ChandrashekharKhare
   Cohomological cuspidal newforms of weight at least 2, mod-3 Galois
   representations, and automorphy over CM fields.

4. Spencer Leslie (2022-04-28), *Modular Forms of Half-Integral Weight on
   Exceptional Groups*.
   https://www.ias.edu/video/modular-forms-half-integral-weight-exceptional-groups
   Half-integral weight, metaplectic double covers, and an exceptional-group
   example of weight 1/2.

5. Wen-Ching Winnie Li (2022-10-13), *Modular Curves, Modular Forms
   and Hecke Operators: Old and New*.
   https://www.ias.edu/video/modular-curves-modular-forms-and-hecke-operators-old-and-new
   Ogg's newform theory and Rankin-Selberg convolution; new Hecke-trace
   method for even-weight cusp forms on certain triangle groups, including
   cocompact Shimura-curve examples. The IAS video page mistakenly carries
   Barry Mazur's abstract; use Li's own event description:
   https://www.ias.edu/events/celebration-honor-frank-c-and-florence-s-professorship-2

6. Xiannan Li (2022-12-08), *Quadratic Twists of Modular L-Functions*.
   https://www.ias.edu/video/quadratic-twists-modular-l-functions
   Modular L-functions, twists and the role of Fourier coefficients of
   half-integral-weight modular forms.

7. Jack Thorne (2023-05-18), *Symmetric Power Functoriality for Hilbert
   Modular Forms*.
   https://www.ias.edu/video/symmetric-power-functoriality-hilbert-modular-forms
   Regular-weight Hilbert modular forms and Langlands functoriality.

8. Gyujin Oh (2024-05-09), *Derived Hecke Action for Weight One Modular
   Forms via Classicality*.
   https://www.ias.edu/video/derived-hecke-action-weight-one-modular-forms-classicality
   Why weight-one specializations of p-adic families need not be classical
   in the way higher-weight specializations are.

9. John Bergdall (2026-05-01), *On the Distribution of Modular Points on
   Deformation Rings*.
   https://www.ias.edu/video/distribution-modular-points-deformation-rings
   Modular forms parametrized by weights, with related local deformation
   rings and p-adic Hodge theory.

## Questions for Dirichlet (not yet design commitments)

- Keep Dirichlet characters chi, modular-form weight k, level N and
  nebentypus logically distinct.
- Compare Euler products of Dirichlet L-functions to Hecke-eigenform
  L-functions before introducing a more general cusp-form representation.
- Treat half-integral weights and p-adic varying weights as separate
  extensions, not consequences of adding an integer k field.
