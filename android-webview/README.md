# Dirichlet C67 experimental Android installer

This is an **installable Android WebView host** for the exact finite Wegert
viewer and Dirichlet-character weights in `../web/`. The viewer is not
rewritten in Java, and there is no C++ dependency. The only Java application
code provides an Android launcher and maps read-only APK assets to an HTTPS
origin so JavaScript modules, fetch(), and WebGL2 can work in a WebView.

The APK runs on Android 8+; it contains no architecture-specific native code,
so it supports both 32-bit and 64-bit Android userspace. GLES 3.0 is required.
The target C67 is **not yet tested**. This experiment diagnoses actual WebView
WebGL2 and shader behavior on a physical phone; it does not certify a NativeActivity
GLES target or physical-device driver compatibility.

## Install on C67

Open the GitHub Actions run for `.github/workflows/c67-debug-apk.yml`.
Download the `dirichlet-c67-test-apk` ZIP artifact, extract
`app-debug.apk` in the phone's Files app, tap to install, and allow the
installation from that specific source if Android asks. Launch
`Dirichlet C67 test`.

The app includes the HTML, JS and GLSL fragment template. The phase-color
core is **fetched at runtime** from the existing pinned
`isomorphismes/wegert@873d03e` URL, preserving that project's license
boundary. A network connection and working GitHub raw access are required
for first paint. Failure is displayed in the viewer's status area, not hidden
by fabricated offline colors.

Test: switch weights chi4/chi3/chi1; switch finite sum, local factor, finite
product and geometric polynomial; pan, pinch, probe values and reset. The
`?smoke=1` startup requests a real center-pixel readback and sets an internal
smoke evidence attribute. Browser-host CI results are not physical C67 evidence.

The package ID is `org.isomorphisms.dirichlet.viewer`; it does not replace L
or Wegert. The APK uses the stable, **publicly known and untrusted** Wegert
test signer at immutable commit `873d03e` and checks its certificate fingerprint.
It must never be treated as a production/security-trusted release key.

This experimental candidate remains **draft and unmerged** pending real
Flexible Pipes dispatch/delivery, independent ai-ci acceptance, licensing
qualification for any subsequently bundled Wegert shader, and physical device
acceptance. The preferred future native Android GLES route remains the
existing L NativeActivity architecture, not WebView as a substitute for it.
