
# designed for github

InstallBlock () { source /dev/stdin <<< "$(curl --fail --silent --raw ${BLOCK_PATH:-https://raw.github.com/altercation/archblocks/master/}$1/$2)"; }

