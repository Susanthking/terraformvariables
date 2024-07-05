// modules/vpc/main.tf

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags       = var.tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = var.azs[0]
  tags              = var.tags
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = var.azs[1]
  tags              = var.tags
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.azs[0]
  tags              = var.tags
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.azs[1]
  tags              = var.tags
}

resource "aws_nat_gateway" "a" {
  allocation_id = aws_eip.a.id
  subnet_id     = aws_subnet.public_a.id
  tags          = var.tags
}

resource "aws_nat_gateway" "b" {
  allocation_id = aws_eip.b.id
  subnet_id     = aws_subnet.public_b.id
  tags          = var.tags
}

resource "aws_eip" "a" {
  vpc = true
}

resource "aws_eip" "b" {
  vpc = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = var.tags
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.a.id
  }
  tags = var.tags
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.b.id
  }
  tags = var.tags
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_instance" "public_a" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_a.id
  tags          = var.tags
}

resource "aws_instance" "public_b" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_b.id
  tags          = var.tags
}

resource "aws_instance" "private_a" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_a.id
  tags          = var.tags
}

resource "aws_instance" "private_b" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_b.id
  tags          = var.tags
}

resource "aws_db_instance" "this" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = "foobar123"
  password             = "foobar1234"
  db_subnet_group_name = aws_db_subnet_group.this.name
  multi_az             = true
  tags                 = var.tags
}

resource "aws_db_subnet_group" "this" {
  name       = "mydb-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags       = var.tags
}

