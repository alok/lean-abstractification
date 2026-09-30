import Examples.IsolateZeroWidths
open Examples.IsolateZeroWidths

-- The scan returns zero for the all-ones word; overflow must not create an extra mask bit.
example : reference (4294967295 : BitVec 32) = 1#32 := by decide
