#!/bin/bash

#do it right
if [  $# -le 2 ]
then
  echo "Usage: $(basename $0) [\"Human Name\"] [username] [email@example.com]"
  exit 1
fi

#check for deps
command -v pwgen > /dev/null
if [ $? != 0 ]; then
  echo "please install pwgen and try again"
  exit 1
fi

if [ -z "$JENKINS_USERNAME" ]; then
  echo "JENKINS_USERNAME not set, exiting."
  exit 1
fi

if [ -z "$JENKINS_PASSWORD" ]; then
  echo "JENKINS_PASSWORD not set, exiting."
  exit 1
fi

#pwgen function
makepass () {
  pwgen -cnsB 16 1
}

#set some vars
NEW_NAME=$1
NEW_USERNAME=$2
NEW_EMAIL=$3
NEW_JENK_PASS=$(makepass)
JENK_FILE="/tmp/jenkins-cli.jar"
JENK_URL="https://jenkins.trp.co"
JENK_PAYLOAD="jenkins.model.Jenkins.instance.securityRealm.createAccount(\"${NEW_USERNAME}\", \"${NEW_JENK_PASS}\")"
#reftab license id for jenkins
licid="XXXXX"
#collect the user's reftab loanee id
lnid=$(./reftab.sh -m GET -e loanees | jq --arg NAME "$NEW_NAME" '.[] | select(.name==$NAME) | .lnid')

# get jenkins cli jar file (gross)
if [ ! -f ${JENK_FILE} ]; then
echo "Getting jenkins cli"
wget --quiet --show-progress https://jenkins.trp.co/jnlpJars/jenkins-cli.jar -O ${JENK_FILE}
fi

# do jenkins
echo "Creating jenkins user"
echo ${JENK_PAYLOAD} | java -jar ${JENK_FILE} -s "${JENK_URL}" -auth "${JENKINS_USERNAME}":"${JENKINS_PASSWORD}" -noKeyAuth groovy = –

#do reftab
echo "Updating reftab"
./reftab.sh -e 'loans' -m 'POST' -b "{\"licids\":[$licid],\"lnid\":$lnid,\"due\": \"\",\"notes\":\"onboarding script\"}" | jq | grep '"status": "out"' || echo 'reftab failed'

#discuss
echo
echo "Jenkins url: ${JENK_URL}"
echo "Jenkins username: $NEW_USERNAME"
echo "Jenkins password: $NEW_JENK_PASS"
echo
