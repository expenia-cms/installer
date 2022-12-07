#!/bin/bash
set -e

## fonction gen_pwd
password_input() {
  local __resultvar=$1
  local result=''
  local default="$4"

  while [ -z "$result" ]; do
    echo -n "* ${2}"

    while IFS= read -r -s -n1 char; do
      [[ -z $char ]] && {
        printf '\n'
        break
      }                               # ENTER pressed; output \n and break.
      if [[ $char == $'\x7f' ]]; then # backspace was pressed
        # Only if variable is not empty
        if [ -n "$result" ]; then
          # Remove last char from output variable.
          [[ -n $result ]] && result=${result%?}
          # Erase '*' to the left.
          printf '\b \b'
        fi
      else
        # Add typed char to output variable.
        result+=$char
        # Print '*' in its stead.
        printf '*'
      fi
    done
    [ -z "$result" ] && [ -n "$default" ] && result="$default"
    [ -z "$result" ] && print_error "${3}"
  done

  eval "$__resultvar="'$result'""
}
## (C) Expenia Group by mynosci. 2022

export EXPENIA_VERSION="b1"
export GITHUB_BASE_URL="https://raw.githubusercontent.com/expenia-cms/installer"

## Import Couleurs
export ERR='\033[0;31m'
export COLOR_NC='\033[0m'
export INFO='\033[96m'
export SUCCESS='\033[92m'
## Vérification du module CURL
if ! [ -x "$(command -v curl)" ]; then
  echo -e "${ERR}[improved][ACT] apt: installation | curl package"
  apt update -y
  apt install curl -y
  echo -e "${INFO} Redémarrez le script d'installation svp..."
  apt-get install bash wget
  exit 1
fi

echo -e "${INFO} Installation par défaut en cours de lancement..."
echo -e "${INFO} * Installation des dépendances"
sleep 5
apt-get install -y software-properties-common curl apt-transport-https ca-certificates gnupg
add-apt-repository -y ppa:ondrej/php
apt update -y
apt install -y php8.1 php8.1-{cli,gd,mysql,pdo,mbstring,tokenizer,bcmath,xml,fpm,curl,zip} mariadb-server
echo -e "${SUCCESS} * Installation des dépendances réussie"


  ## Configuration BDD
  echo -e "${INFO}* Installation des tables SQL => Connexion requise"
  echo ""
  echo ""

  echo -n -e "${INFO}* Nom de la base de données (expenia): "
  read -r MYSQL_DB_INPUT

  [ -z "$MYSQL_DB_INPUT" ] && MYSQL_DB="expenia" || MYSQL_DB=$MYSQL_DB_INPUT

  echo -n -e "${INFO}* Utilisateur (expeniauser): "
  read -r MYSQL_USER_INPUT

  [ -z "$MYSQL_USER_INPUT" ] && MYSQL_USER="expeniauser" || MYSQL_USER=$MYSQL_USER_INPUT

  ## Gestion SQL - Mot de passe
  rand_pw=$(
    tr -dc 'A-Za-z0-9!"#$%&()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c 64
    echo
  )
  password_input MYSQL_PASSWORD "Mot de passe BDD : " "" "$rand_pw"

  ## Serveur Web (installation)
  apt-get install nginx ruby-http -y
  cd /tmp/
  wget https://raw.githubusercontent.com/expenia-cms/installer/expenia.conf
  rm -rf /etc/nginx/sites-available/default && rm -rf /etc/nginx/sites-enabled/default
  mv expenia.conf /etc/nginx/sites-available/ && ln -s /etc/nginx/sites-available/expenia.conf /etc/nginx/sites-enabled/expenia.conf
  mkdir -p /usr/local/expenia/
  cd /usr/local/expenia
