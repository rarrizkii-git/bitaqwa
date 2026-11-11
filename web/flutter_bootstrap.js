{{flutter_js}}
{{flutter_build_config}}

// Bitaqwa — custom Flutter web bootstrap (PWA Phase 2B).
//
// This mirrors what Flutter 3.44.7 generates by default, with two deliberate
// differences:
//
//   1. No `serviceWorkerSettings`. Flutter's built-in service worker
//      (`flutter_service_worker.js`) is a deprecated cleanup stub that
//      unregisters itself and reloads every open tab. Registering it would
//      fight Bitaqwa's own worker, so the setting is omitted entirely and
//      the loader never touches `navigator.serviceWorker` on its own.
//
//   2. CanvasKit is loaded from this origin (`/canvaskit/`). Flutter's
//      default resolves CanvasKit from gstatic using the engine revision,
//      which would keep the renderer outside the service worker's
//      same-origin caching strategy and break offline support.
//
// `load()` is called without `onEntrypointLoaded`, preserving the loader's
// default behavior for this Flutter version: the build configuration is
// forwarded automatically to `initializeEngine()`, which then runs the app.
// The splash screen in index.html is driven by the engine's
// `flutter-first-frame` event and needs no changes here.

_flutter.loader.load({
  config: {
    canvasKitBaseUrl: '/canvaskit/',
  },
});

// Register Bitaqwa's service worker (see sw.js for the cache strategy).
// The URL and scope are absolute so the SPA's deep routes (e.g. /quran/36)
// always register the worker for the whole origin. `updateViaCache: 'none'`
// keeps update checks from being satisfied by the HTTP cache. Registration
// failure is non-fatal: the app runs fine without offline support.
if ('serviceWorker' in navigator) {
  navigator.serviceWorker
    .register('/sw.js', { scope: '/', updateViaCache: 'none' })
    .catch((error) => {
      console.warn('Bitaqwa: service worker registration failed:', error);
    });
}
