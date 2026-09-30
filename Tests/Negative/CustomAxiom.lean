import Examples.DSL
open Abstractification Examples.DSL

axiom invented : doubling.Valid 2

def rejected : Installed doubling := install% 2 certified_by invented
