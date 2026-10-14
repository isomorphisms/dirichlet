# Dirichlet C67 experimental Android installer

This is an **installable Android WebView host** for the exact finite Wegert
viewer and Dirichlet-character weights in `../web/`. The viewer is not
rewritten in Java, and there is no C++ dependency. The only Java application
code provides an Android launcher and maps read-only APK assets to an HTTPS
origin so JavaScript modules, fetch(), and WebGL2 can work in a WebView.

The APK runs on Android 8+; it contains no architecture-specific native code,
so it supports both 32-bit and 64-bit Android userspace. GLES 3.0 is required.
The user reported successful physical C67 installation and supplied
screenshots of the weighted finite Dirichlet sum and a chi3 finite Euler
product from the version-1 APK. That establishes observable installation and
rendering, **not** GPU numerical accuracy or an independent device receipt.
Version 2 adds on-device numeric checks; it is not yet device-tested.
The WebView host is not a native NativeActivity/GLES qualification.

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
product and geometric polynomial; pan, pinch, probe values and reset. Scroll
to **Device graphics diagnostics** and tap **Check 171 GPU values**.
This compiles the same GLSL math as the displayed portrait with its float32
capture switch, draws into a 1×1 RGBA8 framebuffer and reads real and
imaginary components back independently; every value is checked against
the reference JavaScript implementation. The report shows the failure count,
worst absolute complex error, GL renderer/version, source commit and elapsed
time. For failures it also shows the exact first offending inputs. Screenshot
or copy the report back into the development conversation; there is no
automatic telemetry upload.

The APK source revision is embedded in `web/build-receipt.json` and checked
against the CI commit before publication. The existing `?smoke=1` startup
still tests a visible center pixel, independently of the 171-point test.
The browser-host CI result is not a physical C67 pass.

The version-2 package keeps exactly the same ID and stable test signer as the
working version-1 APK, allowing a normal Android update without uninstalling.
The package ID is `org.isomorphisms.dirichlet.viewer`; it does not replace L
or Wegert. The APK uses the stable, **publicly known and untrusted** Wegert
test signer at immutable commit `873d03e` and checks its certificate fingerprint.
It must never be treated as a production/security-trusted release key.

This experimental candidate remains **draft and unmerged** pending real
Flexible Pipes dispatch/delivery, independent ai-ci acceptance, licensing
qualification for any subsequently bundled Wegert shader, and physical device
acceptance. The preferred future native Android GLES route remains the
existing L NativeActivity architecture, not WebView as a substitute for it.
