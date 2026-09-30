import Abstractification.Search
import Abstractification.DSL
import Examples.IsolateZero

/-!
# Two workload-dependent selections within the paper's sketching boundary

The baseline scans; the proposed bit expression has the paper's two typed constant holes. Ranking
uses a declared toy operation count, not elapsed time or an allocation benchmark. Longer scans favor
the bit expression; a workload of zero inputs favors the scan. Incorrect proposals never get scores.
-/

namespace Examples.Search

open Abstractification Examples.IsolateZero

/-- Closed proposal data; the driver keeps the reference, verifier, and surrounding code fixed. -/
inductive Plan where
  | scan
  | mask (fill : Fill)
  deriving Repr, DecidableEq

/-- Interpret the closed proposal data inside the fixed surrounding program. -/
def execute : Plan → Word → Word
  | .scan, x => reference x
  | .mask fill, x => sketch fill x

abstractify boundary
  input: Word output: Word holes: Plan observation: Word
  reference: reference
  sketch: execute
  observing: id
  requiring: (fun _ ↦ True)

instance : DecidablePred boundary.pre := fun _ ↦ inferInstanceAs (Decidable True)

instance (fill : Plan) : Decidable (boundary.Valid fill) :=
  inferInstanceAs (Decidable (∀ x : Word, True → execute fill x = reference x))

/-- Count reference bit inspections. This deliberately omits real compiler and machine costs. -/
def scanCost (x : Word) : List Nat → Nat
  | [] => 0
  | i :: rest => if x.getLsbD i then 1 + scanCost x rest else 1

/-- Toy cost: each bit inspection costs one; the bit expression costs four operations. -/
def workloadCost (inputs : List Word) (plan : Plan) : Nat :=
  (inputs.map fun x ↦ match plan with
    | .scan => scanCost x (List.range 8)
    | .mask _ => 4).foldl Nat.add 0

/-- Include two incorrect proposals, both correct alternatives, and a later dominated proposal. -/
def proposals : List Plan :=
  [.mask wrongFill, .mask ⟨0, 2⟩, .scan, .mask goodFill, .scan, .mask wrongFill]

def longWorkload : List Word := [127, 255]
def shortWorkload : List Word := [0, 0, 0, 0]

/-- The initial corpus misses the all-zero fill's bug; full verification adds input zero. -/
def run (workload : List Word) : SearchState Plan Word :=
  search boundary allInputs [255] (workloadCost workload) proposals

def longRun := run longWorkload
def shortRun := run shortWorkload

/-- A separately certified static installation of the selected fast candidate. -/
def fastInstalled : Installed boundary :=
  install% (.mask goodFill) certified_by (by
    intro x _
    exact goodFill_equivalent x)

/-- The runtime-selected tested fill goes through an all-input certificate gate. -/
def certifySelected (state : SearchState Plan Word) : Option (Installed boundary) :=
  match state.best with
  | none => none
  | some (fill, _) => certify boundary fill

set_option maxRecDepth 2048 in
set_option maxHeartbeats 2000000 in
theorem long_winner : longRun.best = some (.mask goodFill, 8) := by decide

set_option maxRecDepth 2048 in
set_option maxHeartbeats 2000000 in
theorem short_winner : shortRun.best = some (.scan, 4) := by decide

/-- A correctness rejection carries no ranking score. -/
theorem first_rejection : longRun.trials.head? =
    some ⟨.mask wrongFill, .rejectedVerifier 0, none⟩ := by decide

/-- The next proposal is rejected by the newly accumulated counterexample. -/
theorem second_rejection : longRun.trials[1]? =
    some ⟨.mask ⟨0, 2⟩, .rejectedCorpus 0, none⟩ := by decide

set_option maxRecDepth 2048 in
set_option maxHeartbeats 2000000 in
theorem long_certified : (certifySelected longRun).isSome = true := by decide

set_option maxRecDepth 2048 in
set_option maxHeartbeats 2000000 in
theorem short_certified : (certifySelected shortRun).isSome = true := by decide

/-- The all-input gate rejects an incorrect candidate even if a replay-only search preferred it. -/
theorem incorrect_not_certified : (certify boundary (.mask wrongFill)).isNone = true := by decide

/-- Deliberately incomplete verification can accept a bug; certification still rejects it. -/
def replayOnly : SearchState Plan Word :=
  search boundary [255] [255] (fun _ ↦ 0) [.mask wrongFill]

theorem replay_misses_bug : replayOnly.best = some (.mask wrongFill, 0) := by decide

theorem replay_winner_not_certified : (certifySelected replayOnly).isNone = true := by decide

#audit_install fastInstalled

end Examples.Search
