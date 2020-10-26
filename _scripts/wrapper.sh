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

# from: https://stackoverflow.com/questions/14366390/check-if-an-element-is-present-in-a-bash-array/14367368
array_contains () {
    local array="$1[@]"
    local seeking="$2"
    local in="no"
    for element in "${!array}"; do
        if [[ $element == "$seeking" ]]; then
            in="yes";
            break
        fi
    done
    echo "${in}"
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

## busybox のコマンド名とコマンドライン引数を取得
WRAPPER_CMD_NAME="$(basename ${0})"
ARGS=("$@")

## busybox のコマンド名 が wrapper.sh の時はここで終了.
if [[ "${WRAPPER_CMD_NAME}" == "wrapper.sh" ]]; then
    exit 0;
fi

## busybox が特定のコマンド名の時, コマンドライン引数に一部修正を加える
case "${WRAPPER_CMD_NAME}" in
    "ansible-galaxy" )
        ## コマンドライン引数に -p が指定されていない時は VENV_COLLECTIONS_PATH を指定する.
        #  * 参照: https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#installing-a-collection-from-galaxy
        if [[ "$(array_contains ARGS '-p')" == "no" ]]; then
            ARGS+=("-p" "${VENV_COLLECTIONS_PATH}")
        fi
        ;;

    * ) ;;
esac

## シンボリック名に合わせて実行 busybox を実行
"${VENV_DIR}/bin/${WRAPPER_CMD_NAME}" "${ARGS[@]}"
