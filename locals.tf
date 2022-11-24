locals {
    # Generic project prefix, to rename most components
    prefix                = "EB"    
    # New empty Atlas project name to create in organization
    project_name           = "${local.prefix}-AWS-Linked-project"
    # Atlas region,https://docs.atlas.mongodb.com/reference/amazon-aws/#std-label-amazon-aws
    region                = "EU_WEST_1"
    # Atlas cluster name
    cluster_name		      = "${local.prefix}-Cluster"    
    # Atlas Pulic providor
    provider_name         = "AWS"
    # Atlas size name 
    atlas_size_name       = "M10"
    # Atlas cluster 
    disk_size_gb          = 40

    # AWS Region
    aws_region            = "eu-west-1"

    aws_route_cidr_block  = "10.11.6.0/23"
    # AWS Subnet block (first 256)
    aws_subnet1_cidr_block = "10.11.6.0/24"
    # AWS Subnet block (second 256)
    aws_subnet2_cidr_block = "10.11.7.0/24"

    # AWS user_name
    admin_username        = "demouser1"
  
    # Instance type to use for testing
    #aws_ec2_instance = "t3.medium"
    aws_ec2_instance = "m4.xlarge"

    # Instance name
    aws_ec2_name = "${local.prefix}-vm"

    python = [
      "sleep 10",
      "sudo apt-get -y update",
	    "sudo apt-get -y install python3-pip",
	    "sudo pip3 install pymongo==4.0.1",
      "sudo pip3 install faker",
	    "sudo pip3 install dnspython"
    ]
    mongodb = [
      "wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -",
      "echo 'deb [ arch=amd64 ] http://repo.mongodb.com/apt/ubuntu bionic/mongodb-enterprise/6.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-enterprise.list",
      "sudo apt-get update",
	    "sudo apt-get install -y mongodb-enterprise-shell mongodb-mongosh",
    ]
    tags = { 
      Name = "${local.prefix}-tf-provisioned"
      owner = var.user_email
      expire-on = timeadd(timestamp(), "760h")
      purpose = "training"
    }
}

terraform {
  required_version = ">= 0.13.05"
}
