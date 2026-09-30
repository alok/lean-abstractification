import Abstractification.DSL
import Examples.IsolateZero
open Abstractification Examples.IsolateZero

-- A true native decision still uses compiler trust outside the declared axiom policy.
def rejected : Installed boundary :=
  install% goodFill certified_by (by
    unfold Boundary.Valid boundary
    native_decide)
