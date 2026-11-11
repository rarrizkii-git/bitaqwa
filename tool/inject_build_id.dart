// Bitaqwa PWA — Phase 2B build-ID injector.
//
// Replaces the single `__BUILD_ID__` placeholder in the built service worker
// (build/web/sw.js, copied there verbatim by `flutter build web`) with a
// unique build identifier:
//
//   "<git-commit-sha>-<unix-epoch-seconds>"
//
// The build ID versions the service worker's build-scoped caches
// (bitaqwa-shell-v* / bitaqwa-runtime-v*), so every deployment is a new,
// self-consistent cache generation and an old app shell is never served with
// new assets. Flutter 3.44.7 has no --web-content-hash behavior that could
// provide this, hence this post-build step.
//
// The identifier must match the DEV_MODE pattern in web/sw.js:
// ^[0-9a-f]{40}-[0-9]+$. Keep both in sync.
//
// Usage:
//   dart tool/inject_build_id.dart [path-to-sw-js]
//
// Exits non-zero (and therefore fails the Vercel build) if the placeholder
// is missing, appears more than once, or cannot be verified after writing,
// so a build can never silently ship the placeholder.

import 'dart:io';

const String placeholder = '__BUILD_ID__';
final RegExp buildIdPattern = RegExp(r'^[0-9a-f]{40}-[0-9]+$');

Future<void> main(List<String> args) async {
  final swPath = args.isNotEmpty ? args.first : 'build/web/sw.js';
  final swFile = File(swPath);

  if (!await swFile.exists()) {
    stderr.writeln('inject_build_id: service worker not found: $swPath');
    stderr.writeln('inject_build_id: run `flutter build web --release` first.');
    exit(1);
  }

  final buildId = await computeBuildId();
  if (!buildIdPattern.hasMatch(buildId)) {
    stderr.writeln('inject_build_id: computed build ID is malformed: $buildId');
    exit(1);
  }

  final original = await swFile.readAsString();
  final occurrences = placeholder.allMatches(original).length;
  if (occurrences != 1) {
    stderr.writeln(
      'inject_build_id: expected exactly 1 placeholder in $swPath, '
      'found $occurrences. Refusing to inject.',
    );
    exit(1);
  }

  await swFile.writeAsString(original.replaceFirst(placeholder, buildId));

  // Verify the written file: the placeholder must be gone, and the BUILD_ID
  // constant must now hold the injected identifier.
  final result = await swFile.readAsString();
  final hasPlaceholder = result.contains(placeholder);
  final hasInjectedConstant = result.contains("const BUILD_ID = '$buildId';");
  if (hasPlaceholder || !hasInjectedConstant) {
    stderr.writeln('inject_build_id: verification failed for $swPath.');
    stderr.writeln(
      'inject_build_id: placeholder still present: $hasPlaceholder',
    );
    stderr.writeln(
      'inject_build_id: BUILD_ID constant updated: $hasInjectedConstant',
    );
    exit(1);
  }

  stdout.writeln('inject_build_id: BUILD_ID=$buildId');
  stdout.writeln('inject_build_id: injected into $swPath');
}

/// "`<git-commit-sha>`-`<unix-epoch-seconds>`" — deterministic per commit,
/// unique per build.
Future<String> computeBuildId() async {
  final sha = await gitSha();
  final epochSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return '$sha-$epochSeconds';
}

Future<String> gitSha() async {
  final result = await Process.run('git', ['rev-parse', 'HEAD']);
  if (result.exitCode != 0) {
    stderr.writeln('inject_build_id: `git rev-parse HEAD` failed:');
    stderr.writeln(result.stderr);
    exit(1);
  }
  return (result.stdout as String).trim();
}
