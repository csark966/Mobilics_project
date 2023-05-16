# Define provider and region
provider "aws" {
  region     = "ap-south-1"
  access_key = "***************************************"
  secret_key = "******************************************"
}


# Create a new VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate the route table with the VPC
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create a subnet
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1b"
}

# Create security group
resource "aws_security_group" "my_sg" {
  name        = "my-security-group"
  description = "Allow traffic on port 80"

  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instances
resource "aws_instance" "my_instance" {
  count                  = 2
  ami                    = "ami-02eb7a4783e7e9317"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name               =  "first_key"
  availability_zone      = "ap-south-1b"

  tags = {
    Name = "Instance ${count.index + 1}"
  }
}

# Create a load balancer
resource "aws_elb" "my_load_balancer" {
  name               = "my-load-balancer"
  subnets            = [aws_subnet.my_subnet.id]
  security_groups    = [aws_security_group.my_sg.id]
  instances          = aws_instance.my_instance.*.id
  cross_zone_load_balancing   = true
  idle_timeout       = 400
  connection_draining = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
}

# Output load balancer DNS name
output "load_balancer_dns" {
  value = aws_elb.my_load_balancer.dns_name
}
