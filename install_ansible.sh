#! /bin/bash -eu

## リポジトリのルートディレクトリ
REPO_DIR="$(cd $(dirname ${0}); pwd)"

## ansible のインストール
"${REPO_DIR}/_scripts/wrapper.sh"
