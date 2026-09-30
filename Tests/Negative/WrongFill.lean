import Abstractification.DSL
import Examples.IsolateZero
open Abstractification Examples.IsolateZero

def rejected : Installed boundary :=
  install% wrongFill certified_by goodFill_valid
