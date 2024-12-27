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
NEW_NAME=$1
NEW_USERNAME=$2
NEW_EMAIL=$3
NEW_GRAF_PASS=$(makepass)
GRAF_URL="http://dash.trp.co:3000"
GRAF_USERS_ENDPOINT="/api/admin/users"
GRAF_PAYLOAD={\"name\":\"${NEW_NAME}\",\"email\":\"${NEW_EMAIL}\",\"login\":\"${NEW_USERNAME}\",\"password\":\"${NEW_GRAF_PASS}\"}


licid="XXXXX"
lnid=$(./reftab.sh -m GET -e loanees | jq --arg NAME "$NEW_NAME" '.[] | select(.name==$NAME) | .lnid')

# do grafana
echo "Creating grafana user..."
curl -s -X POST -H "Content-Type: application/json" -d "${GRAF_PAYLOAD}" -u ${GRAFANA_USERNAME}:${GRAFANA_PASSWORD} ${GRAF_URL}${GRAF_USERS_ENDPOINT} | jq
echo
echo "Grafana url: ${GRAF_URL} (requires prod vpn)"
echo "Grafana username: $NEW_USERNAME"
echo "Grafana password: $NEW_GRAF_PASS"
echo

#do reftab
echo "Updating reftab"
./reftab.sh -e 'loans' -m 'POST' -b "{\"licids\":[$licid],\"lnid\":$lnid,\"due\": \"\",\"notes\":\"onboarding script\"}" | jq | grep '"status": "out"' || echo 'reftab failed'
