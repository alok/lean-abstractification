import Abstractification.Core
import Lean

/-!
# Specification and installation syntax

`abstractify` declares a fixed boundary. `install%` uses the expected `Installed` type to elaborate
the fill and its proof, then audits transitive axiom dependencies. `draft_hole%` reports a typed
editing obligation and fails; it never introduces an admitted executable value.

This is an elaboration-time trust check in a trusted project, not an operating-system sandbox for
hostile Lean code. Ordinary Lean definitions can also construct `Installed` directly.
-/

open Lean Meta Elab Term Command

namespace Abstractification

/-- A declarative spelling of the fixed parts of an abstractification boundary. -/
syntax "abstractify " ident
  " input: " term " output: " term " holes: " term " observation: " term
  " reference: " term " sketch: " term " observing: " term " requiring: " term : command

macro_rules
  | `(abstractify $name:ident input: $i:term output: $o:term holes: $f:term observation: $v:term
      reference: $ref:term sketch: $sk:term observing: $obs:term requiring: $pre:term) =>
    `(def $name : Boundary $i $o $f $v :=
        { reference := $ref, sketch := $sk, observe := $obs, pre := $pre })

/-- The explicit axiom policy for this research draft's audited installations. -/
def allowedAxiom (name : Name) : Bool :=
  name == ``propext || name == ``Classical.choice || name == ``Quot.sound

/-- Audit transitive constants plus reachable local declarations, their types, and let values. -/
def auditExpression (value : Expr) : TermElabM Unit := do
  let mut pending := #[value, ← inferType value]
  let mut seenLocals : FVarIdSet := {}
  let mut seenConstants : NameSet := {}
  while !pending.isEmpty do
    let expression ← instantiateMVars pending.back!
    pending := pending.pop
    if expression.hasMVar then
      throwError "installation contains unresolved metavariables"
    if expression.hasSorry then
      throwError "installation contains an admitted hole (sorryAx)"
    for name in expression.getUsedConstants do
      unless seenConstants.contains name do
        seenConstants := seenConstants.insert name
        for axiomName in ← collectAxioms name do
          unless allowedAxiom axiomName do
            throwError m!"installation depends on disallowed axiom {axiomName} via {name}"
    for fvarId in (collectFVars {} expression).fvarIds do
      unless seenLocals.contains fvarId do
        seenLocals := seenLocals.insert fvarId
        let decl ← fvarId.getDecl
        pending := pending.push decl.type
        if let some localValue := decl.value? then
          pending := pending.push localValue

/-- Install a typed fill and a proof at the boundary supplied by the expected `Installed` type. -/
syntax "install% " term " certified_by " term : term

elab_rules : term <= expected
  | `(install% $fill:term certified_by $proof:term) => do
    let target ← whnf expected
    unless target.isAppOf ``Installed do
      throwError m!"install% expected Installed boundary, got {expected}"
    let expanded ← `({ fill := $fill, correct := $proof })
    let value ← elabTermEnsuringType expanded (some expected)
    synthesizeSyntheticMVarsNoPostponing
    let value ← instantiateMVars value
    auditExpression value
    return value

/-- An editor-facing obligation that refuses to create `sorryAx` or a default value. -/
syntax "draft_hole% " ident : term

elab_rules : term <= expected
  | `(draft_hole% $name:ident) => do
    let mut locals : MessageData := m!""
    for decl in ← getLCtx do
      unless decl.isImplementationDetail do
        locals := locals ++ m!"\n  {decl.userName} : {decl.type}"
    throwError m!"unfilled draft hole {name.getId} : {expected}\nlocal context:{locals}"

/-- Audit an installed declaration transitively; fail on admissions or nonstandard axioms. -/
syntax "#audit_install " ident : command

elab_rules : command
  | `(#audit_install $name:ident) => liftTermElabM do
    let value ← elabTerm name none
    let type ← whnf (← inferType value)
    unless type.isAppOf ``Installed do
      throwError m!"audit expects Installed boundary, got {type}"
    auditExpression value
    logInfo m!"installation {name.getId}: audited (standard Lean axioms only)"

end Abstractification
