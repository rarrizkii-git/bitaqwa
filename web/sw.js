/*
 * Bitaqwa service worker — PWA Phase 2B.
 *
 * Vanilla, dependency-free worker implementing Bitaqwa's caching strategy.
 *
 * Build identity
 * --------------
 * `BUILD_ID` below holds a placeholder in source form (and therefore during
 * `flutter run`, which serves web/ unmodified). After `flutter build web
 * --release`, tool/inject_build_id.dart replaces the single placeholder
 * occurrence with "<git-commit-sha>-<unix-epoch-seconds>".
 *
 * While the placeholder is unreplaced the worker is deliberately inert (dev
 * pass-through): it creates no caches and answers no fetch events, so local
 * development is never polluted with production-style caches.
 *
 * Cache layout
 * ------------
 *   bitaqwa-shell-v<BUILD_ID>    app shell (navigation responses)  build-scoped
 *   bitaqwa-runtime-v<BUILD_ID>  same-origin assets, CanvasKit     build-scoped
 *   bitaqwa-fonts-v1             Google Fonts                      persistent
 *   bitaqwa-quran-v1             api.alquran.cloud/v1 responses   persistent
 *
 * Build-scoped caches are keyed by BUILD_ID so an app shell is never served
 * alongside assets from a different build. Font and Qur'an caches hold
 * content that does not depend on the app build, so they persist across
 * updates and are never deleted during ordinary activation.
 *
 * Strategies
 * ----------
 *   Navigations & same-origin GETs    network-first, cache fallback
 *   CanvasKit (same-origin)           network-first, cache fallback
 *   Google Fonts (approved hosts)     cache-first
 *   Qur'an API (approved host)        network-first, FIFO-capped at 60 entries
 *   non-GET requests                  pass-through (never cached)
 *   YouTube / other cross-origin      pass-through (never cached)
 *
 * Offline behavior
 * ----------------
 * Navigations fall back to the cached app shell (never to a rewritten asset
 * URL), so missing static assets remain genuine 404s while SPA deep routes
 * keep working offline. If no shell has been cached yet, a minimal branded
 * offline page is served instead.
 *
 * Update lifecycle
 * ----------------
 * The worker never calls skipWaiting() on its own: a new build stays in the
 * waiting state until every tab of the previous build has closed, so an old
 * shell is never served mixed with new assets. A user-approved update
 * (Phase 2D) can opt in explicitly by posting a message:
 *
 *   navigator.serviceWorker.waiting.postMessage({ type: 'SKIP_WAITING' })
 *
 * and then reloading once on the page's 'controllerchange' event. Only the
 * obsolete build-scoped caches are removed on activation.
 */

'use strict';

const BUILD_ID = '__BUILD_ID__';

// tool/inject_build_id.dart writes "<40-hex git sha>-<epoch seconds>" and
// keeps this pattern in sync. While the placeholder above is unreplaced, the
// worker stays inert (see header).
const DEV_MODE = !/^[0-9a-f]{40}-[0-9]+$/.test(BUILD_ID);

// Build-scoped caches, deleted when a newer build activates.
const SHELL_CACHE = 'bitaqwa-shell-v' + BUILD_ID;
const RUNTIME_CACHE = 'bitaqwa-runtime-v' + BUILD_ID;

// Persistent caches, never deleted on activation.
const FONTS_CACHE = 'bitaqwa-fonts-v1';
const QURAN_CACHE = 'bitaqwa-quran-v1';

const QURAN_CACHE_MAX_ENTRIES = 60;

// Approved cross-origin hosts. Nothing outside these hosts is ever cached.
const QURAN_API_ORIGIN = 'https://api.alquran.cloud';
const QURAN_API_PATH_PREFIX = '/v1';
const FONT_ORIGINS = [
  'https://fonts.googleapis.com',
  'https://fonts.gstatic.com',
];

// App shell plus startup assets, warmed once on first activation.
// Registration races the app's own startup fetches: anything fetched before
// this worker took control would otherwise miss the cache on the very first
// visit, and offline support would only begin with the second visit. Both
// CanvasKit variants are warmed so first-visit offline works on every
// browser, not just the one that served the warm-up.
const WARMUP_SHELL_URL = '/';
const WARMUP_RUNTIME_URLS = [
  'flutter_bootstrap.js',
  'main.dart.js',
  'manifest.json',
  'favicon.png',
  'favicon-32.png',
  'apple-touch-icon.png',
  'assets/AssetManifest.bin',
  'assets/AssetManifest.bin.json',
  'assets/FontManifest.json',
  'assets/fonts/MaterialIcons-Regular.otf',
  'assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
  'assets/assets/fonts/Fraunces-Medium.ttf',
  'assets/assets/fonts/Fraunces-SemiBold.ttf',
  'assets/assets/fonts/PlusJakartaSans-Regular.ttf',
  'assets/assets/fonts/Amiri-Regular.ttf',
  'assets/assets/images/brand_mark.svg',
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'canvaskit/chromium/canvaskit.js',
  'canvaskit/chromium/canvaskit.wasm',
];

