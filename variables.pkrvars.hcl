variable "ami_name" {
  default = "WHS-CloudFence-{{timestamp}}"
}

variable "aws_region" {
  default = "ap-northeast-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ssh_timeout" {
  default = "10m"
}

variable "ssh_username" {
  default = "ubuntu"
}

variable "tag_name" {
  default = "WHS-CloudFence"
}

variable "tag_environment" {
  default = "Production"
}

variable "tag_created_by" {
  default = "Packer"
}

variable "ami_filter_name" {
  default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}
