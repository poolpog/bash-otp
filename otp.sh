#!/usr/bin/env bash

# Openssl encrypt/decrypt examples
# Encrypt file to file
#openssl enc -aes-256-cbc -salt -in file.txt -out file.txt.enc
# Decrypt file to stdout
#openssl enc -aes-256-cbc -d -salt -in file.txt.enc
# Decrypt file to file
#openssl enc -aes-256-cbc -d -salt -in file.txt.enc -out file.txt

# Init
TOKENFILES_DIR="$( dirname ${0} )/tokenfiles"
TOKENFILES_DIR_MODE="$( ls -ld ${TOKENFILES_DIR} | awk '{print $1}'| sed 's/.//' )"
U_MODE="$( echo $TOKENFILES_DIR_MODE | gawk  -F '' '{print $1 $2 $3}' )"
G_MODE="$( echo $TOKENFILES_DIR_MODE | gawk  -F '' '{print $4 $5 $6}' )"
A_MODE="$( echo $TOKENFILES_DIR_MODE | gawk  -F '' '{print $7 $8 $9}' )"

if [ "$( echo $G_MODE | egrep 'r|w|x' )" -o "$( echo $A_MODE | egrep 'r|w|x' )" ]; then
    echo "Perms on [${TOKENFILES_DIR}] are too permissive. Try 'chmod 700 ${TOKENFILES_DIR}' first"
    exit 1
fi

token="$1"
if [ -z "$token" ]; then echo "Need token filename"; exit 1; fi

# Returns the token
function get_decrypted_token_from_file {
    read -s -r -p "Password: " PASSWORD
    echo $PASSWORD | openssl enc -aes-256-cbc -d -salt -pass stdin -in ${TOKENFILES_DIR}/${token}.enc
}

function get_plaintext_token_from_file {
    cat ${TOKENFILES_DIR}/$token
}

if [[ -f "${TOKENFILES_DIR}/${token}.enc" ]]; then
    TOKEN=$( get_decrypted_token_from_file $token )
elif [[ -f "${TOKENFILES_DIR}/${token}" ]]; then
    TOKEN=$( get_plaintext_token_from_file $token )
else
    echo "ERROR: Key file [${TOKENFILES_DIR}/$token] doesn't exist"
    exit 1
fi

#TOKEN=$( get_decrypted_token_from_file $token )
echo
D=0
D="$( date  +%S )"
if [ $D -gt 30 ] ; then D=$( echo "$D - 30"| bc ); fi
if [ $D -lt 0 ] ; then D="00"; fi

while true; do
    D="$( date  +%S )"
    X=$( oathtool --totp -b $TOKEN )
    if [ $D = '59'  -o $D = '29' ] ; then
        echo "$D: $X"
    else
        echo -ne "$D: $X\r"
    fi
    OS=$( uname )
    if [[ $OS = "Darwin" ]]; then
        echo -n $X | pbcopy
    elif [[ $OS = "Linux" ]]; then
        echo -n $X | xclip -sel clip
    fi
    sleep 1
done
