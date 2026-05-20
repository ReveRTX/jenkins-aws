terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "my_server" {
  instance_type        = "t3.micro"
  ami                  = "ami-09ed39e30153c3bf9"
  key_name             = "harsha-server"
  availability_zone    = "ap-south-1a"
  hibernation          = true

  root_block_device {
    encrypted   = true
    volume_size = 10
  }

  tags = {
    Name = "jenkins-aws-server"
  }

  ebs_block_device {
    device_name             = "/dev/sdb"
    volume_size             = 8
    encrypted               = true
    delete_on_termination   = true
  }

  provisioner "local-exec" {
    command = <<EOT
      sudo sleep 120
      sudo ssh-keygen -R ${self.public_ip}
       
      sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${self.public_ip}, playbook.yaml -u ec2-user --private-key /home/ec2-user/./keys/harsha-server.pem
    EOT
  }
}

output "aws_attributes" {
  value = aws_instance.my_server.public_ip
}
