#!/bin/bash

#do it right
if [  -z $1 ]; then
  echo "Usage: $(basename $0) [username]"
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

command -v aws > /dev/null
if [ $? != 0 ]; then
  echo "please install awscli, then run 'aws configure', and then try again"
  exit 1
fi

#set some vars
NEW_USERNAME=$1
NEW_AWS_PASS=$(makepass)

# check if user exists

aws iam get-user --user-name ${NEW_USERNAME} > /dev/null 2>&1
if [ $? == 0 ]; then
  echo "User ${NEW_USERNAME} already exists! byebye."
  exit 1
fi

echo "Creating aws user..."
aws iam create-user --user-name ${NEW_USERNAME}
aws iam create-access-key --user-name ${NEW_USERNAME}
aws iam add-user-to-group --user-name ${NEW_USERNAME} --group-name basic-user
# adding to group nsone-dev removed 16 Apr 2021 because that group is going away in favor of role based.
aws iam list-access-keys --user-name ${NEW_USERNAME}
aws iam create-login-profile --user-name ${NEW_USERNAME} --password ${NEW_AWS_PASS} --password-reset-required
echo "Temporary AWS portal password: ${NEW_AWS_PASS}"
