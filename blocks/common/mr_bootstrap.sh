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
read -p "Repository username:" _auth_username

_double_check_until_match "Github passphrase for username $_github_username"
_auth_passphrase="$_DOUBLE_CHECK_RESULT"

MR_BOOTSTRAP="$(echo "${MR_BOOTSTRAP}" | sed "s+^\(.*://\)\(.*\)$+\1${_auth_username}:${_auth_password}@\2+")"
fi

su $USERNAME -l -c "export AUTH_USERNAME=\"$_auth_username\"; export AUTH_PASSPHRASE=\"$_auth_passphrase\"; mr --trust-all bootstrap \"${MR_BOOTSTRAP}\""

