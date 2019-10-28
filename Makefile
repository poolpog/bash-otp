PREFIX_DIR="${HOME}/.local/"
APP_DIR="${PWD}"


install:
	ln -nsf $(APP_DIR)/otp $(PREFIX_DIR)/bin/