// Served only when a navigation fails while offline and no app shell has
// been cached yet (the first visit going offline before warm-up finished).
// Uses the splash screen's mark and palette so the moment stays on-brand.
const OFFLINE_HTML = `<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Bitaqwa — Tidak ada koneksi</title>
<style>
  :root { color-scheme: light dark; }
  html, body {
    margin: 0; height: 100%; background: #FCFAF6; color: #202923;
    font-family: 'Segoe UI', system-ui, sans-serif;
  }
  body { display: grid; place-items: center; padding: 28px; text-align: center; }
  h1 { font-size: 20px; letter-spacing: -0.3px; margin: 18px 0 8px; }
  p { font-size: 14px; line-height: 1.65; color: #68746C; margin: 0 0 24px; }
  button {
    border: 0; border-radius: 12px; background: #126B4F; color: #FCFAF6;
    font-weight: 600; font-size: 14px; padding: 12px 26px; cursor: pointer;
  }
  @media (prefers-color-scheme: dark) {
    html, body { background: #07130F; color: #EAF2EE; }
    p { color: #99AEA3; }
  }
</style>
</head>
<body>
<div>
  <svg width="56" height="56" viewBox="0 0 64 64" fill="none" aria-hidden="true">
    <g stroke="#126B4F" stroke-width="2.6" stroke-linejoin="round">
      <rect x="13" y="13" width="38" height="38" rx="7"/>
      <rect x="13" y="13" width="38" height="38" rx="7" transform="rotate(45 32 32)"/>
      <circle cx="32" cy="32" r="7"/>
    </g>
    <circle cx="32" cy="32" r="2.6" fill="#C9A25E"/>
  </svg>
  <h1>Tidak ada koneksi</h1>
  <p>Bitaqwa memerlukan koneksi internet saat dimuat pertama kali.<br>
     Aktifkan koneksi lalu coba lagi.</p>
  <button onclick="location.reload()">Coba lagi</button>
</div>
</body>
</html>`;

// ---------------------------------------------------------------------------
// Fetch handling
// ---------------------------------------------------------------------------

self.addEventListener('fetch', (event) => {
  if (DEV_MODE) return; // development: pass everything straight to the network

  const request = event.request;

  // Only GET requests are ever served from cache.
  if (request.method !== 'GET') return;

  const url = new URL(request.url);

  // Qur'an API: network-first with a bounded FIFO cache.
  if (url.origin === QURAN_API_ORIGIN && url.pathname.startsWith(QURAN_API_PATH_PREFIX)) {
    event.respondWith(handleQuranApi(request));
    return;
  }

  // Approved Google Fonts hosts: cache-first.
  if (FONT_ORIGINS.indexOf(url.origin) !== -1) {
    event.respondWith(handleFonts(request));
    return;
  }

  // Same-origin (app shell, navigations, assets, CanvasKit): network-first.
  if (url.origin === self.location.origin) {
    event.respondWith(handleSameOrigin(request));
    return;
  }

  // Everything else (YouTube embeds and thumbnails, unknown cross-origin
  // hosts): plain pass-through, never cached.
});

/**
 * Network-first for the app shell, navigations, assets, and CanvasKit.
 * Successful responses update the cache; network failures fall back to it.
 * Navigations additionally fall back to the cached shell itself, so uncached
 * deep routes keep working offline without rewriting any asset request.
 */
async function handleSameOrigin(request) {
  const isNavigation = request.mode === 'navigate';
  const cache = await caches.open(isNavigation ? SHELL_CACHE : RUNTIME_CACHE);
  try {
    const response = await fetch(request);
    // Cache only successful, complete responses. Partial (range) responses
    // are skipped, and 404/500 responses are returned to the page as-is, so
    // missing static assets stay genuine 404s.
    if (response && response.ok && !request.headers.has('range')) {
      try {
        await cache.put(request, response.clone());
      } catch (e) {
        // A failed cache write must not break a successful network response.
      }
    }
    return response;
  } catch (error) {
    const cached = await cache.match(request);
    if (cached) return cached;

    if (isNavigation) {
      const shell = await cache.match('/');
      if (shell) return shell;
      return new Response(OFFLINE_HTML, {
        status: 200,
        headers: { 'Content-Type': 'text/html; charset=utf-8' },
      });
    }
    return new Response('', { status: 503, statusText: 'Offline' });
  }
}

