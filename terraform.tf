resource "aws_vpc" "myvpc" {
  cidr_block       = "11.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "myvpc"
  }
}
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "11.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public_subnet"
  }
}
resource "aws_internet_gateway" "mygateway" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "mygateway"
  }
}
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygateway.id
  }
  tags = {
    Name = "public-route-table"
  }
}
resource "aws_route_table_association" "rt1" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public-route-table.id
}
resource "aws_security_group" "mysg" {
  vpc_id = aws_vpc.myvpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
  tags = {
    Name = "mysg"
  }
}
resource "aws_instance" "myinstance" {
  ami                    = "ami-0cf10cdf9fcd62d37"
  instance_type          = "t2.micro"
  key_name               = "slave-3"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.mysg.id]
  user_data              = file("bash.sh")
  tags = {
    Name = "myinstance"
  }
}
