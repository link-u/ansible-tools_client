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

    ## collection がインストールされるディレクトリ
    venv_collections_path = sys.argv[1]

    ## req_collections.yml のファイル一覧
    _req_files_list = [
        os.path.join(repo_root_dir, "_scripts", "req_collections.yml"),
        os.path.join(repo_root_dir, "../", "req_collections.yml")
    ]
    req_files_list = [
        _req_files_list[i] for i in range(len(_req_files_list))
        if os.path.isfile(_req_files_list[i])
    ]

    ## インストールする collection 名を抽出
    collections: list = []
    for req_file in req_files_list:
        with open(req_file, "r") as yml:
            req_yml = yaml.load(yml, Loader=yaml.SafeLoader)

        for coll in req_yml["collections"]:
            coll_name: str = coll["name"]
            collections.append(os.path.join(
                venv_collections_path,
                "ansible_collections",
                coll_name.replace(".", "/")
            ))

    ## 重複要素を削除
    collections = list(set(collections))

    ## 存在しない collection がある場合インストール
    for coll_path in collections:
        if not os.path.isdir(coll_path):
            cmd = ["ansible-galaxy", "collection", "install", "-r", req_file]
            proc = subprocess.run(cmd, cwd = repo_root_dir)
            if proc.returncode == 0:
                break
            else:
                sys.exit(proc.returncode)
