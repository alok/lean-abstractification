#!/usr/bin/env python3
"""Require each negative fixture to fail for its intended reason, not an import/build failure."""
from pathlib import Path
import subprocess
import sys

CASES: dict[str, tuple[str, ...]] = {
    "DirectAdmission": ("installation contains an admitted hole",),
    "LocalAdmission": ("installation contains an admitted hole",),
    "LocalAxiom": ("disallowed axiom invented",),
    "IndirectAdmission": ("disallowed axiom sorryAx",),
    "CustomAxiom": ("disallowed axiom invented",),
    "HiddenBoundaryAxiom": ("disallowed axiom hidden",),
    "WrongFill": ("goodFill_valid", "wrongFill"),
    "WrongType": ("String", "Fill"),
    "DraftHole": ("unfilled draft hole body : Nat", "x : Nat"),
    "NativeDecision": ("disallowed axiom", "native_decide"),
    "AuditDirectConstruction": ("disallowed axiom invented",),
}


def main() -> int:
    failures: list[str] = []
    for name, fragments in CASES.items():
        path = Path("Tests/Negative") / f"{name}.lean"
        result = subprocess.run(
            ["lake", "env", "lean", str(path)],
            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=False,
        )
        if result.returncode == 0 or any(fragment not in result.stdout for fragment in fragments):
            failures.append(name)
            print(f"FAIL {name}: exit={result.returncode}\n{result.stdout}", file=sys.stderr)
        else:
            print(f"PASS rejected {name} for the expected reason")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
