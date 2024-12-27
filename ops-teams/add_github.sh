#!/bin/bash

#usage / help
if [ "$1" == "teams" ]; then
	curl -sH "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/trp/teams | jq '.[] | .name'
  exit
fi

if [  $# -le 1 ]
then
  echo "Usage: $(basename $0) [github username] [team]"
  echo "for a list of teams: $(basename $0) teams"
  exit 1
fi


#check for deps
if [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_TOKEN not set, exiting."
  exit 1
fi

#set some vars
GIT_USER=$1
GIT_TEAM=$2
GIT_TEAM_ID=$(curl -sH "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/trp/teams | jq '.[] | .name, .id' | grep -A1 ${GIT_TEAM} | tail -1)

# do github
echo "Inviting ${GIT_USER} to ${GIT_TEAM}"
curl -H "Authorization: token $GITHUB_TOKEN" -X PUT https://api.github.com/teams/${GIT_TEAM_ID}/memberships/${GIT_USER}
