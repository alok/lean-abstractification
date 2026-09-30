# Primary sources and reuse

Sources checked on 2026-09-30 by Codex AI research assistance. The paper was read in full before
implementation (11 pages). This is a source review, not human verification.

## Paper provenance

Alperen Keleş, [Abstractification](https://alperenkeles.com/documents/abstractification.pdf), preprint.
The downloaded PDF is 341,536 bytes, SHA-256
`01f11a4c4ee0186effaf46ded10e42b2761cbb29d249e61b2bd6645357f3bf0c`.
It is byte-for-byte identical to the
[pinned PDF in the author's website repository](https://github.com/alpaylan/website-zola/blob/0f239ef9b4817668c09254c8e00ce19e797ec4d4/static/documents/abstractification.pdf).
The paper has one named author; the proposed programming model and its reported results remain
credited to him and the prior work cited there.

The actual prototype described in §3 generates proptest harnesses and uses handwritten benchmarks.
Agent-driven Verus proofs, performance fuzzing, and production replay remain future work. Its
`str::replacen` capacity example preserves successful returned strings while allocation failures,
memory use, and time remain observable. The Lean draft does not reproduce its timing experiment.

No public official implementation was found in a bounded search of the author's website and
publications, all 250 public repositories on the author's GitHub account, likely source trees, and
owner-scoped/global GitHub searches. The paper has no implementation-repository link. This does not
exclude an artifact under another name, owner, or unindexed branch. The author's
[crabcheck](https://github.com/alpaylan/crabcheck/tree/69d76e5cfcd2bce8cc22dcb59652a0efb9b1cfe5) is
related property-testing work, not an identified source for this prototype. The official prototype's
license is unknown. No upstream code or paper PDF is redistributed here.

The rightmost-zero sketch is adapted from the paper's Figures 2–3, which credit Armando Solar-Lezama's
[2008 dissertation](https://people.csail.mit.edu/asolar/papers/thesis.pdf). The new artifact formalizes
that example at an explicitly smaller 8-bit domain; it makes no novelty claim for the bit expression.

## Typed editing holes and trust

- [Lean holes](https://lean-lang.org/doc/reference/latest/Terms/Holes/): unification placeholders and
  synthetic opaque goals provide elaboration assistance. A synthesis boundary still needs its own
  fixed specification and acceptance procedure.
- [Lean axioms](https://lean-lang.org/doc/reference/latest/Axioms/),
  [sorry detection](https://github.com/leanprover/lean4/blob/82fdd8ea67911b4590015937284ad5ba97015782/src/Lean/Util/Sorry.lean), and
  [transitive axiom collection](https://github.com/leanprover/lean4/blob/82fdd8ea67911b4590015937284ad5ba97015782/src/Lean/Util/CollectAxioms.lean)
  explain why direct syntax checks alone are insufficient. This draft calls Lean's APIs through the
  pinned 4.34.1 toolchain; these public source links identify a separately inspected upstream revision.
- [Agda holes](https://agda.readthedocs.io/en/latest/language/lexical-structure.html#holes),
  [editing commands](https://agda.readthedocs.io/en/latest/tools/emacs-mode.html), and
  [Safe Agda](https://agda.readthedocs.io/en/latest/language/safe-agda.html) distinguish interactive
  obligations from completed safe programs. Agda's `abstract` visibility mechanism is separate from
  selecting optimized fills.
- [brendanzab/lean-holes](https://github.com/brendanzab/lean-holes) and
  [alok/lean-holes](https://github.com/alok/lean-holes) were inspected for editing architecture. Their
  unfinished interactive holes can elaborate to `sorryAx`. No code from them is copied here.

## License review

The new original Lean code is MIT licensed. Lean is an external toolchain with
[Apache-2.0 licensing](https://github.com/leanprover/lean4/blob/82fdd8ea67911b4590015937284ad5ba97015782/LICENSE).
Agda's [inspected license](https://github.com/agda/agda/blob/cabd583dda7d7e2e4b079a9c5f80e29890a65b25/LICENSE)
contains MIT permission text, and crabcheck is
[MIT licensed](https://github.com/alpaylan/crabcheck/blob/69d76e5cfcd2bce8cc22dcb59652a0efb9b1cfe5/LICENSE).
Neither is a dependency or vendored implementation. CI references GitHub checkout and the official
Lean action at fixed revisions; their code and licenses remain upstream. No explicit paper
redistribution license was located, so this repository links and attributes it.
