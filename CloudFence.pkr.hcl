packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.6" # 현재 버전
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "ami_name" {
  type    = string
  default = null
}

variable "aws_region" {
  type    = string
  default = null
}

variable "instance_type" {
  type    = string
  default = null
}

variable "ssh_timeout" {
  type    = string
  default = "5m"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "tag_name" {
  type    = string
}

variable "tag_environment" {
  type    = string
}

variable "tag_created_by" {
  type    = string
}

variable "ami_filter_name" {
  type    = string
}

variable "ami_share_account_id" {
  type    = string
  default = ""
}


source "amazon-ebs" "Ubuntu" {
  ami_name      = var.ami_name # AMI 이름 충돌 방지
  region        = var.aws_region        # AWS 리전
  instance_type = var.instance_type    # 인스턴스 타입
  ami_users   = [var.ami_share_account_id] 

  # ssh_timeout = var.ssh_timeout 

  source_ami_filter {
    filters = {
        name                = var.ami_filter_name
        virtualization-type = "hvm"
        root-device-type    = "ebs"
    }
    owners = ["099720109477"]
    most_recent = true
    
  }
  ssh_username = var.ssh_username # SSH 사용자 이름

  tags = {
    Name        = var.tag_name
    Environment = var.tag_environment
    CreatedBy   = var.tag_created_by
}
}

  build {
    sources = [
      "source.amazon-ebs.Ubuntu"
    ]

    # Ansible 프로비저너를 사용하여 Ansible 플레이북 실행
    provisioner "ansible" {
      playbook_file = "./ansible/playbook.yml"
      galaxy_file = "./ansible/requirements.yml"
    
    }

  }
