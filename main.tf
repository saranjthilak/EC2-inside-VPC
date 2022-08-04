provider "aws" {
  region = "us-east-1"
   profile = "default"

}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
   tags = {
    Name = "my VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.my-vpc.id 
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "MYIGW"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id 
    }
  route{
      ipv6_cidr_block        = "::/0"
      gateway_id = aws_internet_gateway.igw.id
    }
  

  tags = {
    Name = "public-rt"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id 
  route_table_id = aws_route_table.public-rt.id
}
resource "aws_security_group" "allow_web" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id
  ingress {
      description      = "HTTPS from VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["0.0.0.0/0"]
    }
  

  ingress {
      description      = "HTTP from VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["0.0.0.0/0"]
    }
  

  ingress {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["0.0.0.0/0"]
    }


  egress  {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  

  tags = {
    Name = "allow_web"
  }
}

resource "aws_network_interface" "nic" {
  subnet_id       = aws_subnet.public.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.igw]
    }

resource "aws_instance" "ubuntu-server" {
  ami           = "ami-02e136e904f3da870"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "newkey"
  

  network_interface {
      device_index=0
      network_interface_id = aws_network_interface.nic.id
      
  }

   user_data =<<-EOF
            #!/bin/bash
            # Install Apache Web Server and PHP
            yum install -y httpd mysql php
            # Download Lab files
            wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-100-ACCLFO-2/2-lab2-vpc/s3/lab-app.zip
            unzip lab-app.zip -d /var/www/html/
            # Turn on web server
            systemctl enable httpd.service
            systemctl start httpd.service
            EOF
            

  tags = {
    Name = "Ubuntu server"
  }
}

