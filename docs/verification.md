# Verification and independent AI review

This is evidence from automated Lean checks and separate Codex AI review. It is not a record of
human verification or approval of the specification.

## Reproduce

```sh
sh scripts/check.sh
```

The script builds the executable and both libraries, audits the installed examples, replays project
modules with the toolchain's separate `leanchecker`, checks every negative fixture for its intended
failure, and runs the complete search demo. Python 3 is used only to interpret compile results.

Local validation on macOS with Lean 4.34.1 passed for this implementation increment:

- Generic observation-preservation theorem and infinite-domain Nat doubling certificate.
- Independent scanning reference and literal two-hole bit sketch over all 256 eight-bit words.
- Enumeration length/completeness, correct fill, wrong-fill counterexample, and overflow/carry edges.
- Kernel proofs of the long- and short-workload winners and their certificate-gate success.
- Replay-only acceptance of a deliberately bad candidate, followed by certificate rejection.
- Explicit installed-declaration audits and separate `leanchecker` replay of the project modules.
- Eleven compile-failure controls: direct/indirect/local admissions, direct/local/hidden-boundary
  axioms, wrong fill, wrong type, unresolved draft hole, native-decision trust, and direct constructor
  followed by audit. The test runner checks diagnostic fragments, so an unrelated import failure
  cannot count as a successful rejection.

The accepted bit proof and search certificates report `[propext, Quot.sound]`. Nat doubling reports
no axioms. The policy permits the three standard Lean axioms `propext`, `Classical.choice`, and
`Quot.sound`; it rejects `sorryAx` and other axioms. Negative fixtures intentionally contain rejected
admissions and invented axioms and are not imported by implementation libraries.

## Review findings and repair

A separate GPT-6.1 Sol AI reviewer examined the full paper, provenance, Core/DSL/Search, and both
bit/search examples. It found a real installation-audit defect: a reachable local `let` could hide a
custom false axiom or admission from a constants-only expression scan. The repaired audit traverses
reachable free-variable declarations, their types, and let values, resolving metavariables and
preventing repeated traversal. Direct/local regression fixtures are in the permanent test suite;
the reviewer also independently checked a nested-local case in an isolated temporary probe.
A legitimate local let-bound certificate remains accepted.

The reviewer also noted that an initial certification theorem did not use its result-equality premise.
It was replaced by `certify_fill`, which proves the certified fill is the actual proposal. The
reviewer's isolated current-Core/DSL/Search regression file compiled successfully on Lean 4.34.1.
No blocking finding remained within the declared finite, trusted-project scope.

## CI and evidence limits

[The Lean workflow](https://github.com/alok/lean-abstractification/actions/workflows/lean.yml) repeats
these checks on a Linux runner. Its badge/run pages provide current status; a configured workflow
alone is not evidence of a completed CI run. The initial public artifact was commit
`960dadeb7c7eea07ef9317c8c8a673cf31770c2d`; later commits add the reviewed implementation and controls.

The reviewed specification is narrower than the paper's full program: 8-bit finite inputs, closed
candidate data, deterministic candidate pool, and toy operation costs. No 32-bit theorem, statistical
performance result, complete Agda-style editor, upstream port, or production autonomous optimizer
is claimed. Axioms in raw Lean constructions must still be audited; Lean elaboration is trusted code,
not an OS sandbox, and logical certificates do not independently certify runtime substitutions or
the compiler.
