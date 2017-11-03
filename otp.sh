#!/usr/bin/env bash

# Openssl encrypt/decrypt examples
# Encrypt file to file
#openssl enc -aes-256-cbc -salt -in file.txt -out file.txt.enc
# Decrypt file to stdout
#openssl enc -aes-256-cbc -d -salt -in file.txt.enc
# Decrypt file to file
#openssl enc -aes-256-cbc -d -salt -in file.txt.enc -out file.txt

function validate_modifiers {
  if [[ $MODIFIERS == *c* ]]; then
    CLIPBOARD=true
  fi
  if [[ $MODIFIERS == *1* ]]; then
    ONE_TIME=true
  fi
  if [[ $MODIFIERS == *s* ]]; then
    OUTPUT="/dev/null"
  else
    OUTPUT="/dev/stdout"
  fi
}

function check_permissions {
  TOKENFILES_DIR_MODE="$( ls -ldH $TOKENFILES_DIR | awk '{print $1}'| sed 's/.//' )"
  U_MODE="$( echo $TOKENFILES_DIR_MODE | gawk  -F '' '{print $1 $2 $3}' )"
  G_MODE="$( echo $TOKENFILES_DIR_MODE | gawk  -F '' '{print $4 $5 $6}' )"
  A_MODE="$( echo $TOKENFILES_DIR_MODE | gawk  -F '' '{print $7 $8 $9}' )"

  if [ "$( echo $G_MODE | egrep 'r|w|x' )" -o "$( echo $A_MODE | egrep 'r|w|x' )" ]; then
    echo "Perms on [$TOKENFILES_DIR] are too permissive. Try 'chmod 700 $TOKENFILES_DIR' first"
    exit 1
  fi
}

function decrypt_token_from_file {
  read -s -r -p "OTP Password: " PASSWORD
  echo $PASSWORD | openssl enc -aes-256-cbc -d -salt -pass stdin -in $1
}

function plaintext_token_from_file {
  cat $1
}

function check_file {
  TOKEN_PATH=${TOKENFILES_DIR}/${TOKEN_NAME}
  FILES=("${TOKEN_PATH}.enc" "${TOKEN_PATH}")

  for file in ${FILES[@]}; do
    if [[ -f "${file}" ]]; then
      TOKEN_FILE="${file}"
      return 0
    fi
  done

  echo "ERROR: Token files [${FILES[@]}] doesn't exist"
  exit 1
}

function get_token {
  if [[ ${TOKEN_FILE} == *.enc ]]; then
    TOKEN=$( decrypt_token_from_file $TOKEN_FILE )
  else
    TOKEN=$( plaintext_token_from_file $TOKEN_FILE )
  fi
}

function verify_clip_command {
  command -v $1 >/dev/null 2>&1 || { echo >&2 "Required '$1'. Install it and try again."; echo "Aborting."; exit 1; }
}

function copy_to_clipboard {
  if [ "$X" != "$LAST_PASSWORD" ]; then
    OS=$( uname )
    if [[ $OS = "Darwin" ]]; then
      verify_clip_command "pbcopy"
      echo -n $X | pbcopy
    elif [[ $OS = "Linux" ]]; then
      verify_clip_command "xclip"
      echo -n $X | xclip -sel clip
    fi
    LAST_PASSWORD="$X"
  fi
}

function show_usage {
  echo "ERROR: $1"
  echo "Usage: ./otp.sh [1cs] <Token Name>"
  echo
  echo " 1 : Get 1 password and exit"
  echo " c : Copy to clipboard"
  echo " s : Silent"
  exit 1
}

if [ "$#" == 0 ]; then
  show_usage "Missing parameters"
fi

PARAMETERS=( "$@" )
TOKEN_NAME="${PARAMETERS[${#PARAMETERS[@]}-1]}"

unset "PARAMETERS[${#PARAMETERS[@]}-1]"
MODIFIERS=${PARAMETERS[@]}

OTP_HOME="$( echo ${HOME} || dirname ${0} )"
TOKENFILES_DIR="${OTP_HOME}/tokenfiles"

#Init
check_permissions
check_file
validate_modifiers
get_token

echo > $( echo "$OUTPUT" )

LAST_PASSWORD=0

while true; do
  D="$( date  +%S )"
  X=$( oathtool --totp -b "$TOKEN" )

  if [ $CLIPBOARD ]; then
    copy_to_clipboard $X
  fi

  echo -ne "$D: $X\r" > $( echo "$OUTPUT" )

  if [ $ONE_TIME ]; then
    echo "$D: $X" > $( echo "$OUTPUT" )
    exit 0;
  fi
  sleep 1
done
