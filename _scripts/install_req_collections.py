#!/usr/bin/python3

import os
import subprocess
import sys
import yaml

## python script path and repo dir
script_path   = os.path.abspath(__file__)
repo_root_dir = os.path.abspath(os.path.join(os.path.dirname(script_path), ".."))

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Invalid argument", file=sys.stderr)
        sys.exit(1)

    venv_collections_path = sys.argv[1]

    # req_files_list = [
    #     os.path.join(repo_root_dir, "_scripts", "req_collections.yml")
    # ]

    collections: list = []
    req_file = os.path.join(repo_root_dir, "_scripts", "req_collections.yml")
    with open(req_file, "r") as yml:
        req_yml = yaml.load(yml, Loader=yaml.SafeLoader)

    for coll in req_yml["collections"]:
        coll_name: str = coll["name"]
        collections.append(os.path.join(
            venv_collections_path,
            "ansible_collections",
            coll_name.replace(".", "/")
        ))

    for coll_path in collections:
        if not os.path.isdir(coll_path):
            cmd = ["ansible-galaxy", "collection", "install", "-r", req_file]
            proc = subprocess.run(cmd, cwd = repo_root_dir)
            if proc.returncode == 0:
                break
            else:
                sys.exit(proc.returncode)
