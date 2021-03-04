

provider "aws" {
  # Which Environement variable does the provider requires?
  # AWS_SECURITY_GROUPS
  region  = local.aws_region
}

data "aws_security_group" "default" {
  id = local.vpc_security_group_id
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_security_group.default.vpc_id
}

data "aws_subnet" "default" {
  for_each = data.aws_subnet_ids.default.ids
  id       = each.value
}

resource "aws_vpc_endpoint" "ptfe_service" {
  vpc_id             = data.aws_security_group.default.vpc_id 
  service_name       = mongodbatlas_privatelink_endpoint.test.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  security_group_ids = [data.aws_security_group.default.id]
  subnet_ids         = data.aws_subnet.default.id
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

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami               = data.aws_ami.ubuntu.id
  availability_zone = local.aws_az
  instance_type     = local.aws_ec2_instance
  key_name          = var.key_name
  vpc_security_group_ids = [data.aws_security_group.default.id]
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
	    "sleep 10",
	    "sudo apt-get -y update",
	    "sudo apt-get -y install python3-pip",
      "sudo apt-get -y update",
	    "sudo apt-get -y install python3-pip",
	    "sudo pip3 install pymongo==3.9.0",
	    "sudo pip3 install faker",
	    "sudo pip3 install dnspython",

      "wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -",
      "echo 'deb [ arch=amd64 ] http://repo.mongodb.com/apt/ubuntu bionic/mongodb-enterprise/4.4 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-enterprise.list",
      "sudo apt-get update",
	    "sudo apt-get install -y mongodb-enterprise-shell",

      "sudo rm -f /etc/resolv.conf ; sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf"
	  ]
  }
  
  connection {
    host        = aws_instance.web.public_ip
    user        = "ubuntu"
    password    = var.admin_password
    agent       = true
    private_key = file(var.private_key_path)
  }
}

output "Virtual_Machine_Address" {
  description = "Virtual Machine Address"
  value = aws_instance.web.public_ip
}
