import Examples.DSL
open Abstractification Examples.DSL

-- Ordinary Lean constructors bypass the DSL policy; the explicit audit still detects the debt.
axiom invented : doubling.Valid 2

def raw : Installed doubling := ⟨2, invented⟩
#audit_install raw
