#!/usr/bin/env python3
import subprocess
import json

"""
Python script to automate the configuration of AWS CLI profiles for multiple AWS accounts, set up Kubernetes configurations for EKS clusters, and handles region-specific AWS profiles.
"""

cmds = [
    "aws configure set role_arn arn:aws:iam::{id}:role/{name} --profile {name}",
    "aws configure set region us-east-1 --profile {name}",
    "aws configure set output json --profile {name}",
    "aws configure set source_profile default --profile {name}",
]

orgs = {
    "Accounts": [
        {
            "Name": "dev-aws", "Id": "XXXXXXXXXXXX", "Status": "ACTIVE"
        }
    ]
}


regional_accs = {
    "prod": ["us-east-1",  "us-east-2", "eu-west-1", "eu-central-1", "af-south-1", "me-south-1"],
    "stage": ["us-east-1", "eu-west-1", "eu-central-1", "af-south-1", "me-south-1"],
    "dev": ["us-east-1", "eu-west-1"],
}


def run(cmd):
    print("Running: {}".format(cmd))
    subprocess.run(cmd.split())


def _generate_alias(acc_name, region, suffix=""):
   
    if region == "us-east-1":
        return "{}{}".format(acc_name, suffix)
    else:
        return "{}-{}{}".format(acc_name, region, suffix)


def _update_kubeconfig(acc_name, region):
    """
    List clusters in a region and update kubeconfig with authentication information.
    """
    try:
        eks_output = subprocess.check_output("aws eks list-clusters --profile {} --region {}".format(acc_name, region).split())
        eks_info = json.loads(eks_output)
        for cluster in eks_info["clusters"]:
            try:
                alias_suffix = ""
                if len(eks_info["clusters"]) > 1:
                    alias_suffix = f"-{cluster}"
                alias = _generate_alias(acc_name, region, alias_suffix)
                run(
                    "aws eks update-kubeconfig --name {cluster} --alias {alias} --profile {name} --region {region}".format(
                        cluster=cluster,
                        alias=alias,
                        name=acc_name,
                        region=region))
            except Exception as e:
                print("Could not update kubeconfig for cluster {} in {}. Reason: {}".format(cluster, region, str(e)))
    except Exception as e:
        print("Could not list EKS clusters for account {} in {}. Reason: {}".format(acc_name, region, str(e)))


def main():
    try:
        acc_output = subprocess.check_output("aws organizations list-accounts".split())
        acc_info = json.loads(acc_output)
    except Exception as e:
        print("You don't have permissions to list organization. Reason: {}\nUsing hardcoded dictionary.".format(
            str(e)))
        acc_info = orgs

    for acc in acc_info["Accounts"]:
        acc_id, acc_name = acc["Id"], acc["Name"]
        print("Trying to setup account {}".format(acc["Name"]))
        if acc["Status"] != "ACTIVE":
            continue
        if "dev-" not in acc_name and "prod-" not in acc_name:
            continue
        for cmd in cmds:
            run(cmd.format(name=acc_name, id=acc_id))
        if acc_name in regional_accs:
            for region in regional_accs[acc_name]:
                _update_kubeconfig(acc_name, region)
        else:
            _update_kubeconfig(acc_name, "us-east-1")

    print("\033[91m[!] You need to run 'aws configure' and set the AWS key and access key")
    print("\033[91m[!] After that unset the AWS_ACCESS/AWS_SECRET env var as aws profile doesn't work")

if __name__ == "__main__":
    main()
