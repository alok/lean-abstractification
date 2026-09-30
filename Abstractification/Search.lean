import Abstractification.Core
import Std

/-!
# Bounded counterexample-guided candidate search

Only fill values are proposed. The caller supplies fixed corpus and verifier inputs plus a fixed
cost function. A verifier pass is explicitly a test result; `certify` separately requires a decision
procedure for the all-input specification before producing an `Installed` value.
-/

namespace Abstractification

universe u v w z

/-- One input satisfies the observation contract, or lies outside the precondition. -/
def agrees {I : Type u} {O : Type v} {F : Type w} {V : Type z}
    (b : Boundary I O F V) [DecidableEq V] [DecidablePred b.pre]
    (fill : F) (input : I) : Bool :=
  decide (b.pre input → b.observe (b.sketch fill input) = b.observe (b.reference input))

/-- Return the first contract violation in the fixed input list. -/
def firstCounterexample {I : Type u} {O : Type v} {F : Type w} {V : Type z}
    (b : Boundary I O F V) [DecidableEq V] [DecidablePred b.pre]
    (fill : F) (inputs : List I) : Option I :=
  inputs.find? fun input ↦ !(agrees b fill input)

/-- Search feedback keeps correctness rejection distinct from cost ranking. -/
inductive Verdict (Input : Type u) where
  | rejectedCorpus (counterexample : Input)
  | rejectedVerifier (counterexample : Input)
  | improved
  | retained
  deriving Repr, DecidableEq

/-- A score exists only after both correctness test stages pass. -/
structure Trial (Fill : Type w) (Input : Type u) where
  fill : Fill
  verdict : Verdict Input
  score : Option Nat
  deriving Repr, DecidableEq

/-- Search state is data: even `best` is a tested fill, not an installed implementation. -/
structure SearchState (Fill : Type w) (Input : Type u) where
  corpus : List Input := []
  best : Option (Fill × Nat) := none
  trials : List (Trial Fill Input) := []
  deriving Repr, DecidableEq

/-- Check corpus first, then verifier inputs; only then call the fixed cost function. -/
def consider {I : Type u} {O : Type v} {F : Type w} {V : Type z}
    (b : Boundary I O F V) [DecidableEq V] [DecidablePred b.pre]
    (verifierInputs : List I) (cost : F → Nat) (state : SearchState F I) (fill : F) :
    SearchState F I :=
  match firstCounterexample b fill state.corpus with
  | some input =>
    { state with trials := state.trials ++ [⟨fill, .rejectedCorpus input, none⟩] }
  | none =>
    match firstCounterexample b fill verifierInputs with
    | some input =>
      { state with
        corpus := state.corpus ++ [input]
        trials := state.trials ++ [⟨fill, .rejectedVerifier input, none⟩] }
    | none =>
      let score := cost fill
      let improves := match state.best with
        | none => true
        | some (_, bestScore) => score < bestScore
      { state with
        best := if improves then some (fill, score) else state.best
        trials := state.trials ++
          [⟨fill, if improves then .improved else .retained, some score⟩] }

/-- A finite proposal list supplies the synthesis side of this deterministic CEGIS-style loop. -/
def search {I : Type u} {O : Type v} {F : Type w} {V : Type z}
    (b : Boundary I O F V) [DecidableEq V] [DecidablePred b.pre]
    (verifierInputs corpus : List I) (cost : F → Nat) (proposals : List F) : SearchState F I :=
  proposals.foldl (consider b verifierInputs cost) { corpus := corpus }

/-- An all-input decider must supply the actual proof for installation after testing. -/
def certify {I : Type u} {O : Type v} {F : Type w} {V : Type z}
    (b : Boundary I O F V) (fill : F) [Decidable (b.Valid fill)] : Option (Installed b) :=
  if h : b.Valid fill then some ⟨fill, h⟩ else none

/-- Certification preserves the proposed fill itself, as well as supplying its validity proof. -/
theorem certify_fill {I : Type u} {O : Type v} {F : Type w} {V : Type z}
    {b : Boundary I O F V} (fill : F) [Decidable (b.Valid fill)] (installed : Installed b)
    (h : certify b fill = some installed) : installed.fill = fill := by
  unfold certify at h
  split at h
  · simp only [Option.some.injEq] at h
    cases h
    rfl
  · contradiction

end Abstractification
