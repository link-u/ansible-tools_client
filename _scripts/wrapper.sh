#! /bin/bash -eu
SCRIPT_PATH=$(readlink -f $0)
SCRIPT_DIR=$(cd $(dirname ${SCRIPT_PATH}); pwd)

REQUIREMENT_HASH=$(cat ${SCRIPT_DIR}/req.txt | openssl dgst -md5 | sed 's/^.* //')
VENV_DIR=$(cd ${SCRIPT_DIR}/../_venvs; pwd)/${REQUIREMENT_HASH}

bash ${SCRIPT_DIR}/prepare.sh ${VENV_DIR}
source ${VENV_DIR}/bin/activate

${VENV_DIR}/bin/$(basename $0) "$@"
