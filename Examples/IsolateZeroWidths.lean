import Abstractification.DSL
import Examples.IsolateZero
import Std

/-!
# A width-parametric certificate for the paper's rightmost-zero sketch

The public reference is the paper-shaped positional loop over bits `0 .. w-1`. A separate recursive
low-bit scan is used only to prove the result by width induction, and is proved equal to that loop.
The sketch uses explicit finite-width literals so additions wrap, including at the all-ones word.
No input enumeration, SAT solver, native decision, or extra arithmetic assumption is needed.
-/

namespace Examples.IsolateZeroWidths

open Abstractification

/-- The independent positional scan, stopping at the first listed zero bit. -/
def scan {w : Nat} (x : BitVec w) : List Nat → BitVec w
  | [] => 0
  | i :: rest => if x.getLsbD i then scan x rest else (1 : BitVec w) <<< i

/-- A shifted mask extends by appending a zero low bit. -/
theorem shifted_concat (w i : Nat) :
    ((1 : BitVec w) <<< i).concat false = (1 : BitVec (w + 1)) <<< (i + 1) := by
  ext j hj
  simp only [← BitVec.getLsbD_eq_getElem]
  cases j with
  | zero => simp
  | succ k =>
    have hk : k < w := by omega
    simp [hk, Nat.add_sub_add_right]

