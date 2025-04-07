

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-${var.environment}"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "gtw-${var.environment}"
  }
}

# Create Router Public
resource "aws_route_table" "router-public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "router-public-${var.environment}"
  }
}

#================== AZ Privado ===================
# Create SubNet Private 1a
resource "aws_subnet" "private-subnet-1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${var.regiao}a"
  tags = {
    Name = "private-subnet-1a"
  }
}

# Create SubNet Private 1b
resource "aws_subnet" "private-subnet-1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.regiao}b"
  tags = {
    Name = "private-subnet-1b"
  }
}

#============== AZ PUBLIC ==================

# Create Public Subnet 1a
resource "aws_subnet" "public-subnet-1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.regiao}a"
  tags = {
    Name = "public-subnet-1a"
  }
}

resource "aws_route_table_association" "associate_route_table_public_a" {
  subnet_id      = aws_subnet.public-subnet-1a.id
  route_table_id = aws_route_table.router-public.id
}

# Create Public Subnet 1b
resource "aws_subnet" "public-subnet-1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.regiao}b"
  tags = {
    Name = "public-subnet-1b"
  }
}

resource "aws_route_table_association" "associate_route_table_public_b" {
  subnet_id      = aws_subnet.public-subnet-1b.id
  route_table_id = aws_route_table.router-public.id
}

# =============== CREATE SECURITY GROUP ===============================
# Create Security Group SSH
resource "aws_security_group" "allow_web" {
  name        = "allow-web-${var.environment}"
  description = "Allow WEB inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "sg_allow_web_${var.environment}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

