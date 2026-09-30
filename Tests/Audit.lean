import Examples.DSL
import Examples.Search
import Examples.IsolateZeroWidths

open Abstractification

#audit_install Abstractification.Examples.doubleInstalled
#audit_install Examples.DSL.doubled
#audit_install Examples.DSL.localCertificate
#audit_install Examples.IsolateZero.installed
#audit_install Examples.Search.fastInstalled

#print axioms Examples.IsolateZero.goodFill_equivalent
#print axioms Examples.IsolateZero.installed
#print axioms Examples.Search.fastInstalled
#print axioms Examples.Search.long_winner
#print axioms Examples.Search.long_certified

-- Generic finite certification is also audited for its proof dependencies.
#print axioms Abstractification.certify

#audit_install Examples.IsolateZeroWidths.installed32
#print axioms Examples.IsolateZeroWidths.goodFill_equivalent
#print axioms Examples.IsolateZeroWidths.exact32
#print axioms Examples.IsolateZeroWidths.recursive_eq_loop
#print axioms Examples.IsolateZeroWidths.installed
#print axioms Examples.IsolateZeroWidths.installed32
#print axioms Examples.IsolateZeroWidths.wrongFill_rejected
