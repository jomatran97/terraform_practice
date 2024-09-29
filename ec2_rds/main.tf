provider "aws" {
  secret_key = var.secret_key
  access_key = var.access_key
  region     = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "subnet1" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "us-east-1a"
}

data "aws_subnet" "subnet2" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "us-east-1b"
}

# Creating a security group
resource "aws_security_group" "general" {
  name = "general"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "web-server" {
  ami             = "ami-02e136e904f3da870"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.general.name}"]
  user_data       = <<-EOF
    #!/bin/bash
    sudo su
    yum update -y
    yum install mysql -y
    EOF
  tags = {
    Name = "whiz_instance"
  }
}
#Creating RDS Database Instance
resource "aws_db_instance" "myinstance" {
  engine                 = "mysql"
  identifier             = "mydatabaseinstance"
  allocated_storage      = 20
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = "whizuser"
  password               = "whizpassword"
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = ["${aws_security_group.general.id}"]
  skip_final_snapshot    = true
  publicly_accessible    = true
}