/-- Scanning shifted positions agrees with scanning the shorter high-bit tail. -/
theorem scan_map_succ {w : Nat} (x : BitVec (w + 1)) (xs : List Nat)
    (bound : ∀ i ∈ xs, i < w) :
    scan x (xs.map Nat.succ) = (scan (x.extractLsb' 1 w) xs).concat false := by
  induction xs with
  | nil => simp [scan]
  | cons i rest ih =>
    have hi : i < w := bound i (by simp)
    have hrest : ∀ j ∈ rest, j < w := fun j hj ↦ bound j (by simp [hj])
    have hbit : (x.extractLsb' 1 w).getLsbD i = x.getLsbD (i+1) := by
      simp [hi, Nat.add_comm]
    simp only [List.map_cons, scan, hbit]
    split
    · exact ih hrest
    · exact (shifted_concat w i).symm

/-- The paper-shaped positional loop obeys a low-bit decomposition. -/
theorem scan_range_step {w : Nat} (x : BitVec (w + 1)) :
    scan x (List.range (w + 1)) =
      if x.getLsbD 0 then (scan (x.extractLsb' 1 w) (List.range w)).concat false else 1 := by
  rw [List.range_succ_eq_map]
  simp only [scan]
  split
  · exact scan_map_succ x (List.range w) (fun _ hi ↦ List.mem_range.mp hi)
  · simp


/-- Proof helper: discard each one low bit and restore its mask position on return. -/
def recursiveReference : {w : Nat} → BitVec w → BitVec w
  | 0, _ => 0
  | w + 1, x =>
    if x.getLsbD 0 then (recursiveReference (x.extractLsb' 1 w)).concat false else 1

/-- Figure 3 with the two holes filled by explicitly typed zero and one. -/
def mask {w : Nat} (x : BitVec w) : BitVec w := ~~~(x + 0#w) &&& (x + 1#w)

/-- Dropping the appended low bit recovers the shorter word. -/
theorem extract_tail {w : Nat} (x : BitVec w) (b : Bool) :
    (x.concat b).extractLsb' 1 w = x := by
  ext i hi
  simp [BitVec.getLsbD_concat, hi]

/-- Increment stops at a zero low bit without changing the tail. -/
theorem concat_false_add_one {w : Nat} (x : BitVec w) :
    x.concat false + 1#(w+1) = x.concat true := by
  apply BitVec.eq_of_toNat_eq
  have hx := x.isLt
  simp [BitVec.toNat_concat, Nat.pow_succ]
  rw [Nat.mod_eq_of_lt (by omega)]

/-- Increment of a one low bit carries into the tail, with modular overflow. -/
theorem concat_true_add_one {w : Nat} (x : BitVec w) :
    x.concat true + 1#(w+1) = (x + 1#w).concat false := by
  apply BitVec.eq_of_toNat_eq
  simp [BitVec.toNat_concat, Nat.pow_succ]
  rw [show x.toNat * 2 + 1 + 1 = (x.toNat + 1) * 2 by omega,
    Nat.mul_mod_mul_right]

/-- Appending a one low bit to a zero tail is the finite-width value one. -/
theorem zero_concat_true {w : Nat} : (0 : BitVec w).concat true = 1 := by
  apply BitVec.eq_of_toNat_eq
  simp

/-- Width induction proves the filled mask agrees with the recursive proof helper. -/
theorem mask_eq_recursive {w : Nat} (x : BitVec w) : mask x = recursiveReference x := by
  induction x using BitVec.concat_induction with
  | nil => simp [mask, recursiveReference]
  | @concat w x b ih =>
    cases b
    · unfold mask
      rw [BitVec.add_zero, concat_false_add_one, BitVec.not_concat,
        BitVec.concat_and_concat]
      simp [recursiveReference]
    · unfold mask
      rw [BitVec.add_zero, concat_true_add_one, BitVec.not_concat,
        BitVec.concat_and_concat]
      simp [recursiveReference, extract_tail, ← ih, mask]

/-- The recursive helper is equivalent to the positional scan for every width and input. -/
theorem recursive_eq_loop {w : Nat} (x : BitVec w) :
    recursiveReference x = scan x (List.range w) := by
  induction w with
  | zero => simp [recursiveReference, scan]
  | succ w ih =>
    rw [recursiveReference, scan_range_step]
    split
    · rw [ih]
    · rfl

/-- The width-parametric equivalence, stated against the paper-shaped positional loop. -/
theorem mask_eq_loop {w : Nat} (x : BitVec w) :
    mask x = scan x (List.range w) :=
  (mask_eq_recursive x).trans (recursive_eq_loop x)



/-- The immutable executable reference uses the original positional-loop shape. -/
def reference {w : Nat} (x : BitVec w) : BitVec w := scan x (List.range w)

/-- The two typed constant holes, now for an arbitrary finite word width. -/
structure Fill (w : Nat) where
  left : BitVec w
  right : BitVec w
  deriving Repr, DecidableEq

/-- The literal surrounding sketch from Figure 3, with wrapping addition. -/
def sketch {w : Nat} (fill : Fill w) (x : BitVec w) : BitVec w :=
  ~~~(x + fill.left) &&& (x + fill.right)

def goodFill (w : Nat) : Fill w := ⟨0#w, 1#w⟩

/-- Valid for every width, including width zero; there is no no-overflow precondition. -/
theorem goodFill_equivalent {w : Nat} (x : BitVec w) :
    sketch (goodFill w) x = reference x :=
  mask_eq_loop x

/-- Exact specialization to every 32-bit input of the paper's example. -/
theorem exact32 (x : BitVec 32) : sketch (goodFill 32) x = reference x :=
  goodFill_equivalent x

/-- The same full-output observation boundary, with no restriction on inputs. -/
def boundary (w : Nat) : Boundary (BitVec w) (BitVec w) (Fill w) (BitVec w) where
  reference := reference
  sketch := sketch
  observe := id

/-- Every width receives its proof from induction rather than an input-domain decision procedure. -/
def installed (w : Nat) : Installed (boundary w) :=
  install% (goodFill w) certified_by (by intro x _; exact goodFill_equivalent x)

def installed32 : Installed (boundary 32) := installed 32

theorem installed32_preserves (x : BitVec 32) : installed32.run x = reference x :=
  installed32.preserves x trivial

/-- The old and new scanners agree for every position list in the existing 8-bit example. -/
theorem scan_eight_compatible (x : BitVec 8) (indices : List Nat) :
    scan x indices = Examples.IsolateZero.scan x indices := by
  induction indices with
  | nil => rfl
  | cons i rest ih => simp [scan, Examples.IsolateZero.scan, ih]

/-- The existing 8-bit reference is unchanged and is the specialization of this positional scan. -/
theorem reference_eight_compatible (x : BitVec 8) :
    reference x = Examples.IsolateZero.reference x :=
  scan_eight_compatible x (List.range 8)

/-- Width zero is valid and produces the unique empty word. -/
theorem zero_width (x : BitVec 0) : reference x = 0#0 ∧ sketch (goodFill 0) x = 0#0 := by
  rw [goodFill_equivalent]
  simp [reference, scan]

/-- A deliberate bad fill for the stronger boundary. -/
def wrongFill (w : Nat) : Fill w := ⟨0#w, 0#w⟩

/-- An all-zero fill has a zero-input counterexample at every positive width. -/
theorem wrongFill_counterexample {w : Nat} (hp : 0 < w) :
    sketch (wrongFill w) 0#w ≠ reference 0#w := by
  cases w with
  | zero => omega
  | succ n =>
    simp [sketch, wrongFill, reference, List.range_succ_eq_map, scan]

/-- The positive-width assumption is needed: zero-width words have no differing output. -/
theorem wrongFill_rejected {w : Nat} (hp : 0 < w) : ¬ (boundary w).Valid (wrongFill w) := by
  intro h
  exact wrongFill_counterexample hp (h 0#w trivial)

end Examples.IsolateZeroWidths
