import Examples.DSL
open Abstractification Examples.DSL

set_option warningAsError false in
def rejected : Installed doubling := install% 2 certified_by (by sorry)
