terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = "us-east-1"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}

#####
# BEGIN per-region provider declarations
# Terraform cannot instantiate providers in a loop (e.g. foreach).
# It requires simple, static provider configurations.  This is related
# to how it keeps track of state behind the scenes.
# Therefore, we use a script in util/ to generate these repetitive
# pre-region stanzas.

provider "aws" {
    alias = "ap-northeast-1"
    region = "ap-northeast-1"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "ap-northeast-2"
    region = "ap-northeast-2"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "ap-northeast-3"
    region = "ap-northeast-3"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "ap-south-1"
    region = "ap-south-1"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "ap-southeast-1"
    region = "ap-southeast-1"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "ap-southeast-2"
    region = "ap-southeast-2"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "ca-central-1"
    region = "ca-central-1"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "eu-central-1"
    region = "eu-central-1"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "eu-north-1"
    region = "eu-north-1"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "eu-west-1"
    region = "eu-west-1"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "eu-west-2"
    region = "eu-west-2"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "eu-west-3"
    region = "eu-west-3"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "sa-east-1"
    region = "sa-east-1"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "us-east-1"
    region = "us-east-1"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "us-east-2"
    region = "us-east-2"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "us-west-1"
    region = "us-west-1"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}
provider "aws" {
    alias = "us-west-2"
    region = "us-west-2"
    default_tags {
        tags = {
            jsw_project = "awscast"
        }
    }
}

# END per-region provider declarations
#####

resource "aws_globalaccelerator_accelerator" "anydns1" {
    name = "awscast-demo-dns1"
    ip_address_type = "IPV4"
    enabled = true
    attributes {
        flow_logs_enabled = false
    }
}

resource "aws_globalaccelerator_listener" "anydns1" {
    accelerator_arn = aws_globalaccelerator_accelerator.anydns1.id
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
# See https://github.com/hashicorp/terraform/issues/24476
#
# AFAIK Terragrunt is also not a fix, because of limits on its ability
# to pass provider references to Terraform.
# See https://github.com/gruntwork-io/terragrunt/issues/1095
#
# A script in util/ generates these repetitive invocations.

module "region-ap-northeast-1" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.ap-northeast-1
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-ap-northeast-2" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.ap-northeast-2
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-ap-northeast-3" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.ap-northeast-3
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    dns_instance_type = "t3.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-ap-south-1" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.ap-south-1
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-ap-southeast-1" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.ap-southeast-1
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-ap-southeast-2" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.ap-southeast-2
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-ca-central-1" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.ca-central-1
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-eu-central-1" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.eu-central-1
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-eu-north-1" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.eu-north-1
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-eu-west-1" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.eu-west-1
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-eu-west-2" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.eu-west-2
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-eu-west-3" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.eu-west-3
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-sa-east-1" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.sa-east-1
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-us-east-1" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.us-east-1
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-us-east-2" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.us-east-2
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-us-west-1" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.us-west-1
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}
module "region-us-west-2" {
    source = "./per_region"
    providers = {
        aws = aws
        aws.per_region = aws.us-west-2
    }
    dns_ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
    dns_instance_type = "t4g.nano"
    global_accelerator_listener_arn = aws_globalaccelerator_listener.anydns1.id
}

# END per-region module declarations
#####
