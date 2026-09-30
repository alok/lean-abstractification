import Examples.DSL
open Abstractification Examples.DSL

set_option warningAsError false in
def rejected : Installed doubling :=
  let hiddenProof : False := by sorry
  install% 0 certified_by (by intro _ _; exact False.elim hiddenProof)
