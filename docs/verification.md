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
- Width-parametric equivalence against the positional scan, exact 32-bit specialization, and direct
  audited installation of the inductive certificate. No input-domain enumeration or solver is used.
- Compatibility with the old 8-bit reference, width-zero behavior, and the necessary positive-width
  premise for rejecting the all-zero wrong fill.
- Concrete 32-bit zero, all-ones, carry, alternating-word, and modular-wrap regression checks.
- Kernel proofs of the long- and short-workload winners and their certificate-gate success.
- Replay-only acceptance of a deliberately bad candidate, followed by certificate rejection.
- Explicit installed-declaration audits and separate `leanchecker` replay of the project modules.
- Fourteen compile-failure controls: direct/indirect/local admissions, direct/local/hidden-boundary
  axioms, wrong fill, wrong type, unresolved draft hole, native-decision trust, and direct constructor
  followed by audit, plus a wrong 32-bit fill, a fill-width mismatch, and a false overflow result.
  The test runner checks diagnostic fragments, so an unrelated import failure cannot count as a
  successful rejection.

The original eight-bit proof and search certificates report `[propext, Quot.sound]`. The stronger
all-width theorem, exact 32-bit specialization, and installed certificate report
`[propext, Classical.choice, Quot.sound]`; the recursive-to-positional bridge reports
`[propext, Quot.sound]`. Nat doubling reports no axioms. The policy permits those three standard Lean
axioms and rejects `sorryAx` and other axioms. Negative fixtures intentionally contain rejected
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

A separate review of the width-parametric increment found no blocker. The reviewer compiled a fresh
copy of the new source plus independent audit and compatibility checks on Lean 4.34.1. It checked the
paper's positional-loop semantics, the wrapping increment lemmas, the recursive-to-loop bridge,
width zero, and the positive-width premise on wrong-fill rejection. It independently proved the new
installed 8-bit execution agrees with the old installation and that the wrong fill is valid at width
zero. The old 8-bit module was unchanged. Explicit audits confirmed the axiom dependencies above;
the review did not substitute for the full check script or CI.

## CI and evidence limits

[The Lean workflow](https://github.com/alok/lean-abstractification/actions/workflows/lean.yml) repeats
these checks on a Linux runner. Its badge/run pages provide current status; a configured workflow
alone is not evidence of a completed CI run. The initial public artifact was commit
`960dadeb7c7eea07ef9317c8c8a673cf31770c2d`; later commits add the reviewed implementation and controls.

The correctness certificate now covers every finite bit width, including exactly 32 bits. The search
and ranking demo still uses 8-bit inputs, closed candidate data, a deterministic pool, and toy costs.
No statistical performance result, complete Agda-style editor, upstream port, Rust runtime refinement,
or production autonomous optimizer is claimed. Axioms in raw Lean constructions must still be
audited; Lean elaboration is trusted code, not an OS sandbox, and logical certificates do not
independently certify runtime substitutions or the compiler.
