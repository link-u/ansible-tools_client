#! /bin/bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)

if [ -z $1 ]; then
  echo "usage: bash prepare.sh {VENV_DIR}"
  exit -1
fi

VENV_DIR=$1

if [ -d ${VENV_DIR} ]; then
  exit 0
fi

bash -eu <<EOF
  trap catch ERR
  function catch() {
    rm -Rf ${VENV_DIR}
  }
  python3 -m venv ${VENV_DIR}
  source ${VENV_DIR}/bin/activate

  pip3 install -r ${SCRIPT_DIR}/req.txt
EOF
