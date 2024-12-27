#!/bin/bash

#do it right
if [  -z $1 ]; then
  echo "Usage: $(basename $0) [username]"
  exit 1
fi


command -v aws > /dev/null
if [ $? != 0 ]; then
  echo "please install awscli, then run 'aws configure', and then try again"
  exit 1
fi

#set some vars
USERNAME=$1

# check if user exists

aws iam get-user --user-name ${USERNAME} > /dev/null 2>&1
if [ $? != 0 ]; then
  echo "User ${USERNAME} username not found! byebye."
  exit 1
fi

echo "Removing aws user..."
for GROUP in $(aws iam list-groups-for-user --user-name $USERNAME | awk -F '"' '/GroupName/ {print$4}'); do
  aws iam remove-user-from-group --user-name $USERNAME --group-name $GROUP
done
for KEY_ID in $(aws iam list-access-keys --user-name $USERNAME | awk -F '"' '/AccessKeyId/ {print$4}'); do
  aws iam delete-access-key --access-key-id $KEY_ID --user-name $USERNAME
done
aws iam delete-login-profile --user-name $USERNAME
aws iam delete-user --user-name $USERNAME
