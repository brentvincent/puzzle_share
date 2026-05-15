# CLAUDE.md — puzzle_share

Project-specific instructions for Claude Code working in this repo.

## Helper extraction (pure-fn-first pattern)

When you find non-trivial inline decision logic inside a Flutter widget — multi-branch if/else chains, date/time math, predicates gating user-visible UI, duplicated checks across methods — extract it to a file-scope pure helper and pin every branch with tests. Quiet regressions (a reshuffle that demotes the rarer milestone, an off-by-one calendar gate, a dropped clamp) don't crash or fire events; tests are the only safety net.

The 5-step rubric:

1. **Extract to file scope.** Take every dependency as a named parameter — no `widget.*`, no `BuildContext`, no Flutter types in the signature beyond `DateTime`/`Color`/primitives.
2. **Delegate from the widget.** Original method becomes a one-liner that constructs named args from widget state.
3. **Doc-comment the why.** Explain which input wins when, what edge case the defensive guards protect against. This becomes the test plan.
4. **Pin every branch with tests.** One `test()` per branch in isolation, one per priority collision, one per defensive guard, one sweep invariant. Test file mirrors source path under `test/`.
5. **Commit + push immediately.** Single commit naming the helper and the gap it closes.

Apply to ≥3-branch decisions or non-obvious edge cases. Skip trivially-pure single-line ternaries (test would just re-state the implementation). Don't import Flutter from the helper. Don't add defensive guards the tests don't pin (they get removed in the next refactor as "dead code").

Full pattern doc with anti-patterns, reference implementation, and worked examples: `/Users/brent/My Drive/Projects/gameops/docs/helper-extraction-pattern.md`.

Proven 20× in Nonograms PixDojo (commits G1–G20, ~180 tests). Reference helpers: `lib/features/puzzle/widgets/completion_overlay.dart` (4 helpers), `lib/features/home/home_screen.dart` (3 streak/first-run gates), `lib/features/daily/daily_archive_screen.dart` (year-wrap calendar nav).
