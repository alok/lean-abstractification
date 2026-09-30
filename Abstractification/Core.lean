/-!
# Abstractification boundaries

A boundary fixes a reference, a sketch, and the observations being preserved. Only the typed fill is
variable. Installation carries a proof of observational agreement on every input satisfying `pre`.
This models the specification boundary in Alperen Keleş's *Abstractification*, §3.
-/

namespace Abstractification

universe u v w z

/-- The immutable specification and surrounding program for one replaceable fill. -/
structure Boundary (Input : Type u) (Output : Type v) (Fill : Type w) (Observation : Type z) where
  reference : Input → Output
  sketch : Fill → Input → Output
  observe : Output → Observation
  pre : Input → Prop := fun _ ↦ True

/-- The exact obligation for installing a candidate. It concerns only the declared observations. -/
def Boundary.Valid {I : Type u} {O : Type v} {F : Type w} {V : Type z}
    (b : Boundary I O F V) (fill : F) : Prop :=
  ∀ input, b.pre input → b.observe (b.sketch fill input) = b.observe (b.reference input)

/-- An executable fill packaged with a kernel-checkable certificate for its fixed boundary. -/
structure Installed {I : Type u} {O : Type v} {F : Type w} {V : Type z}
    (b : Boundary I O F V) where
  fill : F
  correct : b.Valid fill

/-- Execute the surrounding sketch with the certified fill. -/
def Installed.run {I : Type u} {O : Type v} {F : Type w} {V : Type z}
    {b : Boundary I O F V} (installed : Installed b) : I → O :=
  b.sketch installed.fill

/-- Every installed fill preserves the observations on inputs covered by the precondition. -/
theorem Installed.preserves {I : Type u} {O : Type v} {F : Type w} {V : Type z}
    {b : Boundary I O F V} (installed : Installed b) (input : I) (h : b.pre input) :
    b.observe (installed.run input) = b.observe (b.reference input) :=
  installed.correct input h

end Abstractification
