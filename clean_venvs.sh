#! /bin/bash -eu

## リポジトリのルートディレクトリ
REPO_DIR="$(cd $(dirname ${0}); pwd)"

## _venvs の _venvs の中身を削除
rm -rf "${REPO_DIR}/_venvs"
mkdir -p "${REPO_DIR}/_venvs"
touch "${REPO_DIR}/_venvs/.gitkeep"
