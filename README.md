# bash-otp
One-Time Password generator for CLI using bash, oathtool.

This is basically "Authy for the CLI"

Automatically copies (using modifier "-c") the token into your computer's copy buffer

This script supports both encrypted and plain-text token files, but my recommendation is to use encryption.

### Requirements

* oathtool (http://www.nongnu.org/oath-toolkit/)
* OpenSSL
* xclip (Linux)
* pbcopy (MacOS)

## Description

Set of bash shell scripts to generate OTP *value* from token using TOTP.

### Setup

First ensure that there is a directory "**tokenfiles**" in you **$HOME** directory or in the main directory where the script resides.

1. Create token file and encrypt it. Resulting file, "tokenfiles/tokenname.enc", is an encrypted file containing the token
  1. Put your token in a plaintext file in the tokenfiles/ directory:
  ```bash
  $ echo "1234567890abcdef" > tokenfiles/tokenname
  ```

  1. Encrypt the file with the included shell script:
  ```bash
  $ ./otp-lockfile.sh tokenfiles/tokenname
  Password: (enter a good password)
  ```

  1. Confirm it worked:
  ```bash
  $ ls tokenfiles/
  tokenname.enc
  ```

1. Run otp.sh; will produce roughly the following output:
  ```
$ ./otp.sh tokenname
OTP Password:
02: 123456
  ```

The number on the left is the seconds counter; a new TOTP token is generated every 30 seconds.

The number on the right is the 6-digit One-Time Password.

### Usage

```
./otp.sh [-1] [-c] [-s] <Token Name>

 -1 : Get 1 password and exit.
 -c : Copy to clipboard. This will be copied directly into the paste buffer. Just paste it anywhere.
 -s : Silent. Do not output anything to console.
```

## Contents

* Script to do the actual value generation
* Script to encrypt the token in a file
* Script to decrypt same
* Empty "tokenfiles/" directory
