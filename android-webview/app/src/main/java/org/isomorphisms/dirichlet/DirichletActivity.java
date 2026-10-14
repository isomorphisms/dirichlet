package org.isomorphisms.dirichlet;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.webkit.ConsoleMessage;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import java.io.IOException;
import java.io.InputStream;
import java.util.Locale;

public final class DirichletActivity extends Activity {
    private static final String TAG = "DirichletC67";
    private static final String HOST = "appassets.androidplatform.net";
    private static final String HOME =
        "https://" + HOST + "/web/index.html?model=2&character=4&smoke=1";
    private WebView browser;

    private static WebResourceResponse missing() {
        WebResourceResponse response = new WebResourceResponse(
            "text/plain", "UTF-8",
            new java.io.ByteArrayInputStream("Asset not found".getBytes(java.nio.charset.StandardCharsets.UTF_8))
        );
        response.setStatusCodeAndReasonPhrase(404, "Not Found");
        return response;
    }

    private static String mime(String name) {
        if (name.endsWith(".html")) return "text/html";
        if (name.endsWith(".mjs") || name.endsWith(".js")) return "text/javascript";
        if (name.endsWith(".css")) return "text/css";
        if (name.endsWith(".glsl") || name.endsWith(".frag.in")) return "text/plain";
        return "application/octet-stream";
    }

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        );

        browser = new WebView(this);
        browser.setBackgroundColor(0xff101419);
        browser.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        WebSettings settings = browser.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(false);
        settings.setAllowContentAccess(false);
        settings.setAllowFileAccessFromFileURLs(false);
        settings.setAllowUniversalAccessFromFileURLs(false);
        settings.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);
        settings.setTextZoom(100);

        browser.setWebChromeClient(new WebChromeClient() {
            @Override public boolean onConsoleMessage(ConsoleMessage message) {
                Log.i(TAG, "JS " + message.messageLevel() + " " + message.message());
                return true;
            }
        });
        browser.setWebViewClient(new WebViewClient() {
            @Override public WebResourceResponse shouldInterceptRequest(
                    WebView view, WebResourceRequest request) {
                if (!"https".equals(request.getUrl().getScheme())
                        || !HOST.equals(request.getUrl().getHost())) {
                    return super.shouldInterceptRequest(view, request);
                }
                String encodedPath = request.getUrl().getEncodedPath();
                if (encodedPath == null || !encodedPath.startsWith("/web/")
                        || encodedPath.contains("..")
                        || encodedPath.indexOf('%') >= 0
                        || encodedPath.indexOf('\\') >= 0) {
                    return missing();
                }
                String path = encodedPath.substring(1);
                try {
                    InputStream bytes = getAssets().open(path);
                    return new WebResourceResponse(mime(path), "UTF-8", bytes);
                } catch (IOException error) {
                    Log.e(TAG, "Missing APK asset: " + path, error);
                    return missing();
                }
            }
        });
        setContentView(browser);
        browser.loadUrl(HOME);
    }

    @Override public void onBackPressed() {
        if (browser != null && browser.canGoBack()) {
            browser.goBack();
        } else {
            super.onBackPressed();
        }
    }

    @Override protected void onDestroy() {
        if (browser != null) {
            browser.destroy();
            browser = null;
        }
        super.onDestroy();
    }
}
