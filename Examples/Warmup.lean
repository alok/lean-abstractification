import Abstractification.Core

namespace Abstractification.Examples

/-- A small infinite-domain boundary used to exercise proof-carrying installation. -/
def doubleBoundary : Boundary Nat Nat Nat Nat where
  reference := fun n ↦ n + n
  sketch := fun multiplier n ↦ n * multiplier
  observe := id

/-- Only the multiplier is replaceable; the rest of the boundary remains fixed. -/
def doubleInstalled : Installed doubleBoundary where
  fill := 2
  correct := by
    intro n _
    exact Nat.mul_two n

theorem double_correct (n : Nat) : doubleInstalled.run n = n + n :=
  doubleInstalled.preserves n trivial

#print axioms doubleInstalled
#print axioms double_correct

end Abstractification.Examples
