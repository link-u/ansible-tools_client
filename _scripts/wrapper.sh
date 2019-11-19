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

REQUIREMENT_HASH=$(cat ${SCRIPT_DIR}/req.txt | openssl dgst -md5 | sed 's/^.* //')
VENV_DIR=$(cd ${SCRIPT_DIR}/../_venvs; pwd)/${REQUIREMENT_HASH}

bash ${SCRIPT_DIR}/prepare.sh ${VENV_DIR}
source ${VENV_DIR}/bin/activate

${VENV_DIR}/bin/$(basename $0) "$@"
