terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            configuration_aliases = [
                aws.per_region
            ]
        }
    }
}


variable "dns_ami_name_filter" {
    type = string
    description = "Filter value like ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
}

variable "dns_instance_type" {
    type = string
    description = "Instance type e.g. t4g.nano"
}

variable "global_accelerator_listener_arn" {
    type = string
}

data "aws_ami" "ubuntu" {
    provider = aws.per_region
    most_recent = true
    filter {
        name = "name"
        # This will be a value like ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*
        # We accept it as a module argument because amd64 vs arm64 depending on instance type
        values = [var.dns_ami_name_filter]
    }
    filter {
        name = "root-device-type"
        values = ["ebs"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "jsw" {
    provider = aws.per_region
    key_name = "tf-managed jeffsw6@gmail.com boomer 2013-05-28"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4k8nVaS9Ns+8jZ1C97eUcOvkFw6NOXS8e4xxG6XEH1l9PDluOCxAqgCvdKxX9ZhFvwW1SCSWuN95WrM7u/9p0flOX7DZFYld053ClWxMZZ4ZtKj8XWnmDU4LLXSmUWaKddW9pHZHvxfEFu+wCcnUiJM4NgS4owfaIGC3IOIXVrxsoNuoKyTQS9pRa5+3sMC3rHK8oWPkleJGO+cs8AxuetRtHS/ZHwshsyI27ROC/nIxZ7ZeKXf3g/jxEpbxI9LNFnocuUmeoNpndBFYND1ujwiHZvoWxx4ByiTRDNJDHJWdnJpz8rOmnoHeHFqV8F/I5CRG9Dh7aq5vd9LWdrkqb jeffsw6@gmail.com boomer 2013-05-28"
}

resource "aws_security_group" "dns_demo2" {
    provider = aws.per_region
    name = "dns_demo2"
    description = "Allow traffic for awscast DNS demo project"
    ingress {
        from_port = 53
        to_port = 53
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    ingress {
        from_port = 53
        to_port = 53
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}

resource "aws_instance" "dns_server_01" {
    provider = aws.per_region
    instance_type = var.dns_instance_type
    # Typically an Ubuntu 20.04 LTS AMI
    ami = data.aws_ami.ubuntu.id
    key_name = "tf-managed jeffsw6@gmail.com boomer 2013-05-28"
    user_data = file("dns_server_provisioner.sh")
    vpc_security_group_ids = [
        aws_security_group.dns_demo2.id
    ]
}

resource "aws_instance" "dns_server_02" {
    provider = aws.per_region
    instance_type = var.dns_instance_type
    # Typically an Ubuntu 20.04 LTS AMI
    ami = data.aws_ami.ubuntu.id
    key_name = "tf-managed jeffsw6@gmail.com boomer 2013-05-28"
    user_data = file("dns_server_provisioner.sh")
    vpc_security_group_ids = [
        aws_security_group.dns_demo2.id
    ]
}

resource "aws_globalaccelerator_endpoint_group" "anydns2" {
    provider = aws.per_region
    listener_arn = var.global_accelerator_listener_arn
    health_check_port = 80
    endpoint_configuration {
        client_ip_preservation_enabled = true
        endpoint_id = aws_instance.dns_server_01.id
    }
    endpoint_configuration {
        client_ip_preservation_enabled = true
        endpoint_id = aws_instance.dns_server_02.id
    }
}
