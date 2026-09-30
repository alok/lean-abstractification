# lean-abstractification

A working Lean 4 research draft interpreting Alperen Keleş's
[Abstractification](https://alperenkeles.com/documents/abstractification.pdf). Our goal is to make the
paper's fixed sketch and replaceable holes explicit in Lean, with a proof required before a fill
becomes a certified implementation.

## Run the current artifact

Requires [elan](https://github.com/leanprover/elan). The toolchain is pinned to Lean 4.34.1; there are
no third-party Lean package dependencies.

```sh
lake build
lake exe abstractificationDemo
lake env lean Examples/Warmup.lean
```

The current increment includes a generic `Boundary`, proof-carrying `Installed` fills, and a small
infinite-domain doubling example. It kernel-checks that replacing repeated addition with a
multiplier hole filled by `2` preserves the declared output for every natural number. The proof and
implementation have no axiom dependencies, as reported by `#print axioms`.

This warmup exercises the boundary and installation contract. Next is an adaptation of the paper's
two-hole rightmost-zero-bit sketch to an explicit 8-bit domain, with a bounded counterexample-guided
search, a DSL, proof-gated elaboration, and negative controls. These are planned increments, not
claims about the current artifact. See [the design specification](docs/design.md).

## What the boundary means

The specification fixes the reference function, sketch, precondition, and observation function. The
search may propose only typed fills. A candidate that passes tests is still a tested candidate; an
installed fill carries a proof of observational agreement on every input covered by the precondition.
That theorem does not establish that the chosen specification captures the user's intent.

The paper proposes both tests and formal verifiers with different assurance levels. Its current Rust
prototype uses generated differential tests; Verus verification, performance fuzzing, and production
replay are future work. This draft explores a Lean proof gate and does not reproduce its allocation
benchmarks or claim speedups.

## Attribution and status

Direction and scope: **Alok**. Implementation and research assistance: **OpenAI Codex, GPT-6.1 Sol**,
including parallel AI assistance. This is our research draft; no human verification is claimed.
The abstractification proposal is **Alperen Keleş's**, building on the sketching, synthesis, contracts,
and testing literature cited in his paper. See [NOTICE](NOTICE) for sources and reuse status.

The dirty local `lean-holes` work was inspected read-only for Agda-style editing ideas. No code from
it or the paper's Rust implementation is vendored. This project is original Lean code under MIT.
It is an early prototype, not a production autonomous optimizer or a Lean compiler modification.
