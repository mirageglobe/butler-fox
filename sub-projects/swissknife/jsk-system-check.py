#!/usr/bin/env python3

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Cross-platform system diagnostic tool for OS, disk, and apps.
# version     : 1.1.0

import json
import platform
import shutil
import subprocess
import sys

def get_help():
    return """
--------------------
jimmy's system check
--------------------

check           get system information (OS, Disk)
applist         get common installed applications
runningapps     get current running applications
version         get current script version
help            get list of commands

flags:
  --json        output result as JSON
"""

def get_os():
    return f"{platform.system()} {platform.release()} ({platform.machine()})"

def get_disk():
    total, used, free = shutil.disk_usage("/")
    return (
        f"Total: {total // (2**30)} GB\n"
        f"Used:  {used // (2**30)} GB\n"
        f"Free:  {free // (2**30)} GB"
    )

def get_disk_dict():
    total, used, free = shutil.disk_usage("/")
    return {"total_gb": total // (2**30), "used_gb": used // (2**30), "free_gb": free // (2**30)}

def get_version():
    return "1.1.0"

def get_app_list():
    apps = ["nginx", "git", "docker", "python3", "bash", "curl"]
    results = []
    for app in apps:
        status = "✓" if shutil.which(app) else "✗"
        results.append(f"{app:<10} {status}")
    return "\n".join(results)

def get_app_list_dict():
    apps = ["nginx", "git", "docker", "python3", "bash", "curl"]
    return {app: bool(shutil.which(app)) for app in apps}

def get_running_apps():
    targets = ["nginx", "sophos", "docker", "ssh"]
    found = []
    try:
        for target in targets:
            try:
                subprocess.check_output(["pgrep", "-f", target])
                found.append(f"{target:<10} [RUNNING]")
            except subprocess.CalledProcessError:
                found.append(f"{target:<10} [STOPPED]")
    except FileNotFoundError:
        return "pgrep not found. Cannot check running apps easily."
    return "\n".join(found)

def get_running_apps_dict():
    targets = ["nginx", "sophos", "docker", "ssh"]
    result = {}
    try:
        for target in targets:
            try:
                subprocess.check_output(["pgrep", "-f", target])
                result[target] = True
            except subprocess.CalledProcessError:
                result[target] = False
    except FileNotFoundError:
        return {}
    return result

if __name__ == "__main__":
    if sys.version_info.major < 3:
        print("[error] requires python 3.x")
        sys.exit(1)

    args = [a for a in sys.argv[1:] if a != "--json"]
    use_json = "--json" in sys.argv[1:]

    if not args or args[0] == "help":
        print(get_help())
        sys.exit(0)

    cmd = args[0]

    if cmd == "check":
        if use_json:
            total, used, free = shutil.disk_usage("/")
            print(json.dumps({"os": get_os(), "disk": get_disk_dict()}, indent=2))
        else:
            print(f"Operating System : {get_os()}")
            print("\nDisk Space:")
            print(get_disk())
    elif cmd == "applist":
        if use_json:
            print(json.dumps(get_app_list_dict(), indent=2))
        else:
            print("Common Applications:")
            print(get_app_list())
    elif cmd == "runningapps":
        if use_json:
            print(json.dumps(get_running_apps_dict(), indent=2))
        else:
            print("Target Running Applications:")
            print(get_running_apps())
    elif cmd == "version":
        if use_json:
            print(json.dumps({"version": get_version()}))
        else:
            print(get_version())
    else:
        print(f"Invalid command: {cmd}")
        print(get_help())
        sys.exit(1)
