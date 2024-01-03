// creating vpc1 public

resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name= "public-vpc"
  }
}

//creating vpc2-private

resource "aws_vpc" "vpc2" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "private-vpc"
  }
}


// creating public subnet for vpc 1

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name= "public_subnet"
  }
}

//creating private subnet for vpc 2

resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.vpc2.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name="private_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "IGW for vpc1"
  }
}

// creating route table
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

 
  tags = {
    Name = "RTB"
  }
}

//subnet association with route table

resource "aws_route_table_association" "RTB-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.rtb.id
}

//creating securtiy group
resource "aws_security_group" "my-vpc1-sg" {
  name        = "my-vpc1-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc1.cidr_block]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "my-vpc1-sg"
  }
}
