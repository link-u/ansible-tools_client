#! /bin/bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)

# pre-req.txtはオーバーライドできない
PRE_REQ_TXT=${SCRIPT_DIR}/pre-req.txt

# req.txtはオーバーライド可能。
if [ -e "${SCRIPT_DIR}/../../req.txt" ]; then
  REQ_TXT="${SCRIPT_DIR}/../../req.txt"
else
  REQ_TXT=${SCRIPT_DIR}/req.txt
fi

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

  pip3 install -r ${PRE_REQ_TXT}
  pip3 install -r ${REQ_TXT}
EOF
