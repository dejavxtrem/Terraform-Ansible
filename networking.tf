#Data source availability zones
data "aws_availability_zones" "available" {}

#use locals for using data in other blocks 
locals {
  azs = data.aws_availability_zones.available.names
}



# Random Id resource generator
resource "random_id" "random" {
  byte_length = 2
}



resource "aws_vpc" "vpc_terraform_ansible" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "dev_training-${random_id.random.dec}"
  }


  #allows for new vpc to be created before the old one is destroyed 
  lifecycle {
    create_before_destroy = true
  }
}



#public subnet cos internet gateway attached"
resource "aws_internet_gateway" "vpc_terraform_ansible_internetgateway" {
  vpc_id = aws_vpc.vpc_terraform_ansible.id

  tags = {
    Name = "vpc_terraform_ansible_internetgateway-${random_id.random.dec}"
  }
}

###create the route table first
resource "aws_route_table" "public_terraformansible_routetable" {
  vpc_id = aws_vpc.vpc_terraform_ansible.id

  tags = {
    Name = "dev_public_routetable"
  }
}


#create the route resource
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_terraformansible_routetable.id
  destination_cidr_block = "0.0.0.0/0" # destination block will be the internet
  gateway_id             = aws_internet_gateway.vpc_terraform_ansible_internetgateway.id
  depends_on             = [aws_route_table.public_terraformansible_routetable]
}


# Default route table for the vpc we are creating(all private subnet fallback and associate with default route table)
resource "aws_default_route_table" "terraformansible_private_rt" {
  default_route_table_id = aws_vpc.vpc_terraform_ansible.default_route_table_id

  tags = {
    Name = "dev_private_routetable"
  }
}


#define public subnet 
resource "aws_subnet" "terraformansible_pub_subnet" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.vpc_terraform_ansible.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = local.azs[count.index]


  tags = {
    Name = "dev_public_subnet-${count.index + 1}"
  }
}



#define private subnet 
resource "aws_subnet" "terraformansible_private_subnet" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.vpc_terraform_ansible.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, length(local.azs) + count.index)
  map_public_ip_on_launch = false
  availability_zone       = local.azs[count.index]


  tags = {
    Name = "dev_private_subnet-${count.index + 1}"
  }
}

#route table association with public subnet
resource "aws_route_table_association" "terraformansible_public_assoc" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.terraformansible_pub_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_terraformansible_routetable.id
}


#create security group  for public ec2 instance
resource "aws_security_group" "terraforansible_securitygroup" {
  name        = "public_sg"
  description = "security group for public instance"
  vpc_id      = aws_vpc.vpc_terraform_ansible.id

}

#security group rule for public  ingress instance
resource "aws_security_group_rule" "ingress_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1" # means accept any protocol
  cidr_blocks       = var.access_ip
  security_group_id = aws_security_group.terraforansible_securitygroup.id

}

#security group rule for public  egress instance
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1" # means accept any protocol
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraforansible_securitygroup.id

}

