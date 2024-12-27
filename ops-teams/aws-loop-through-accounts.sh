# Run this script first; it will call aws-put-security-contact.sh.  If you need to put a contact other than security, the parameters in
# the other script can be modified.
#
# original script https://aws.amazon.com/blogs/mt/programmatically-managing-alternate-contacts-on-member-accounts-with-aws-organizations/
#
# User running script will need account: GetAlternateContact, account: PutAlternateContact, and account: DeleteAlternateContact
# The fastest way to provide that if not in the admins group is to assign that user the AWSAccountManagementFullAccess managed policy in IAM.

#! /bin/bash
    managementaccount=`aws organizations describe-organization --query Organization.MasterAccountId --output text`

    for account in $(aws organizations list-accounts --query 'Accounts[].Id' --output text); do

            if [ "$managementaccount" -eq "$account" ]
                     then
                         echo 'Skipping management account.'
                         continue
            fi
            ./aws-put-security-contact.sh -a $account
            sleep 0.2
    done
