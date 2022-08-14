#!/bin/env python3
from shutil import which
from subprocess import run, CompletedProcess
import re
from typing import Match

acpi: str = "acpi"
command: str | None = which(acpi)

try:
    if command is None:
        raise Exception(f"Cannot find command {command}")
    else:
        result: CompletedProcess = run([command], capture_output=True, text=True)
    
        if result.returncode != 0 or len(result.stdout.strip()) == 0:
            raise Exception(f"{command} return an error.")
        else:
            re_result: Match | None = re.search(r"(.*):([^,]*),([^,]*)[,]?(.*)?", result.stdout.strip())
    
            if not re_result:
                raise Exception(f"Regex returned None.")
            else:
                res: list[str] = list(re_result.groups())
                for k, v in enumerate(res):
                    res[k] = v.strip().rstrip("%")

                print(",".join(res), end="")
except Exception as _:
    print("", end="")

