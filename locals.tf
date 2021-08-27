locals {
    # Generic project prefix, to rename most components
    prefix                = "EB"    
    # Atlas organization where to provsion a new group
    organization_id       = "599ef70e9f78f769464e3729"
    # New empty Atlas project name to create in organization
    project_id            = "${local.prefix}-AWS-Linked-project"
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
    # AWS Availability_Zone
    aws_az                = "eu-west-1c"
    # AWS user_name
    admin_username        = "demouser1"

    # AWS security group
    aws_security_group    = "default"
    # The id of the above group
    vpc_security_group_id = "sg-dce6f4b8"
  

    # Instance type to use for testing
    aws_ec2_instance = "t3.medium"
    # Instance name
    aws_ec2_name = "${local.prefix}-vm"
}

terraform {
  required_version = ">= 0.13.05"
}
