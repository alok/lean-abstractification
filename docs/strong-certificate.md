# Width-parametric bit-sketch certificate

[Examples/IsolateZeroWidths.lean](../Examples/IsolateZeroWidths.lean) proves Figure 3's filled sketch
correct for every `w : Nat` and `x : BitVec w`. The public reference scans ascending positions
`0 .. w-1`, returning the first zero bit's mask or zero if there is none. The sketch is
`~~~(x + 0#w) &&& (x + 1#w)`, with finite-width complement, AND, and wrapping addition.

```lean
theorem goodFill_equivalent {w : Nat} (x : BitVec w) :
    sketch (goodFill w) x = reference x

theorem exact32 (x : BitVec 32) :
    sketch (goodFill 32) x = reference x
```

## Assumptions and observations

The installed boundary observes the entire returned word and has precondition `True`. There is no
positivity, no-overflow, or input restriction. Width zero returns the unique empty word. At width 32,
`BitVec 32` models the paper's unsigned arithmetic; this does not verify Rust compilation or runtime
refinement. The all-zero wrong fill has a zero-input counterexample at every **positive** width; it
is valid at width zero, so its rejection theorem explicitly requires `0 < w`.

## Proof structure

1. Show that a shifted one-bit mask extends by appending a zero low bit. Relate a scan over shifted
   positions to a scan of the shorter high-bit tail, and derive the positional loop's decomposition.
2. Prove the two wrapping increment steps: a zero low bit stops the carry; a one low bit carries into
   the tail modulo its width. These steps include overflow through the all-ones word.
3. Induct on a word's width and low-bit concatenation to show the filled sketch equals a recursive
   scan helper. Separately prove that helper equals the public positional-loop reference.
4. Compose the two proofs. `installed w` packages the result through the audited `install%` elaborator;
   `installed32` specializes it directly, with no domain decision procedure.

The universal proof uses no input enumeration, SAT solver, native evaluation, or custom axiom.
Its explicit axiom audit reports only `propext`, `Classical.choice`, and `Quot.sound`. The full check
script audits installation and replays project modules with the toolchain's separate `leanchecker`.
Ordinary `decide` is used only for small concrete regression inputs in `Tests/Strong.lean`.

## Compatibility and evidence

The original 8-bit example is unchanged. `reference_eight_compatible` proves the new and old positional
references equal. Regression tests cover zero, all ones, high-bit carry, alternating words, width zero,
and wrong-fill rejection. Negative compilation fixtures reject a wrong 32-bit fill, an 8-bit fill at
the 32-bit boundary, and a false all-ones result. Separate Codex AI review independently checked the
proof path, axiom dependencies, and compatibility; see [verification](verification.md).

The search demo still uses eight-bit inputs and an explicit toy operation count. Extending correctness
to all widths establishes no measured machine performance, speedup, allocation behavior, or compiler
correctness.
