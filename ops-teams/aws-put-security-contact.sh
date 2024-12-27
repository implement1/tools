#! /bin/bash

# Do not run this script directly; run aws-loop-through-accounts.sh, which will provide the account IDs for this action.

while getopts a: flag
do
    case "${flag}" in
        a) account_id=${OPTARG};;
    esac
done

echo 'Put security contact for account '$account_id'...'
aws account put-alternate-contact   --account-id $account_id   --alternate-contact-type=SECURITY   --email-address=security@trp.com   --phone-number=""   --title=""   --name=""
echo 'Done putting security contact for account '$account_id'.'
