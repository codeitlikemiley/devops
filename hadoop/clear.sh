#!/bin/bash

# unofficial bash strict mode
set -euo pipefail
IFS=$'\n\t'

# run from any directory (no symlink allowed)
CURRENT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)
cd ${CURRENT_PATH}

##############################

# common
KEY_NAME="hadoop_rsa"
DATA_PATH="data"

##############################

explosion() {
cat<<"EOT"
                             ____
                     __,-~~/~    `---.
                   _/_,---(      ,    )
               __ /        <    /   )  \___
- ------===;;;'====------------------===;;;===----- -  -
                  \/  ~"~"~"~"~"~\~"~)~"/
                  (_ (   \  (     >    \)
                   \_( _ <         >_>'
                      ~ `-i' ::>|--"
                          I;|.|.|
                         <|i::|i|`.
                        (` ^'"`-' ")
------------------------------------------------------------------

EOT
}

read -p "Are you sure? [y/n]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  vagrant destroy -f
  rm -frv \
    .vagrant \
    ${DATA_PATH}/$KEY_NAME* \
    ${DATA_PATH}/namenode \
    ${DATA_PATH}/resource-manager \
    ${DATA_PATH}/node-{1,2,3}
  explosion
fi