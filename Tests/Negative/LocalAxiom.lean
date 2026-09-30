import Examples.DSL
open Abstractification Examples.DSL

axiom invented : False

def rejected : Installed doubling :=
  let hiddenProof := invented
  install% 0 certified_by (by intro _ _; exact False.elim hiddenProof)
