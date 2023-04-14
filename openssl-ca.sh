#! /bin/bash

set -euo pipefail

###############################################################################
# Environment

_ME="$(basename "${0}")"
BASE="$(pwd)/openssl-ca"

COLOR_GREEN="\033[1;92m"
COLOR_RED="\033[1;91m"
COLOR_YELLOW="\033[1;93m"
COLOR_BOLD_WHITE="\033[1;97m"
COLOR_RESET="\033[0m"

SKIP_TEXT="${COLOR_BOLD_WHITE}[${COLOR_RESET}${COLOR_YELLOW}SKIP${COLOR_RESET}${COLOR_BOLD_WHITE}]${COLOR_RESET}"
OK_TEXT="${COLOR_BOLD_WHITE}[${COLOR_RESET}${COLOR_GREEN}OK${COLOR_RESET}${COLOR_BOLD_WHITE}]${COLOR_RESET}"
ERROR_TEXT="${COLOR_BOLD_WHITE}[${COLOR_RESET}${COLOR_RED}ERROR${COLOR_RESET}${COLOR_BOLD_WHITE}]${COLOR_RESET}"

# shellcheck disable=SC2155
export OPENSSL_CONF="$(pwd)/openssl.cnf"

###############################################################################
# Help

function print_help() {
  cat <<HEREDOC
Unipi Control OS Tools
Usage: ${_ME} [-h] [--build-root-ca] [--create-signing-key]

Options:
  -h, --help                        Show show this help message and exit
  --build-root-ca [ORG] [CA]        Build root CA and directory structure for certificates
  --create-signing-key [CN]         Create code signing key
HEREDOC
}

###############################################################################
# Program Functions

function build_root_ca() {
  local ORG="${2:-Test Org}"
  local CA="${3:-RAUC CA}"

  if [ -e "${BASE}" ]; then
    echo -e "${ERROR_TEXT} Directory 'openssl-ca' already exists!"
    exit 1
  fi

  mkdir -p "${BASE}/"{root,private,certs}
  mkdir -p "${BASE}/root/private"
  touch "${BASE}/index.txt"
  echo 01 > "${BASE}/serial"

  (
    echo "ORG=\"${ORG}\""
    echo "CA=\"${CA}\""
  ) > "${BASE}/meta"

  openssl req -newkey rsa \
    -keyout "${BASE}/root/private/ca.key.pem" \
    -out "${BASE}/root/ca.csr.pem" \
    -subj "/O=${ORG}/CN=${ORG} ${CA} Root" > /dev/null 2>&1

  echo -e "${OK_TEXT} Root CA private key 'openssl-ca/root/private/ca.key.pem' created."

  openssl ca -batch -selfsign -extensions v3_ca \
    -in "${BASE}/root/ca.csr.pem" \
    -out "${BASE}/root/ca.cert.pem" \
    -keyfile "${BASE}/root/private/ca.key.pem" > /dev/null 2>&1

  echo -e "${OK_TEXT} Root CA certificate 'openssl-ca/root/ca.cert.pem' created."
}

function create_signing_key() {
  if [ ! -e "${BASE}" ]; then
    echo -e "${SKIP_TEXT} Directory 'openssl-ca' not exists! Execute './${_ME} --build-root-ca' first."
    exit 1
  fi

  local CN=${2:-}

  if [ -z "${CN}" ]; then
    echo -e "${ERROR_TEXT} CN argument is missing!"
    exit 1
  fi

  if [ -f "${BASE}/private/${CN}.key.pem" ] || [ -f "${BASE}/${CN}.cert.pem" ]; then
    echo -e "${SKIP_TEXT} Key and certificate for '${CN}' already exists!"
    exit 1
  fi

  . "${BASE}/meta"

  openssl req -newkey rsa:4096 \
    -keyout "${BASE}/private/${CN}.key.pem" \
    -out "${BASE}/${CN}.csr.pem" \
    -subj "/O=${ORG}/CN=${CN}" > /dev/null 2>&1

  echo -e "${OK_TEXT} Private key 'openssl-ca/private/${CN}.key.pem' created."

  openssl ca -batch -extensions v3_leaf \
  -in "${BASE}/${CN}.csr.pem" \
  -out "${BASE}/${CN}.cert.pem" > /dev/null 2>&1

  echo -e "${OK_TEXT} Certificate 'openssl-ca/${CN}.cert.pem' created."
}

###############################################################################
# Main

function main() {
  if [[ "${1:-}" =~ ^-h|--help$ ]]
  then
    print_help
  elif [[ "${1:-}" =~ ^--build-root-ca$ ]]
  then
    build_root_ca "$@"
  elif [[ "${1:-}" =~ ^--create-signing-key$ ]]
  then
    create_signing_key "$@"
  else
    print_help
  fi
}

main "$@"
