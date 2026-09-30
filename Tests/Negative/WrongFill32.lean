import Examples.IsolateZeroWidths
open Abstractification Examples.IsolateZeroWidths

-- Kernel-certified equivalence for (0,1) cannot justify the concrete counterexample fill (0,0).
def rejected : Installed (boundary 32) :=
  install% (wrongFill 32) certified_by (by intro x _; exact exact32 x)
