#!/usr/bin/env python
'''
Generates per-region provider and module stanzas to be cut/pasted
to the root main.tf file.  This is tedious and mistake-prone if
done by hand.
'''

import operator
import boto3

eligible_instance_types = [
    't4g.nano',
    't3.nano',
    't2.nano',
]

def print_one_module_invocation(region):
    # figure out instance type e.g. t4g.nano or whatever
    rc = boto3.client(service_name='ec2', region_name=region)
    available = rc.describe_instance_types()
    avail_by_type = {}
    for it in available['InstanceTypes']:
        avail_by_type[it['InstanceType']] = it
    for eligible_type in eligible_instance_types:
        if eligible_type in avail_by_type:
            dns_instance_type = avail_by_type[eligible_type]
            break
    else:
        raise ValueError(F'AWS region {region} has no eligible instance type.')
    # based on instance type, set AMI filter using CPU type arm64 or amd64
    if 'arm64' in dns_instance_type['ProcessorInfo']['SupportedArchitectures']:
        dns_ami_name_filter = 'ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*'
    elif 'x86_64' in dns_instance_type['ProcessorInfo']['SupportedArchitectures']:
        dns_ami_name_filter = 'ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*'

    print(F'''module "region-{region}" {{
    source = "./per_region"
    providers = {{
        aws = aws
        aws.per_region = aws.{region}
    }}
    dns_ami_name_filter = "{dns_ami_name_filter}"
    dns_instance_type = "{dns_instance_type['InstanceType']}"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}}''')

def print_one_provider(region):
    print(F'''provider "aws" {{
    alias = "{region}"
    region = "{region}"
    default_tags {{
        tags = {{
            jsw_project = "awscast"
        }}
    }}
}}''')

c = boto3.client('ec2')
region_descriptions = c.describe_regions(AllRegions=False)
sorted_region_descriptions = sorted(region_descriptions['Regions'], key=operator.itemgetter('RegionName'))
print('''
#####
# BEGIN per-region provider declarations
# Terraform cannot instantiate providers in a loop (e.g. foreach).
# It requires simple, static provider configurations.  This is related
# to how it keeps track of state behind the scenes.
# Therefore, we use a script in util/ to generate these repetitive
# pre-region stanzas.
''')

for region in sorted_region_descriptions:
    print_one_provider(region=region['RegionName'])

print('''
# END per-region provider declarations
#####
''')

print('''
#####
# BEGIN per-region module invocations
# Terraform cannot pass in a provider alias using e.g. for_each.
# See https://github.com/hashicorp/terraform/issues/24476
#
# AFAIK Terragrunt is also not a fix, because of limits on its ability
# to pass provider references to Terraform.
# See https://github.com/gruntwork-io/terragrunt/issues/1095
#
# A script in util/ generates these repetitive invocations.
''')

for region in sorted_region_descriptions:
    print_one_module_invocation(region['RegionName'])

print('''
# END per-region module declarations
#####
''')

