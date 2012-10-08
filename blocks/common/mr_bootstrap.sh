#!/bin/bash

# su new user
# ------------------------------------------------------------------------
_installaur mr

_auth=false
echo -e "\nYou specified the following 'mr' bootstrap url:"
echo -e "$MR_BOOTSTRAP\n"
echo -e "\nDo you want to authenticate with a username/passphrase?"
echo "This will be submitted in the following format:"
echo "https://username:passphrase@rest.of.url.here"
echo -e "\n(y/n)"
read _answer
shopt -s nocasematch; [[ "$_answer" == y* ]] && _auth=true; shopt -u nocasematch

if $_auth; then
_double_check_until_match "Repository username:"
_auth_username="$_DOUBLE_CHECK_RESULT"

_double_check_until_match "Github passphrase for username $_github_username"
_auth_passphrase="$_DOUBLE_CHECK_RESULT"

MR_BOOTSTRAP="$(echo "${MR_BOOTSTRAP}" | sed "s+^\(.*://\)\(.*\)$+\1${_auth_username}:${_auth_password}@\2+")"

# we're exporting env with su below, so these variables should be accessible to the mr config file as well
export AUTH_USERNAME="$_auth_username"
export AUTH_PASSWORD="$_auth_password"
fi

su $USERNAME -l -c "mr --trust-all bootstrap \"${MR_BOOTSTRAP}\""
