#!/usr/bin/env bash
set -e

# decrypts file to standard out

# Examples, all use password-based encryption:
# Encrypt file to file
#openssl enc -aes-256-cbc -salt -in file.txt -out file.txt.enc
# Decrypt file to stdout
#openssl enc -aes-256-cbc -d -salt -in file.txt.enc
# Decrypt file to file
#openssl enc -aes-256-cbc -d -salt -in file.txt.enc -out file.txt

INPUT_FILE="$1"
OUTPUT_FILE=$( echo $INPUT_FILE | sed 's/.enc//' )
PW_FILE=$( mktemp pwfile.XXXXXXXX )

if [ ! -f "${INPUT_FILE}" ]; then
    echo "The file [${INPUT_FILE}] does not exist"
    exit 1
fi

read -s -r -p "Password to unlock file: " PASSWORD1

echo "${PASSWORD1}" > "${PW_FILE}"
openssl enc -aes-256-cbc -d -salt -in "${INPUT_FILE}" -out "${OUTPUT_FILE}" -pass file:"${PW_FILE}"
rm "${PW_FILE}"
