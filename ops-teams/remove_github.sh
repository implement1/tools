#!/bin/bash

# usage
if [  $# -le 0 ]
then
  echo "Usage: $(basename $0) [github username]"
  # echo "for a list of teams: $(basename $0) teams"
  exit 1
fi

#check for deps
if [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_TOKEN not set, exiting."
  echo "export GITHUB_TOKEN='youractualgithubtoken' and try again."
  exit 1
fi

#set some vars
GIT_USER=$1

# do github
echo "Removing ${GIT_USER} from github organization"
curl -H "Authorization: token $GITHUB_TOKEN" -X DELETE https://api.github.com/orgs/nsone/memberships/${GIT_USER}
