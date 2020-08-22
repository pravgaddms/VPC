# ----------------------------
# CONFIGURE OUR AWS CONNECTION
# ----------------------------

provider "aws" {
  region = var.region
}

#--------------
# Create a VPC
#--------------

resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "TEST VPC"
  }
}

#-----------------------------------------
# Create a public subnet on AZ us east -1a
#-----------------------------------------
resource "aws_subnet" "public_us_east_1a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet1_cidr
  availability_zone = var.subnet1_az

  tags = {
    Name = "Public Subnet us-east-1a"
  }
}

#-------------------------------
# Create an IGW for your new VPC
#-------------------------------
resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "TEST VPC-IGW"
  }
}

#----------------------------------
# Create an RouteTable for your VPC
#----------------------------------
resource "aws_route_table" "my_vpc_public" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }

    tags = {
        Name = "Public Subnets Route Table for TEST VPC"
    }
}

#--------------------------------------------------------------
# Associate the RouteTable to the Subnet created at ap-south-1a
#--------------------------------------------------------------
resource "aws_route_table_association" "my_vpc_ap_south_1a_public" {
    subnet_id = aws_subnet.public_us_east_1a.id
    route_table_id = aws_route_table.my_vpc_public.id
}
#--------------------------------------
# Create an Security Group for your VPC
#--------------------------------------
resource "aws_security_group" "my_sgp" {
  name = "my_sgp"
  vpc_id = aws_vpc.my_vpc.id

  # SSH access from the VPC
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

  tags = {
     Name = "SG for TEST VPC"
  }
}
#----------------------------------
# Create an EC2 inside subnet with an SG
#----------------------------------
resource "aws_instance" "testInstance" {
  ami           = "var.image"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_us_east_1a.id 
  vpc_security_group_ids = [aws_security_group.my_sgp.id]
  key_name = "mycrdkey4"

connection {
  type = "ssh"
  user = "ubuntu"
  private_key = file("mycrdkey4.pem")
  host = self.public_ip
}
# Install Ansible & Call Ansible
provisioner "remote-exec" {
inline = [
  "sudo apt -y update",
  "sudo apt install -y ansible",
  "sudo ansible --version"
]
}
  tags = {
     Name = "EC2 in Test VPC"  
	}
}
