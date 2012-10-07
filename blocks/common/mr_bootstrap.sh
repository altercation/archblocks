#!/bin/bash

# su new user
# ------------------------------------------------------------------------
_installaur mr
su $USERNAME -l -c "mr --trust-all bootstrap \"${MR_BOOTSTRAP}\""
