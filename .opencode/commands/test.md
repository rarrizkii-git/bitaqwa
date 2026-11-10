---
description: Run Flutter analysis and relevant tests without modifying code
agent: qa
---

Run quality checks for: $ARGUMENTS

Run `flutter analyze`, then `flutter test` or the relevant test files. Report results in severity order with file paths and line numbers. Separate confirmed failures from checks that could not run. Do not modify application code, tests, configuration, dependencies, or assets, and do not install packages. Only claim a check passed when the command completed successfully.
