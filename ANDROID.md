# Dirichlet / Wegert Android GLES3 integration boundary (source only)

The existing WebGL2 portrait compiles a GLES 3.00 ES shader by inserting the
pinned isomorphismes/wegert color core into web/dirichlet.frag.in. The shader
math and uniforms are deliberately independent of browser and Android GUI.
The browser run is **not** Android runtime evidence.

The existing native Android host in
isomorphismes/L@668f0c4876c861635c1437cce0c5097f248854b8
(app/src/main/cpp/l.c) supplies an inspected NativeActivity lifecycle,
EGL ES3 context, fullscreen triangle, pan/pinch gestures, shader asset load,
and first-frame GL_RENDERER/readback logs. It is a *reference to reuse*, not
yet a drop-in executable for Dirichlet: L expects u_object, a different
bottom-navigation layout, and its analytically continued L-function shader.

## Ready for consumption

- code/dirichlet_view.h and .c: portable C11 controls. Geometric G(N,q),
  one selected-character local Euler factor, finite weighted sum and finite
  weighted Euler product (characters modulo 1, 3 and 4; default chi4).
- Controls supply u_center, u_half_height, u_aspect, u_model,
  u_cutoff, u_prime, and u_character, exactly matching
  web/dirichlet.frag.in.
- Changing q-plane ↔ s-plane resets the view, while changing among s-plane
  evaluators preserves pan and zoom. Zoom preserves the point under a touch.
- Cutoffs are bounded (32/127/31 respectively); invalid primes and invalid
  dimensions fail closed. No dummy poles/zeros are introduced.
- Host control tests do not need NDK headers, EGL, or an Android device.

## Native integration remaining

1. Adapt the existing L NativeActivity EGL lifecycle, rather than construct
   an unrelated Android/Java control pipeline. Preserve its object/gesture
   behavior for L itself; do not relabel the three LMFDB neighbor chips.
2. Use a separate Dirichlet target/application identity with four function
   choices, a cutoff adjustment, prime selection, character-weight selector,
   pan, pinch, and probe.
   The NativeActivity should read the portable view struct and pass its
   uniforms to the real compiled/linked Dirichlet shader program.
3. At build time assemble the GPL-3.0-or-later Wegert color shader from its
   immutable source revision; verify the expected source hash. There is no
   production/offline shader bundle here yet. Resolve combined-work
   licensing explicitly before redistributing a compiled or bundled APK.
4. Use ICK where it is actually qualified; otherwise use the pinned Android
   NDK as an explicit ICK gap, not as ICK evidence.
5. Record physical MIRO A1 package/build/signing identity, ABI (ARMv7 A32),
   GL_VENDOR, GL_RENDERER, GL_VERSION, chosen GLSL program, shader source
   revision, real pixel readback and actual interaction recording.
   SwiftShader/emulator evidence is separate from physical PowerVR.
6. Obtain real Flexible Pipes handoff receipts and independent ai-ci
   acceptance before merge, release, or publication.

This file is an integration handoff and **does not claim a working APK**.
For analytic continuation of the global L-function, keep the
isomorphismes/L Hurwitz-zeta continuation distinct from finite sums and
finite Euler products. No critical-strip Euler-product substitution.
