import Examples.DSL
import Examples.Search

open Abstractification Examples.IsolateZero Examples.Search

private def planName : Plan → String
  | .scan => "reference scan"
  | .mask fill => s!"bit sketch (left={fill.left.toNat}, right={fill.right.toNat})"

private def showRun (label : String) (state : SearchState Plan Word) : IO Unit := do
  IO.println s!"\n{label}"
  for trial in state.trials do
    let verdict := match trial.verdict with
      | .rejectedCorpus x => s!"rejected by accumulated counterexample {x.toNat}"
      | .rejectedVerifier x => s!"rejected by full verifier at {x.toNat}; added to corpus"
      | .improved => "passed verifier; improved toy cost"
      | .retained => "passed verifier; retained current best"
    IO.println s!"  {planName trial.fill}: {verdict}; score={trial.score}"
  match state.best with
  | none => IO.println "No tested candidate selected."
  | some (fill, cost) =>
    IO.println s!"Selected tested candidate: {planName fill}; toy cost={cost}"
    match certifySelected state with
    | none => throw <| IO.userError "Selected candidate failed all-input certification"
    | some installed =>
      IO.println s!"All-input certificate gate passed; installed(127)={installed.run 127 |>.toNat}"

def main : IO Unit := do
  IO.println "Abstractification in Lean: fixed boundary, typed proposals, separate certificate gate"
  IO.println
    "Exact domain: all 256 eight-bit words. Ranking: toy operation count, not elapsed time."
  showRun "Long-scan workload [127, 255]" longRun
  showRun "Short-scan workload [0, 0, 0, 0]" shortRun
  IO.println "\nNegative control: replay-only checks [255] accept a bad fill."
  if (certifySelected replayOnly).isNone then
    IO.println "The independent all-input certificate gate rejects that replay winner."
  else
    throw <| IO.userError "Negative control unexpectedly certified"
