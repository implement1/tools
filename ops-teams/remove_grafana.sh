#!/bin/bash

#do it right
if [  $# -le 2 ]
then
  echo "Usage: $(basename $0) [\"Human Name\"] [username] [email@example.com]"
  exit 1
fi

#pwgen function
makepass () {
  pwgen -cnsB 16 1
}

#check for deps
command -v pwgen > /dev/null
if [ $? != 0 ]; then
  echo "please install pwgen and try again"
  exit 1
fi

if [ -z "$GRAFANA_USERNAME" ]; then
  echo "GRAFANA_USERNAME not set, exiting."
  exit 1
fi

if [ -z "$GRAFANA_PASSWORD" ]; then
  echo "GRAFANA_PASSWORD not set, exiting."
  exit 1
fi

#set some vars
BYEBYE_NAME=$1
BYEBYE_USERNAME=$2
BYEBYE_EMAIL=$3
GRAF_URL="http://dash.trp.com:3000"
GRAF_USERS_ENDPOINT="/api/users/"
GRAF_USERS_ADMIN_ENDPOINT="/api/admin/users/"

#collect the user's grafana id
GRAF_ID=$(curl -s -X GET -H "Content-Type: application/json" -u ${GRAFANA_USERNAME}:${GRAFANA_PASSWORD} -H "Content-Type: application/json" ${GRAF_URL}${GRAF_USERS_ENDPOINT} | jq --arg NAME "$BYEBYE_NAME" '.[] | select(.name==$NAME) | .id')
#reftab license id for grafana
licid="XXXXX"
#collect the user's reftab loanee id
lnid=$(./reftab.sh -m GET -e loanees | jq --arg NAME "$BYEBYE_NAME" '.[] | select(.name==$NAME) | .lnid')
#collect the user's grafana loan id
lid=$(./reftab.sh -e "loans?lnid=${lnid}&licid=${licid}" -m 'GET' | jq '.[] | .lid')

# do grafana
echo "Removing grafana user..."
curl -sX DELETE -u ${GRAFANA_USERNAME}:${GRAFANA_PASSWORD} -H "Content-Type: application/json" ${GRAF_URL}${GRAF_USERS_ADMIN_ENDPOINT}${GRAF_ID} | jq | grep 'User deleted' || echo "Grafana removal failed"
echo
#do reftab
echo "Removing reftab license"
./reftab.sh -e "loans/${lid}" -m 'PUT' -b '{"status":"in","notes":"techops offboarding script"}' | jq . | grep '"status": "in"' || echo "Reftab removal failed"
echo
