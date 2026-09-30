# First draft specification

Implement a small Lean interpretation of the mechanism in Alperen Keleş's
[Abstractification](https://alperenkeles.com/documents/abstractification.pdf), read in full on
2026-09-30 (11 pages; SHA-256
`01f11a4c4ee0186effaf46ded10e42b2761cbb29d249e61b2bd6645357f3bf0c`).

The immutable boundary consists of a reference implementation, a surrounding sketch, an input
precondition, and an observation function. A replaceable fill has an ordinary Lean type. Installing
it requires a proof of agreement for **every** input covered by the precondition. A search candidate
and a tested candidate are not installed fills. Tests provide counterexamples and search guidance;
only proof-carrying installation supports the certified execution claim.

The first example adapts the paper's two-constant rightmost-zero bit sketch to an explicitly finite
8-bit word domain. The domain reduction must remain visible. A finite candidate driver will collect
counterexamples, reject incorrect fills, rank valid candidates under a stated toy cost model, and
retain the best one. This is bounded enumeration, with no paid inference or model calls. It is not a
reproduction of the paper's Rust allocation experiment or its wall-clock performance results.

A DSL will declare the immutable boundary. An `install%` elaborator will check a fill and its proof
against the expected installed type and reject admitted or axiom-dependent certificates outside the
stated trust policy. A draft hole will fail with its expected type and local context rather than
create `sorryAx`. The existing dirty `~/lean-holes` was inspected read-only; its code actions are
useful editing ideas, but it currently admits unfinished editor holes. No code is copied from it.

Next milestones: reference/sketch regression and negative controls; deterministic finite CEGIS;
proof-gated DSL installation; axiom audit; isolated CI; independent AI review. Later possibilities
include richer editor actions, a proposal-only external agent protocol, observer-based data
representations, and externally measured performance. These later items are speculative.

Direction and scope: Alok. Implementation and research assistance: OpenAI Codex (GPT-6.1 Sol, with
parallel AI research/implementation). The paper's ideas remain credited to Alperen Keleş and the
prior work he cites. No claim of human verification is made.
