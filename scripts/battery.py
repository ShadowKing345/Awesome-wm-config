#!/bin/env python3
from distutils.spawn import find_executable
import sys, subprocess

acpi = "acpi"

command = find_executable(acpi)

if not command:
    sys.exit(f"Cannot find {acpi}!")

battery_info = subprocess.run(command, capture_output=True, text=True)

if battery_info.stderr:
    sys.exit(battery_info.stderr)

split_string: list[str] = battery_info.stdout.split(",")

name, state = split_string[0].split(":")

name = name.strip()
state = state.strip()

percentage = split_string[1].strip().rstrip("%")

time_left = split_string[2].strip() if len(split_string) == 3 else None

match state:
    case "Not charging":
        state = "full"
    case "Charging":
        state = "charging"
    case "Discharging":
        state = "discharging"
    case _:
        state = "unknown"

print(f"{name},{state},{percentage},{time_left if time_left else ''}")
