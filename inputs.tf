variable "public_key_path" {
  type = "string"
  default = "/root/.ssh/id_rsa.pub"
}

variable "gitlabnew_login_key_path" {
  type = "string"
  default = "/root/.ssh/gitlabnew.pub"
}


variable "private_key_path" {
  type = "string"
  default = "/root/.ssh/id_rsa"
}

variable "minion-count" {
  type = "string"
  default = "2"
}

variable "ec2-ami" {
  type = "string"

  # ubuntu
  # default = "ami-07ebfd5b3428b6f4d"

  #centos
  # default = "ami-0a887e401f7654935"

  #ubuntu - 64-bit x86
  default = "ami-0ac80df6eff0e70b5"

}

variable "ec2-type" {
  type = "string"
  default = "t2.medium"
}

variable "kube-master" {
  type = "string"
  default = "kube-master"
}

variable "kube-minion" {
  type = "string"
  default = "kube-minion"
}

variable "vpc_cidr_block" {
  type = "string"
  default = "172.31.0.0/16"
}

variable "kube-master_cidr" {
  type = "string"
  default = "172.31.96.0/20"
  # default = "172.31.0.0/19"
}

variable "kube-minion_cidr" {
  type = "string"
  default = "172.31.112.0/20"
  # default = "172.31.32.0/19"
}