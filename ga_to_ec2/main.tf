terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

variable "jsw_project" {
    type = string
    default = "awscast_to_ec2"
}

provider "aws" {
    region = "us-east-1"
    default_tags {
        tags = {
            jsw_project = var.jsw_project
        }
    }
}

#####
# BEGIN per-region provider declarations
# Terraform cannot instantiate providers in a loop (e.g. foreach).
# Therefore, we use a script in util/ to generate these repetitive
# per-region stanzas.
provider "aws" {
    alias = "us-east-1"
    region = "us-east-1"
    default_tags {
        tags = {
            jsw_project = var.jsw_project
        }
    }
}
provider "aws" {
    alias = "us-east-2"
    region = "us-east-2"
    default_tags {
        tags = {
            jsw_project = var.jsw_project
        }
    }
}
provider "aws" {
    alias = "us-west-1"
    region = "us-west-1"
    default_tags {
        tags = {
            jsw_project = var.jsw_project
        }
    }
}
provider "aws" {
    alias = "us-west-2"
    region = "us-west-2"
    default_tags {
        tags = {
            jsw_project = var.jsw_project
        }
    }
}
# END per-region provider declarations
#####

resource "aws_globalaccelerator_accelerator" "anydns2" {
    name = "awscast-demo-dns2"
    ip_address_type = "IPV4"
    enabled = true
    attributes {
        flow_logs_enabled = false
    }
}

resource "aws_globalaccelerator_listener" "anydns2" {
    accelerator_arn = aws_globalaccelerator_accelerator.anydns2.id
    client_affinity = "SOURCE_IP"
    protocol = "UDP"
    port_range {
        from_port = 53
        to_port = 53
    }
}

#####
# BEGIN per-region module invocations
# Terraform cannot pass in a provider alias using e.g. for_each.
# A script in util/ generates these repetitive invocations.
module "region-us-east-1" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.us-east-1
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns2.id
}
module "region-us-east-2" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.us-east-2
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns2.id
}
module "region-us-west-1" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.us-west-1
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns2.id
}
module "region-us-west-2" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.us-west-2
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns2.id
}
# END per-region module invocations
#####
