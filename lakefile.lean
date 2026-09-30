import Lake
open Lake DSL

package «lean-abstractification» where
  version := v!"0.1.0"
  leanOptions := #[⟨`autoImplicit, false⟩, ⟨`warningAsError, true⟩]

@[default_target]
lean_lib Abstractification

lean_lib Examples

@[default_target]
lean_exe abstractificationDemo where
  root := `Main