/**
 * Network-first for the Qur'an API with a bounded FIFO cache. Offline, the
 * cached response is served; if the request was never cached, a 503 JSON
 * response is returned, which the app surfaces as a graceful in-app error.
 */
async function handleQuranApi(request) {
  const cache = await caches.open(QURAN_CACHE);
  try {
    const response = await fetch(request);
    if (response && response.ok) {
      try {
        await cache.put(request, response.clone());
      } catch (e) {
        // Non-fatal: the live response still goes to the app.
      }
      await trimQuranCache(cache);
    }
    return response;
  } catch (error) {
    const cached = await cache.match(request, { ignoreVary: true });
    if (cached) return cached;
    return new Response(
      JSON.stringify({ code: 503, status: 'Offline', data: null }),
      {
        status: 503,
        statusText: 'Offline',
        headers: { 'Content-Type': 'application/json' },
      },
    );
  }
}

/**
 * Keeps the Qur'an cache within QURAN_CACHE_MAX_ENTRIES using FIFO
 * eviction: cache.keys() yields keys in insertion order, so the oldest
 * entries are evicted first.
 */
async function trimQuranCache(cache) {
  const keys = await cache.keys();
  while (keys.length > QURAN_CACHE_MAX_ENTRIES) {
    const oldest = keys.shift();
    const deleted = await cache.delete(oldest);
    if (!deleted) break; // guard against a possible infinite loop
  }
}

/**
 * Cache-first for Google Fonts. Fonts are immutable per URL, so the network
 * is only consulted on a cache miss. Requests made without CORS (browser
 * @font-face loads) produce opaque responses whose status is 0, so both `ok`
 * and opaque responses are cached. Offline misses fail softly: the browser
 * renders with fallback fonts and the app keeps working.
 */
async function handleFonts(request) {
  const cache = await caches.open(FONTS_CACHE);
  const cached = await cache.match(request, { ignoreVary: true });
  if (cached) return cached;
  try {
    const response = await fetch(request);
    if (response && (response.ok || response.type === 'opaque')) {
      try {
        await cache.put(request, response.clone());
      } catch (e) {
        // Non-fatal.
      }
    }
    return response;
  } catch (error) {
    return new Response('', { status: 503, statusText: 'Offline' });
  }
}

// ---------------------------------------------------------------------------
// Lifecycle
// ---------------------------------------------------------------------------

self.addEventListener('activate', (event) => {
  if (DEV_MODE) return; // development: stay inert

  event.waitUntil(
    (async () => {
      // Remove only obsolete build-scoped caches. The persistent font and
      // Qur'an caches are deliberately never deleted here.
      const names = await caches.keys();
      await Promise.all(
        names.map((name) => {
          const buildScoped =
            name.startsWith('bitaqwa-shell-v') || name.startsWith('bitaqwa-runtime-v');
          const isCurrent = name === SHELL_CACHE || name === RUNTIME_CACHE;
          return buildScoped && !isCurrent ? caches.delete(name) : null;
        }),
      );

      // Take control of the page that registered this worker so its fetches
      // start flowing through the cache strategies immediately.
      await self.clients.claim();

      // Warm the startup set in the background (best-effort).
      await warmUp();

      console.info('[Bitaqwa] service worker active, build ' + BUILD_ID);
    })(),
  );
});

// The worker never skips waiting on its own (see "Update lifecycle" in the
// header). SKIP_WAITING is the explicit, user-approved opt-in hook that the
// Phase 2D update banner will use.
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

/**
 * Warms the app shell and startup assets so the very first visit is already
 * offline-capable. Best-effort: any failed fetch simply leaves that asset to
 * be cached the next time the app requests it. `cache: 'reload'` bypasses
 * the HTTP cache so build-scoped caches are always filled from the network,
 * never from a possibly stale disk cache.
 */
async function warmUp() {
  const runtime = await caches.open(RUNTIME_CACHE);
  const shell = await caches.open(SHELL_CACHE);

  const warm = async (cache, url) => {
    try {
      const response = await fetch(url, { cache: 'reload' });
      if (response.ok) {
        await cache.put(url, response);
      }
    } catch (e) {
      // Warming is best-effort.
    }
  };

  await Promise.all(WARMUP_RUNTIME_URLS.map((url) => warm(runtime, url)));
  await warm(shell, WARMUP_SHELL_URL);
}
