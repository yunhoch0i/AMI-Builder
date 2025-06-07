packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.6" # 현재 버전
      source  = "github.com/hashicorp/amazon"
    }
  }
}


source "amazon-ebs" "Ubuntu" {
  ami_name      = var.ami_name # AMI 이름 충돌 방지
  region        = var.aws_region        # AWS 리전
  instance_type = var.instance_type    # 인스턴스 타입


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
    ssh_username = "ubuntu" # SSH 사용자 이름

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

    provisioner "ansible" {
      playbook_file = "./ansible/playbook.yml"
      galaxy_file = "./ansible/requirements.yml"
    }
  }
