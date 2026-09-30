import Examples.IsolateZeroWidths

open Abstractification Examples.IsolateZeroWidths

-- These are concrete regression inputs; the universal theorem itself uses width induction.
example : reference (0 : BitVec 32) = 1 ∧ installed32.run 0 = 1 := by decide

example : reference (4294967295 : BitVec 32) = 0 ∧
    installed32.run 4294967295 = 0 := by decide

example : reference (2147483647 : BitVec 32) = 2147483648 ∧
    installed32.run 2147483647 = 2147483648 := by decide

example : reference (1 : BitVec 32) = 2 ∧ installed32.run 1 = 2 := by decide

example : reference (2863311530 : BitVec 32) = 1 ∧
    installed32.run 2863311530 = 1 := by decide

example : reference (1431655765 : BitVec 32) = 2 ∧
    installed32.run 1431655765 = 2 := by decide

example : (4294967295 : BitVec 32) + 1#32 = 0 := by decide

example (x : BitVec 1) : sketch (goodFill 1) x = reference x := goodFill_equivalent x

example : ¬ (boundary 32).Valid (wrongFill 32) := wrongFill_rejected (by decide)

-- The rejection theorem's positive-width premise is essential.
example : (boundary 0).Valid (wrongFill 0) := by
  intro x _
  change sketch (goodFill 0) x = reference x
  exact goodFill_equivalent x

-- Applying a proof for a locally chosen width retains the same audited boundary.
def localWidthInstalled : Installed (boundary 32) :=
  let width := 32
  install% (goodFill width) certified_by (by intro x _; exact goodFill_equivalent x)

#audit_install localWidthInstalled
