# Creating a VPC for a project

resource "aws_vpc" "my-Rock2" {
  cidr_block           = var.vpc-cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "my-Rock2"
  }
}

# Creating two public subnets for the aws_vpc

resource "aws_subnet" "prod-pub-sub1" {
  vpc_id            = aws_vpc.my-Rock2.id
  cidr_block        = var.public-cidr1
  availability_zone = var.availability-z-1
  tags = {
    Name = "prod-pub-sub1"
  }
}

resource "aws_subnet" "prod-pub-sub2" {
  vpc_id            = aws_vpc.my-Rock2.id
  cidr_block        = var.public-cidr2
  availability_zone = var.availability-z-2

  tags = {
    Name = "prod-pub-sub2"
  }
}


resource "aws_subnet" "prod-pub-sub3" {
  vpc_id            = aws_vpc.my-Rock2.id
  cidr_block        = var.public-cidr3
  availability_zone = var.availability-z-3
  tags = {
    Name = "prod-pub-sub3"
  }
}

# Creating two Private Subnets for the aws_vpc

resource "aws_subnet" "prod-priv-sub1" {
  vpc_id            = aws_vpc.my-Rock2.id
  cidr_block        = var.private-cidr1
  availability_zone = var.availability-z-1

  tags = {
    Name = "prod-priv-sub1"
  }
}

resource "aws_subnet" "prod-priv-sub2" {
  vpc_id            = aws_vpc.my-Rock2.id
  cidr_block        = var.private-cidr2
  availability_zone = var.availability-z-2

  tags = {
    Name = "prod-priv-sub2"
  }
}

# Creating two route tables,one public and the other private

resource "aws_route_table" "prod-pub-route-table" {
  vpc_id = aws_vpc.my-Rock2.id

  tags = {
    Name = "prod-pub-route-table"
  }
}

resource "aws_route_table" "prod-priv-route-table" {
  vpc_id = aws_vpc.my-Rock2.id

  tags = {
    Name = "prod-priv-route-table"
  }
}

# Associating subnets to the routes

resource "aws_route_table_association" "public-association1" {
  subnet_id      = aws_subnet.prod-pub-sub1.id
  route_table_id = aws_route_table.prod-pub-route-table.id
}

resource "aws_route_table_association" "public-association2" {
  subnet_id      = aws_subnet.prod-pub-sub2.id
  route_table_id = aws_route_table.prod-pub-route-table.id
}


resource "aws_route_table_association" "public-association3" {
  subnet_id      = aws_subnet.prod-pub-sub1.id
  route_table_id = aws_route_table.prod-pub-route-table.id
}

resource "aws_route_table_association" "private-association1" {
  subnet_id      = aws_subnet.prod-priv-sub1.id
  route_table_id = aws_route_table.prod-priv-route-table.id
}

resource "aws_route_table_association" "private-association2" {
  subnet_id      = aws_subnet.prod-priv-sub2.id
  route_table_id = aws_route_table.prod-priv-route-table.id
}

# Creating an internet gateway

resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.my-Rock2.id

  tags = {
    Name = "prod-igw"
  }
}

# Associating internet gateway with the public route

resource "aws_route" "my-Rock2" {
  route_table_id         = aws_route_table.prod-pub-route-table.id
  gateway_id             = aws_internet_gateway.prod-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# creating elastic ip gateway

resource "aws_eip" "prod-elastic-ip" {
  vpc      = true

tags = {
    Name = "prod-elastic-ip"
}
}

# creating nat gateway
resource "aws_nat_gateway" "prod-nat-gateway" {
  allocation_id = aws_eip.prod-elastic-ip.id
  subnet_id     = aws_subnet.prod-pub-sub1.id
 connectivity_type = "public"

  tags = {
    Name = "prod-nat-gateway"
  }
   depends_on = [aws_internet_gateway.prod-igw]
}

# creating association nat gateway with private subnet 

resource "aws_route" "elatic-ip-association" {
     route_table_id = aws_route_table.prod-priv-route-table.id
     gateway_id             = aws_internet_gateway.prod-igw.id   
     destination_cidr_block = "0.0.0.0/0"
}
