/*
 * coi-serviceworker — adds Cross-Origin Isolation headers required by Godot 4 web exports.
 * Without these headers the browser blocks SharedArrayBuffer, and the game will not start.
 *
 * Based on: https://github.com/gzuidhof/coi-serviceworker
 *
 * HOW IT WORKS
 * On first page load this script registers itself as a service worker, then reloads the page.
 * From the second load onwards the service worker is active and injects the two required headers
 * (Cross-Origin-Opener-Policy and Cross-Origin-Embedder-Policy) into every response so the
 * browser treats the page as cross-origin isolated — no special server config needed.
 */

/* ── Self-registration (runs when loaded as a normal <script>) ── */
if (typeof window !== "undefined") {
    if ("serviceWorker" in navigator) {
        navigator.serviceWorker.register(window.location.pathname.replace(/[^/]*$/, "") + "coi-serviceworker.js")
            .then(function (reg) {
                /* If the worker just installed, reload so it can take control immediately */
                reg.addEventListener("updatefound", function () {
                    var worker = reg.installing;
                    worker.addEventListener("statechange", function () {
                        if (worker.state === "activated") {
                            window.location.reload();
                        }
                    });
                });

                /* Already active but page was not isolated — reload once */
                if (reg.active && !crossOriginIsolated) {
                    window.location.reload();
                }
            })
            .catch(function (err) {
                console.warn("coi-serviceworker: registration failed:", err);
            });
    } else {
        console.warn(
            "coi-serviceworker: Service workers are not supported in this browser. " +
            "The Godot game may not load. Try Chrome or Edge."
        );
    }
}

/* ── Service Worker event handlers (runs inside the SW context) ── */
if (typeof self !== "undefined" && typeof window === "undefined") {
    self.addEventListener("install", function () {
        self.skipWaiting();
    });

    self.addEventListener("activate", function (event) {
        event.waitUntil(self.clients.claim());
    });

    self.addEventListener("fetch", function (event) {
        /* Skip non-GET or opaque no-cors requests that would fail if re-fetched */
        if (event.request.method !== "GET") return;
        if (event.request.cache === "only-if-cached" && event.request.mode !== "same-origin") return;

        event.respondWith(
            fetch(event.request)
                .then(function (response) {
                    if (!response || response.status === 0 || response.type === "opaque") {
                        return response;
                    }
                    var headers = new Headers(response.headers);
                    headers.set("Cross-Origin-Opener-Policy", "same-origin");
                    headers.set("Cross-Origin-Embedder-Policy", "require-corp");
                    headers.set("Cross-Origin-Resource-Policy", "cross-origin");
                    return new Response(response.body, {
                        status: response.status,
                        statusText: response.statusText,
                        headers: headers,
                    });
                })
                .catch(function (err) {
                    console.warn("coi-serviceworker fetch error:", err);
                })
        );
    });
}
