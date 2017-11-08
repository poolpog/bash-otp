#!/usr/bin/env bash

# Openssl encrypt/decrypt examples
# Encrypt file to file
#openssl enc -aes-256-cbc -salt -in file.txt -out file.txt.enc
# Decrypt file to stdout
#openssl enc -aes-256-cbc -d -salt -in file.txt.enc
# Decrypt file to file
#openssl enc -aes-256-cbc -d -salt -in file.txt.enc -out file.txt

function validate_modifiers {
  if [[ $MODIFIERS == *n* ]]; then
    NO_CLIPBOARD=true
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
  OS=$( uname )
  if [[ $OS = "Darwin" ]]; then
    PERMISSIONS=$( stat -L -f "%A" $1 )
  elif [[ $OS = "Linux" ]]; then
    PERMISSIONS=$( stat -L -c "%a" $1 )
  fi

  if [ $PERMISSIONS != $2 ]; then
    echo "Perms on [$1] are too permissive. Try 'chmod $2 $1' first"
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
      check_permissions $file "400"
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

function verify_command {
  command -v $1 >/dev/null 2>&1 || { echo >&2 "Required '$1'. Install it and try again."; echo "Aborting."; exit 1; }
}

function copy_to_clipboard {
  if [ "$NO_CLIPBOARD" != "true" ]; then
    if [ "$X" != "$LAST_PASSWORD" ]; then
      OS=$( uname )
      if [[ $OS = "Darwin" ]]; then
        verify_command "pbcopy"
        echo -n $X | pbcopy
      elif [[ $OS = "Linux" ]]; then
        verify_command "xclip"
        echo -n $X | xclip -sel clip
      fi
      LAST_PASSWORD="$X"
    fi
  fi
}

function set_tokenfiles_dir {
  TOKENFILES="tokenfiles"
  USER_HOME="$HOME/$TOKENFILES"
  BIN_HOME="$( dirname ${0} )/$TOKENFILES"

  if [[ -a "$USER_HOME" ]]; then
    TOKENFILES_DIR="$USER_HOME"
  elif [[ -a "$BIN_HOME" ]]; then
    TOKENFILES_DIR=$BIN_HOME
  else
    echo "ERROR: $USER_HOME directory does not exists."
    exit 1
  fi
}

function show_usage {
  echo "ERROR: $1"
  echo "Usage: $( basename ${0} ) [-1] [-n] [-s] <Token Name>"
  echo
  echo " -1 : Get 1 password and exit."
  echo " -n : Do not copy to clipboard."
  echo " -s : Silent. Do not output anything to console."
  exit 1
}

#Init
verify_command "openssl"

if [ "$#" == 0 ]; then
  show_usage "Missing parameters"
fi

set_tokenfiles_dir

PARAMETERS=( "$@" )
TOKEN_NAME="${PARAMETERS[${#PARAMETERS[@]}-1]}"

unset "PARAMETERS[${#PARAMETERS[@]}-1]"
MODIFIERS=${PARAMETERS[@]}

validate_modifiers
check_permissions $TOKENFILES_DIR "700"
check_file
get_token

if [[ ! $TOKEN =~ ^[0-9A-Z]+$ ]]; then
  exit 1
fi

echo > $( echo "$OUTPUT" )

LAST_PASSWORD=0

while true; do
  D="$( date  +%S )"
  X=$( oathtool --totp -b "$TOKEN" )

  copy_to_clipboard $X

  echo -ne "$D: $X\r" > $( echo "$OUTPUT" )

  if [ $ONE_TIME ]; then
    echo "$D: $X" > $( echo "$OUTPUT" )
    exit 0;
  fi
  sleep 1
done
