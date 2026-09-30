import Abstractification.DSL
import Examples.Warmup

open Abstractification

namespace Examples.DSL

abstractify doubling
  input: Nat output: Nat holes: Nat observation: Nat
  reference: (fun n ↦ n + n)
  sketch: (fun multiplier n ↦ n * multiplier)
  observing: id
  requiring: (fun _ ↦ True)

def doubled : Installed doubling :=
  install% 2 certified_by (by intro n _; exact Nat.mul_two n)

theorem doubled_correct (n : Nat) : doubled.run n = n + n :=
  doubled.preserves n trivial

/-- A legitimate local let-bound certificate remains accepted by the dependency audit. -/
def localCertificate : Installed doubling :=
  let certificate := Nat.mul_two
  install% 2 certified_by (by intro n _; exact certificate n)

#audit_install doubled
#audit_install localCertificate
#print axioms doubled

end Examples.DSL
