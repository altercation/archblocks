#!/bin/bash

# su new user
# ------------------------------------------------------------------------
_installaur mr

echo "Do you want to authenticate with a username/passphrase?"
echo "This will be sent in the following format:"
echo "https://username:passphrase@rest.of.url.here"
echo -e "\n(y/n)"
read _answer
[ "$_answer" == y* ]

_double_check_until_match "Repository username:"
_auth_username="$_DOUBLE_CHECK_RESULT"

_double_check_until_match "Github passphrase for username $_github_username"
_auth_passphrase="$_DOUBLE_CHECK_RESULT"

su $USERNAME -l -c "mr --trust-all bootstrap \"${MR_BOOTSTRAP}\""
