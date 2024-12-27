#!/bin/bash
# This requires you to have IAM permissions for `ec2:DescribeInstances` and
# `ec2:DescribeRegions`.
set -euo pipefail

regions=$(aws ec2 describe-regions | jq -r '.Regions[].RegionName' | sort)
instances="[]"
for region in $regions; do
  list="$(aws ec2 describe-instances \
    --filter Name=tag-key,Values=Name \
    --query 'Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name,InstanceType:InstanceType,Name:Tags[?Key==`Name`]|[0].Value}' \
    --output json \
    --region $region | jq -r '. | flatten')"

  instances=$(echo "$instances" | jq -r --argjson l "${list}" '. + $l')
done

echo "$instances" | \
  jq -r '(["AZ","InstanceID","Name","Type","State"] | (., map(length*"-"))), (.[] | [.AZ, .Instance, .Name, .InstanceType, .State]) | @tsv' | \
  column -t -s $'\t'
