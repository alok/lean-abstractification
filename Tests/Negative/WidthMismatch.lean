import Examples.IsolateZeroWidths
open Abstractification Examples.IsolateZeroWidths

def rejected : Installed (boundary 32) :=
  install% (goodFill 8) certified_by (by intro x _; exact exact32 x)
