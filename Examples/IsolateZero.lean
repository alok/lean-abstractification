import Abstractification.Core
import Std

/-!
# A certified two-hole sketch over all 8-bit words

This is a finite version of Figure 3 in Alperen Keleş's *Abstractification*. The fixed program
shape is `~(x + left) & (x + right)`, with two independently replaceable constants. `BitVec 8`
gives both additions wrapping semantics. The independent reference scans from the least
significant bit and returns the first zero bit's mask, or zero when there is no zero bit.

The certificate quantifies over every 8-bit word, not merely over recorded examples. It does
not claim the paper's full 32-bit result. Ordinary `decide` builds a kernel-checked proof over
this finite domain; no native evaluation axiom or external solver is used.
-/

namespace Examples.IsolateZero

open Abstractification

/-- The precise finite word width covered by this example. -/
abbrev Word := BitVec 8

/-- The two holes in the fixed expression, each independently ranging over every 8-bit word. -/
structure Fill where
  left : Word
  right : Word
  deriving Repr, DecidableEq

/-- Scan the listed bit positions in order and stop at the first zero bit. -/
def scan (x : Word) : List Nat → Word
  | [] => 0
  | i :: rest => if x.getLsbD i then scan x rest else (1 : Word) <<< i

/-- An independent executable reference: scan bit positions 0 through 7. -/
def reference (x : Word) : Word := scan x (List.range 8)

/-- The literal two-hole sketch; `BitVec` addition wraps modulo 256. -/
def sketch (fill : Fill) (x : Word) : Word :=
  ~~~(x + fill.left) &&& (x + fill.right)

/-- Explicit enumeration of the complete input domain, from 0 through 255. -/
def allInputs : List Word := (List.range 256).map (BitVec.ofNat 8)

theorem allInputs_length : allInputs.length = 256 := by
  simp [allInputs]

theorem allInputs_complete (x : Word) : x ∈ allInputs := by
  apply List.mem_map.mpr
  refine ⟨x.toNat, List.mem_range.mpr x.isLt, ?_⟩
  simp [BitVec.ofNat_toNat]

/-- Observe the entire output and impose no restriction on the 256 possible inputs. -/
def boundary : Boundary Word Word Fill Word where
  reference := reference
  sketch := sketch
  observe := id
  pre := fun _ ↦ True

/-- The paper's proposed hole values. -/
def goodFill : Fill := ⟨0, 1⟩

set_option maxRecDepth 2048 in
set_option maxHeartbeats 2000000 in
/-- Agreement over every one of the 256 input words, including overflow at 255. -/
theorem goodFill_equivalent : ∀ x : Word, sketch goodFill x = reference x := by
  decide

theorem goodFill_valid : boundary.Valid goodFill := by
  intro x _
  exact goodFill_equivalent x

/-- The optimized sketch can be installed only with its all-input correctness certificate. -/
def installed : Installed boundary := ⟨goodFill, goodFill_valid⟩

theorem installed_preserves (x : Word) : installed.run x = reference x :=
  installed.preserves x True.intro

/-- A deliberately incorrect proposal with both holes filled by zero. -/
def wrongFill : Fill := ⟨0, 0⟩

theorem wrongFill_counterexample : sketch wrongFill 0 ≠ reference 0 := by
  decide

theorem wrongFill_rejected : ¬ boundary.Valid wrongFill := by
  intro h
  exact wrongFill_counterexample (h 0 True.intro)

/-- At zero, the least significant zero is bit 0. -/
theorem zero_case : reference 0 = 1 ∧ sketch goodFill 0 = 1 := by
  decide

/-- The all-ones word has no zero bit, so both implementations return zero. -/
theorem allOnes_case : reference 255 = 0 ∧ sketch goodFill 255 = 0 := by
  decide

/-- Adding one to the maximum 8-bit word wraps to zero. -/
theorem wrapping_add : (255 : Word) + 1 = 0 := by
  decide

/-- A carry through seven low one bits isolates the remaining high zero bit. -/
theorem high_zero_case : reference 127 = 128 ∧ sketch goodFill 127 = 128 := by
  decide

end Examples.IsolateZero
