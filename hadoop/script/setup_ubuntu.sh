#!/bin/bash

# unofficial bash strict mode
set -euo pipefail
IFS=$'\n\t'

# run from any directory (no symlink allowed)
CURRENT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)
cd ${CURRENT_PATH}

##############################

FILE_PATH="/vagrant/file"
DATA_PATH="/vagrant/.data"
KEY_NAME="hadoop_rsa"
USER_NAME="hadoop"
HOME_PATH="/home/$USER_NAME"

##############################

function apt_update {
  echo "[*] apt update"
  apt-get -qq update && apt-get -qq upgrade -y
}

function setup_java {
  local LOG_PATH="/tmp/apt-java.log"
  echo "[*] setup java"

  add-apt-repository ppa:openjdk-r/ppa -y &> $LOG_PATH

  apt-get -qq update && apt-get install -y \
    openjdk-8-jdk \
    &> $LOG_PATH && \
    apt-get clean

  java -version

  # https://askubuntu.com/questions/866161/setting-path-variable-in-etc-environment-vs-profile
  # /usr/lib/jvm/java-8-openjdk-amd64
  echo "JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")" | sudo tee --append /etc/environment && \
    source /etc/environment
}

# param #1: <name>
function create_user {
  local NAME=$1
  echo "[*] create user: $NAME"

  useradd --create-home --shell /bin/bash $NAME
  usermod --append --groups sudo,$NAME $NAME
  id $NAME
  groups $NAME
}

##############################

function config_ssh {
  local SSH_PATH="$HOME_PATH/.ssh"
  echo "[*] config ssh"

  mkdir -p $SSH_PATH
  # default name to avoid -i parameter
  cp $DATA_PATH/$KEY_NAME $SSH_PATH/id_rsa
  # passphraseless
  cat $DATA_PATH/$KEY_NAME.pub >> $SSH_PATH/authorized_keys
  # avoid prompt first time
  cp $FILE_PATH/ssh/config $SSH_PATH/config
  # update permissions
  chmod 0600 $SSH_PATH/id_rsa $SSH_PATH/authorized_keys
  chown -R $USER_NAME:$USER_NAME $SSH_PATH
}

function config_profile {
  echo "[*] config profile"
  sed -i -r "s/alias ll='ls -alF'/alias ll='ls -alh'/" $HOME_PATH/.bashrc
  source $HOME_PATH/.bashrc
}

function config_host {
  echo "[*] config host"
  cat $FILE_PATH/hadoop/hosts >> /etc/hosts
}

function main {
  echo "[+] setup ubuntu"
  apt_update
  setup_java
  create_user $USER_NAME
  config_ssh
  config_profile
  config_host
  echo "[-] setup ubuntu"
}

main
