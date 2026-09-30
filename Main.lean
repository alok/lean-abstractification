import Examples.Warmup

open Abstractification.Examples

def main : IO Unit := do
  IO.println "Abstractification in Lean: first proof-carrying boundary"
  IO.println s!"fixed reference: 21 + 21 = {doubleBoundary.reference 21}"
  IO.println s!"installed fill: multiplier = {doubleInstalled.fill}"
  IO.println s!"certified execution: {doubleInstalled.run 21}"
  IO.println "Certificate: equality for every Nat input (no admitted holes)."
