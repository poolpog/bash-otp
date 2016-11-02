# bash-otp
One-Time Password generator for CLI using bash, oathtool.

Automatically copys the token into your computer's copy buffer (MacOS only atm)

This is basically "Authy for the CLI"

This script supports both encrypted and plain-text token files, but my reccomendation is to use encryption.

### Requirements

* oathtool (http://www.nongnu.org/oath-toolkit/)
* OpenSSL


## Description

Set of bash shell scripts to generate OTP *value* from token using TOTP.

### Usage

First ensure that there is a directory "tokenfiles" in the main dir where the script resides.

1. Create token file
```
# Put your token in a plaintext file:
$ echo "1234567890abcdef" > tokenfile

#Encrypt the file with the included shell script:
$ ./otp-lockfile.sh tokenfiles/tokenfile

# Confirm it worked:
$ ls tokenfiles/
tokenfile.enc

(enter a good password)

Results in a file, "tokenfiles/tokenfile.enc", which is an encrypted file containing the token
```
    
1. Run otp.sh; will produce roughly the following output:
```
$ otp.sh tokenfile
Password:
02: 123456
```

The number on the left is the seconds counter; a new TOTP token is generated every 30 seconds.

## Contents

* Script to do the actual value generation
* Script to encrypt the token in a file
* Script to decrypt same

