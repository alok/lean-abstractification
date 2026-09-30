# Design and research scope

The paper's §3 distinguishes a hole/specification boundary, correctness verifiers, and an optimizer
whose proposals are limited to holes. This draft models those parts with ordinary Lean data and
proof-carrying installation.

## Boundary and fills

`Boundary Input Output Fill Observation` fixes the reference, sketch, precondition, and observer.
`Boundary.Valid fill` means agreement for every input satisfying the precondition. `Installed`
contains a fill plus that proof. The surrounding program and verifiers are not candidate data.
Observer equality makes the scope of preservation explicit; choosing a weaker observer also weakens
the guarantee. The current bit example observes the entire returned word and has precondition `True`.

Named structure fields are typed holes in the program sketch, rather than unresolved Lean goals.
The first example has `Fill.left` and `Fill.right`, both `BitVec 8`. Its reference scans all eight bit
positions independently of the bit-expression implementation. `decide` constructs the finite
all-input certificate. Explicit input enumeration is proved complete, not merely asserted to cover
the domain. The search example adds a closed `Plan` selecting scan or a filled mask expression;
whole-body and constant holes illustrate two granularities discussed by the paper.

## Proposals, testing, ranking, certification

`SearchState.best` is a tested candidate. `consider` checks the current corpus, then the supplied
verifier list. Counterexamples extend the corpus; failures carry no score. Only after correctness
tests pass does the fixed cost function run. Strict improvement replaces the best candidate; ties
retain it. The proposal list is a deterministic finite pool. Counterexamples filter this pool before
full verification; there is no adaptive LLM synthesizer.

`certify` is deliberately separate. It requires a decision procedure for `Boundary.Valid`, not merely
for agreement on the supplied verifier list. On success it returns an `Installed` with the actual
proof. Generic validity need not be decidable; other applications can instead submit a proof through
`install%`. The incomplete-replay negative control demonstrates the distinction concretely.

The cost model counts one reference bit inspection or four operations per mask expression. Workload
fixtures change which correct implementation wins. This omits compiler simplifications, real timing,
allocation, code size, cache effects, and statistical acceptance. It is a model demonstration rather
than an experimental performance claim.

## Elaboration and editor holes

`abstractify` is a macro for declarative boundary syntax. `install%` uses its expected `Installed`
type to elaborate a fill and proof. It resolves metavariables and audits constants plus their
transitive axiom dependencies, the whole installed type, and reachable local declarations and their
let values. The allowlist is the standard Lean axioms `propext`, `Classical.choice`, and `Quot.sound`.
The finite bit proof uses only the first and third. The Nat doubling proof uses none.

`draft_hole% name` gives the expected type and local context in a failing diagnostic. Draft code
therefore cannot silently become an executable admitted value. Agda-style refinement, case splitting,
InfoTree metadata, and code actions could build on this. We have not implemented those editor flows
or rewritten the existing interactive-hole package.

The audit is a policy check in a trusted Lean project. It does not isolate arbitrary macro/tactic
execution, prohibit users from changing a boundary, or verify compiled substitutions/foreign code.
The closed proposal data used by the demo is a practical restriction; a future external proposer
should submit validated data or patches limited to designated fills, while the specification and
verifier are protected outside that proposer's write scope.

## Next research increments

- Prove the bit sketch for arbitrary widths or the paper's 32-bit domain without exhaustive search.
- Add observer-based data-representation examples and operation-trace contracts.
- Add editor integration while keeping draft obligations separate from certified execution.
- Design a proposal-only external agent protocol with a protected verifier and proof replay.
- Measure compiled candidates in a controlled benchmark, with workload and runtime observables
  spelled out, before making performance claims.

These are planned research directions. No paid inference, GPUs, new credentials, or external
optimization services are needed for the current artifact.
