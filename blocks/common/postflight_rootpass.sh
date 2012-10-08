#!/bin/bash

# root password
echo -e "${HR}\\nNew root user password\\n${HR}"
_try_until_success "passwd" 5 || echo -e "\nERROR: password unchanged for root\n"
