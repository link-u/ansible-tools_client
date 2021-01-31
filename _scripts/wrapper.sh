#! /bin/bash -eu

# from: https://qiita.com/edvakf@github/items/b8400f7dfe9210aadddd
function readlink_f() {
    local TARGET_FILE=$1
    cd $(dirname ${TARGET_FILE})
    TARGET_FILE=$(basename ${TARGET_FILE})

    # Iterate down a (possible) chain of symlinks
    while [ -L "${TARGET_FILE}" ]
    do
        TARGET_FILE=$(readlink ${TARGET_FILE})
        cd $(dirname ${TARGET_FILE})
        TARGET_FILE=$(basename ${TARGET_FILE})
    done

    # Compute the canonicalized name by finding the physical path
    # for the directory we're in and appending the target file.
    local PHYS_DIR=$(pwd -P)
    echo ${PHYS_DIR}/${TARGET_FILE}
}

SCRIPT_PATH=$(readlink_f $0)
SCRIPT_DIR=$(cd $(dirname ${SCRIPT_PATH}); pwd)

if [ -e "${SCRIPT_DIR}/../../req.txt" ]; then
    REQ_TXT="${SCRIPT_DIR}/../../req.txt"
else
    REQ_TXT=${SCRIPT_DIR}/req.txt
fi

REQUIREMENT_HASH=$(cat ${REQ_TXT} | openssl dgst -md5 | sed 's/^.* //')
VENV_DIR=$(cd ${SCRIPT_DIR}/../_venvs; pwd)/${REQUIREMENT_HASH}

## python3-venv の作成とアクティベート
bash ${SCRIPT_DIR}/prepare.sh ${VENV_DIR}
source ${VENV_DIR}/bin/activate

## ansible collections path の設定
#  * VENV_COLLECTIONS_PATH を ANSIBLE_COLLECTIONS_PATHS の先頭に追加
#  * VENV_COLLECTIONS_PATH ディレクトリを作成
#  * ANSIBLE_COLLECTIONS_PATHS を環境変数としてエクスポート
#  * 参照: https://docs.ansible.com/ansible/latest/reference_appendices/config.html#collections-paths
DEFAULT_COLLECTIONS_PATHS="${HOME}/.ansible/collections:/usr/share/ansible/collections"
VENV_COLLECTIONS_PATH="${VENV_DIR}/share/ansible/collections"
mkdir -p "${VENV_COLLECTIONS_PATH}"
export ANSIBLE_COLLECTIONS_PATHS="${VENV_COLLECTIONS_PATH}:${DEFAULT_COLLECTIONS_PATHS}"

## スクリプト名とコマンドライン引数を取得
WRAPPER_CMD_NAME="$(basename ${0})"
ARGS=("$@")

"${VENV_DIR}/bin/python3" "${SCRIPT_DIR}/install_req_collections.py" "${VENV_COLLECTIONS_PATH}"

## スクリプト名 が wrapper.sh の時はここで終了.
if [[ "${WRAPPER_CMD_NAME}" == "wrapper.sh" ]]; then
    exit 0;
fi

## シンボリック名に合わせて実行このスクリプトを実行
"${VENV_DIR}/bin/${WRAPPER_CMD_NAME}" "${ARGS[@]}"
