# bash-otp
One-time Password generator for CLI using bash, oathtool

## Description

Set of bash shell scripts to generate OTP *value* from token using TOTP.

### Usage

1. Create token file
    $ echo "1234567890abcdef" > tokenfile
    $ ./2fa-lockfile.sh tokenfile
    $ ls tokenfile*
    tokenfile.enc
    
    (enter a good password)
    
    Results in a file, "tokenfile.enc", which is an encrypted file containing the token
    
1. Run 2fa.sh
    $ 2fa.sh tokenfile
    123456

### Requires

* oathtool (http://www.nongnu.org/oath-toolkit/)
* OpenSSL


## Contents

* Script to do the actual value generation
* Script to encrypt the token in a file
* Script to decrypt same

