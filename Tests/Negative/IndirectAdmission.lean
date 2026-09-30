import Examples.DSL
open Abstractification Examples.DSL

set_option warningAsError false in
theorem admitted : doubling.Valid 2 := by sorry

def rejected : Installed doubling := install% 2 certified_by admitted
