

provider "aws" {
  # Which Environement variable does the provider requires?
  # AWS_SECURITY_GROUPS
  region  = local.aws_region
}

resource "aws_vpc" "vpc" {
  cidr_block = local.aws_route_cidr_block
  # Required to resolve hostname to internal addresses
  enable_dns_support = true
  enable_dns_hostnames = true
  instance_tenancy = "default"

  tags = local.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = local.aws_subnet1_cidr_block
 
  tags = local.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.vpc.id

  tags = local.tags 
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_route_table" "main_route" {
  vpc_id = aws_vpc.vpc.id  
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.main_gw.id
    }

  tags = local.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_route_table_association" "main-subnet" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.main_route.id
}

resource "aws_security_group" "main" {
  vpc_id = aws_vpc.vpc.id
  egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"   
    // Put your office or home address in it!
    cidr_blocks = [ var.provisioning_address_cdr ]
  }

  ingress {
    from_port = 1024
    to_port = 1026
    protocol = "tcp"   
    // Enable inbound ports to Endpoint service
    cidr_blocks = [ local.aws_route_cidr_block ]
  }

  tags = local.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_vpc_endpoint" "ptfe_service" {
  vpc_id             = aws_security_group.main.vpc_id 
  service_name       = mongodbatlas_privatelink_endpoint.test.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.main.id]
  subnet_ids         = [aws_subnet.subnet1.id]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami               = data.aws_ami.ubuntu.id
  # availability_zone = local.aws_az
  instance_type     = local.aws_ec2_instance
  key_name          = var.key_name
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id         = aws_subnet.subnet1.id
  associate_public_ip_address = true

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type ="gp2"
  }

  provisioner "remote-exec" {
    inline = concat(local.python, local.mongodb)
  }

  connection {
    host        = aws_instance.web.public_ip
    user        = "ubuntu"
    password    = var.admin_password
    agent       = true
    private_key = file(var.private_key_path)
  }
  
  tags = merge(
    local.tags,
    {
      Name = local.aws_ec2_name
    })

  lifecycle {
    ignore_changes = [tags, ebs_block_device]
    create_before_destroy = true
  }
}

output "Virtual_Machine_Address" {
  description = "Virtual Machine Address"
  value = aws_instance.web.public_ip
}
