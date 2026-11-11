{{flutter_js}}
{{flutter_build_config}}

// Bitaqwa — custom Flutter web bootstrap (PWA Phase 2B, bridge in Phase 2D).
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

// ---------------------------------------------------------------------------
// PWA lifecycle bridge — Phase 2D, step 1.
//
// Bitaqwa's service worker is registered here (see sw.js for the cache
// strategy), and the browser lifecycle around it is exposed to Flutter as
// `window.bitaqwaPwa`. The Dart side reaches it through
// lib/core/utils/pwa_bridge_web.dart.
//
// Guarantees enforced here:
//   * No additional service worker is ever registered.
//   * `skipWaiting()` is only requested by `applyUpdate()`, which the Flutter
//     UI calls after an explicit user action. Nothing activates on its own.
//   * The page never reloads on a first installation: `hadController` is
//     captured before registration, so the `controllerchange` caused by
//     `clients.claim()` is ignored.
//   * A reload happens only after an approved update activated, and a
//     sessionStorage timestamp plus a local flag stop a reload loop.
//   * Every listener is isolated, so a failure here can never stop Flutter.
//
// The URL and scope are absolute so the SPA's deep routes (e.g. /quran/36)
// always register the worker for the whole origin. `updateViaCache: 'none'`
// keeps update checks from being satisfied by the HTTP cache. Registration
// failure is non-fatal: the app runs fine without offline support.
// ---------------------------------------------------------------------------
(function () {
  'use strict';

  try {
    const RELOAD_GUARD_KEY = 'bitaqwa.pwa.reload_at';
    const RELOAD_GUARD_WINDOW_MS = 10000;

    const state = {
      updateReady: false,
      install: 'unavailable',
      standalone: false,
      offline: false,
    };

    const listeners = [];
    let installEvent = null;
    let installPending = false;
    let registration = null;
    let updateApproved = false;
    let reloading = false;

    function isStandalone() {
      try {
        if (
          window.matchMedia &&
          window.matchMedia('(display-mode: standalone)').matches
        ) {
          return true;
        }
      } catch (error) {
        // matchMedia is unavailable in some embedded webviews.
      }
      try {
        // Safari-only flag; not exposed by package:web.
        if (window.navigator.standalone === true) return true;
      } catch (error) {
        // Ignore: the property does not exist outside iOS Safari.
      }
      return false;
    }

    function snapshot() {
      return {
        updateReady: state.updateReady === true,
        install: state.install,
        standalone: state.standalone === true,
        offline: state.offline === true,
      };
    }

    function emit() {
      const payload = snapshot();
      for (let i = 0; i < listeners.length; i++) {
        try {
          listeners[i](payload);
        } catch (error) {
          // A failing Dart listener must not break the browser lifecycle.
        }
      }
    }

    function update(patch) {
      let changed = false;
      for (const key in patch) {
        if (
          Object.prototype.hasOwnProperty.call(patch, key) &&
          state[key] !== patch[key]
        ) {
          state[key] = patch[key];
          changed = true;
        }
      }
      if (changed) emit();
    }

    // Initial snapshot.
    state.standalone = isStandalone();
    if (state.standalone) state.install = 'installed';
    state.offline = navigator.onLine === false;

    // Public bridge surface. `state` is a getter so reading the property
    // yields a fresh snapshot object rather than a function reference.
    window.bitaqwaPwa = {
      get state() {
        return snapshot();
      },
      subscribe: function (listener) {
        if (typeof listener !== 'function') return;
        listeners.push(listener);
        try {
          listener(snapshot());
        } catch (error) {
          // The initial emission is best-effort.
        }
      },
      unsubscribe: function (listener) {
        const index = listeners.indexOf(listener);
        if (index !== -1) listeners.splice(index, 1);
      },
      promptInstall: function () {
        if (!installEvent || installPending) return false;
        installPending = true;
        const event = installEvent;
        installEvent = null; // a beforeinstallprompt event is single-use
        try {
          event.prompt();
        } catch (error) {
          installPending = false;
          return false;
        }
        try {
          const choice = event.userChoice;
          if (choice && typeof choice.then === 'function') {
            choice
              .then(function (result) {
                installPending = false;
                const accepted = result && result.outcome === 'accepted';
                update({
                  install:
                    accepted || isStandalone() ? 'installed' : 'unavailable',
                });
              })
              .catch(function () {
                installPending = false;
              });
          } else {
            installPending = false;
          }
        } catch (error) {
          installPending = false;
        }
        return true;
      },
      applyUpdate: function () {
        const current = registration;
        if (!current || !current.waiting) return false;
        updateApproved = true;
        try {
          current.waiting.postMessage({ type: 'SKIP_WAITING' });
        } catch (error) {
          updateApproved = false;
          return false;
        }
        return true;
      },
      checkForUpdate: function () {
        const current = registration;
        if (!current || typeof current.update !== 'function') return false;
        try {
          const pending = current.update();
          if (pending && typeof pending.catch === 'function') {
            pending.catch(function () {});
          }
        } catch (error) {
          return false;
        }
        return true;
      },
    };

    window.addEventListener('online', function () {
      update({ offline: false });
    });
    window.addEventListener('offline', function () {
      update({ offline: true });
    });

    window.addEventListener('beforeinstallprompt', function (event) {
      if (state.install === 'installed') return;
      try {
        event.preventDefault();
      } catch (error) {
        // Ignore: the browser may refuse to cancel its default prompt.
      }
      installEvent = event;
      installPending = false;
      update({ install: 'available' });
    });

    window.addEventListener('appinstalled', function () {
      installEvent = null;
      installPending = false;
      update({ install: 'installed' });
    });

    if ('serviceWorker' in navigator) {
      // Captured before registration: a first visit has no controller, and
      // sw.js calls clients.claim() when it activates, which fires
      // `controllerchange` for that first install. Reloading there would
      // reload every new visitor, so that first event is ignored. The flag
      // then flips, because later changes in the same page are real updates.
      let hadController = Boolean(navigator.serviceWorker.controller);

      navigator.serviceWorker.addEventListener(
        'controllerchange',
        function () {
          if (!hadController) {
            // First installation: the initial claim is not an update.
            hadController = true;
            return;
          }
          // Activation only ever follows an approved update, either from this
          // tab or from another tab that approved it. Without either signal
          // the browser replaced the worker on its own, so stay put.
          if (!updateApproved && !state.updateReady) return;
          if (reloading) return;
          reloading = true;
          try {
            const now = Date.now();
            const last = Number(
              window.sessionStorage.getItem(RELOAD_GUARD_KEY) || 0,
            );
            if (now - last < RELOAD_GUARD_WINDOW_MS) return;
            window.sessionStorage.setItem(RELOAD_GUARD_KEY, String(now));
          } catch (error) {
            // Storage can be unavailable (private mode); `reloading` still
            // prevents a loop within this page.
          }
          window.location.reload();
        },
      );

      navigator.serviceWorker
        .register('/sw.js', { scope: '/', updateViaCache: 'none' })
        .then(function (registered) {
          registration = registered;

          // A worker can already be waiting when the page is opened after an
          // earlier visit that never approved the update.
          if (registered.waiting && navigator.serviceWorker.controller) {
            update({ updateReady: true });
          }

          registered.addEventListener('updatefound', function () {
            const worker = registered.installing;
            if (!worker) return;
            worker.addEventListener('statechange', function () {
              if (
                worker.state === 'installed' &&
                navigator.serviceWorker.controller
              ) {
                update({ updateReady: true });
              }
            });
          });
        })
        .catch(function (error) {
          console.warn('Bitaqwa: service worker registration failed:', error);
        });
    }
  } catch (error) {
    // The bridge is optional: Flutter has already been asked to start above.
    console.warn('Bitaqwa: PWA bridge unavailable:', error);
  }
})();
