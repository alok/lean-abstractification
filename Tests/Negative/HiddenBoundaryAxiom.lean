import Abstractification.DSL
open Abstractification

axiom hidden : Nat

def contaminated : Boundary Nat Nat Nat Nat where
  reference := fun _ ↦ hidden
  sketch := fun _ _ ↦ hidden
  observe := id

def rejected : Installed contaminated := install% 0 certified_by (by intro _ _; rfl)
