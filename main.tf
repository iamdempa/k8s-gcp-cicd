provider "aws" {
  region = "${local.region}"
}

terraform {
    backend "s3" {
        bucket = "terraform-state-banuka-cicd"
        key = "terraform/terraform.tfstate"
        region = "us-east-1"
    }
}

data "aws_vpc" "default" {
  default = true
} 


# kube-master Subnet
resource "aws_subnet" "kube-master-subnet" {
  vpc_id = "${data.aws_vpc.default.id}"
  cidr_block = "${var.kube-master_cidr}"

  tags = {
    Name = "kube-master-subnet"
  }
}

# kube-minion Subnet
resource "aws_subnet" "kube-minion-subnet" {
  vpc_id = "${data.aws_vpc.default.id}"
  cidr_block = "${var.kube-minion_cidr}"

  tags = {
    Name = "kube-minion-subnet"
  }
}

# security Group for master
resource "aws_security_group" "sg-kube-master-allow-ssh" {
  name = "kubernetes-master-sg"
  description = "sg to allow only ssh access to kube-master"
  vpc_id = "${data.aws_vpc.default.id}"

  

  # for ansible and kubernetes
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # for joining the minions to the master 
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self        = true
  }

  # for ansible
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kubernetes-master-sg"
  }
}

# security Group for minions
resource "aws_security_group" "sg-kube-minions-allow-ssh" {
  name = "kubernetes-minion-sg"
  description = "sg to not to allow any inbound traffic, only outbound traffic"
  vpc_id = "${data.aws_vpc.default.id}"

    # for ansible and kubernetes
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "kubernetes-minion-sg"
  }
}

# key-pair
resource "aws_key_pair" "public" {
  key_name = "gitlabnew"
  public_key = "${file("${var.gitlabnew_login_key_path}")}"
}
 
# kube-master
resource "aws_instance" "kubernetes_master" {
  ami = "${var.ec2-ami}"
  instance_type = "${var.ec2-type}"
  key_name = "${aws_key_pair.public.key_name}"
  subnet_id = "${aws_subnet.kube-master-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sg-kube-master-allow-ssh.id}"]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash           
              sudo amazon-linux-extras install ansible2 -y
              echo "${file("${var.public_key_path}")}" >> /root/.ssh/authorized_keys
              echo "${file("${var.gitlabnew_login_key_path}")}" >> /root/.ssh/gitlabnew_login_key_path.txt
              sudo hostname kube-master
              pwd
            EOF

  tags = {
      Name = "kube-master"
  }
}

resource "aws_instance" "kubernetes_minion" {
  ami = "${var.ec2-ami}"
  count = "${var.minion-count}"
  instance_type = "${var.ec2-type}"
  key_name = "${aws_key_pair.public.key_name}"
  subnet_id = "${aws_subnet.kube-master-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sg-kube-master-allow-ssh.id}"]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash           
              echo "${file("${var.public_key_path}")}" >> /root/.ssh/authorized_keys  
              sudo hostname kube-minion-${count.index}             
            EOF

  tags = {
      Name = "kube-minion-${count.index}"
  }
}

resource "local_file" "example" {
  content  = join("\n", aws_instance.kubernetes_minion[*].public_ip)
  filename = "/etc/ansible/machan"
}

# resource "local_file" "ansible-hosts" {
#   content  = join("\n", aws_instance.kubernetes_minion[*].public_ip)
#   filename = "/etc/ansible/hosts"
# }

resource "null_resource" "web3" {

 triggers  = {
    key = "${uuid()}"
  }

  provisioner "local-exec" {
      command = "rm -rf ~/.ssh/known_hosts"
  }

  provisioner "local-exec" {
        command = <<EOD
cat <<EOF > /etc/ansible/hosts
[all] 
${aws_instance.kubernetes_master.public_ip}
${aws_instance.kubernetes_minion.0.public_ip}
${aws_instance.kubernetes_minion.1.public_ip}
[kube-master]
${aws_instance.kubernetes_master.public_ip}
[kube-minions]
${aws_instance.kubernetes_minion.0.public_ip}
${aws_instance.kubernetes_minion.1.public_ip}
EOF
EOD
  }

  # provisioner "local-exec" {
  #   command = "num1=${var.minion-count} && num2=1 && num3=$[num1 - num2] && for i in $(seq 0 $num3); do echo ${aws_instance.kubernetes_minion..public_ip} > /etc/ansible/machan.txt; done"
  #   # command = "num1=${var.minion-count} num2=1 num3=$[num1 - num2] for i in $(seq 0 $num3); do echo $1; done"
  # }
 }

#  ${aws_instance.kubernetes_minion.0.public_ip}
# ${aws_instance.kubernetes_minion.1.public_ip}


# [master] 
# master ansible_host="${aws_instance.kubernetes_master.public_ip}" ansible_user=root 
# [minions] 
# worker1 ansible_host="${aws_instance.kubernetes_minion.0.public_ip}" ansible_user=root
# worker2 ansible_host="${aws_instance.kubernetes_minion.1.public_ip}" ansible_user=root


output "master-ip" {
    value = ["${aws_instance.kubernetes_master.*.public_ip}"]
} 


output "minion-ips" {
    value = ["${aws_instance.kubernetes_minion.*.public_ip}"]
} 

