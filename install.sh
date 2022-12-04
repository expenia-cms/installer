#!/bin/bash
set -e

# (C) Expenia Group by mynosci. 2022 

export EXPENIA_VERSION="b1"
export GITHUB_BASE_URL="https://raw.githubusercontent.com/expenia-cms/installer"

# Import Couleurs
export ERR='\033[0;31m'
export COLOR_NC='\033[0m'
export INFO='\033[96m'
export SUCCESS='\033[92m'
# Vérification du module CURL
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
apt install -y php8.1 php8.1-{cli,gd,mysql,pdo,mbstring,tokenizer,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server redis cron
echo -e "${SUCCESS} * Installation des dépendances réussie"
