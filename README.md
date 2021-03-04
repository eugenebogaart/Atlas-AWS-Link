# MongoDB Atlas project Private Endpoint in AWS

## Background
Based on an small Proof of Concept to make Atlas available via Private Endpoint in AWS in the same region, this script automates all steps. 
The documentation on how to do this manually: https://docs.atlas.mongodb.com/security-private-endpoint 

The end result of the Terraform script is a project in Atlas + a Cluster + provisioned user, Private Endpoint in AWS with a 1 vm with public interface (ssh/key).
The vm has already MongoDB client tools installed.

## Prerequisites:
* Have your AWS cli configured t bue used by Terrafrom
* Have Terraform 0.13+ installed
* Run: terraform init 

```
Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Finding mongodb/mongodbatlas versions matching "~> 0.8.2"...
- Installing hashicorp/aws v3.30.0...
- Installed hashicorp/aws v3.30.0 (signed by HashiCorp)
- Installing mongodb/mongodbatlas v0.8.2...
- Installed mongodb/mongodbatlas v0.8.2 (signed by a HashiCorp partner, key ID 2A32ED1F3AD25ABF)
```

## Config:
* Set up credential, as in section: "Configure Script - Credentials"
* Change basic parameters, as in file : locals.tf
* Run: terraform apply

## Todo:
* Test with terrafrom 14. 

## Basic Terraform resources in script
* mongodbatlas_project,  creates an empty project in your Atlas account
* mongodbatlas_privatelink_endpoint, create privatelink endpoint
* mongodbatlas_privatelink_endpoint_service, create private link service in Atlas
* aws_vpc_endpoint, create Private Endpoint in AWS

## In order to provision a Atlas cluster and an AWS:
* mongodbatlas_cluster, Create cluster 
* mongodbatlas_database_user, Provision a user to the database

 
## Configure Script - Credentials: "variables.tf"

To configure the providers, such as Atlas and Azure, one needs credentials to gain access.
In case of MongoDB Atlas a public and private key pair is required. 
How to create an API key pair for an existing Atlas organization can be found here:
https://docs.atlas.mongodb.com/configure-api-access/#programmatic-api-keys
These keys are read in environment variables for safety. Alternatively these parameters
can be provide on the command line of the terraform invocation. The MONGODBATLAS provider will read
the 2 distinct variable, as below:

* MONGODB_ATLAS_PUBLIC_KEY=<PUBLICKEY>
* MONGODB_ATLAS_PRIVATE_KEY=<PRIVATEKEY>

Second a AWS subscription is required.  This is set p via the AWS CLI.
Please check your ~/.aws/config to see if configured

In other for Atlas to initiated the Link, access to AWS the subscription
Id should be know

* TF_VAR_aws_account_id=<AWS_ACCOUNT>

To create a VM with SSH Keys enable, the name of the AWS Key name should be provided
and the path to the private key on your installation host
* TF_VAR_key_name=<AWS_KEYPAIR_NAME>
* TF_VAR_private_key_path=<SSH_PRIVATE_KEY_PATH>

Third there are several other parameters that are trusted, which should be provided via environment variables. See below list of environment variables that are expected.

```
variable "admin_password" {
  description = "Password for default users"
  type = string
}

variable "aws_account_id" {
  description = "Aws_account_id ..."
  type = string
}

variable "key_name" {
  description = "Key pair name"
  type = string
}

variable "private_key_path" {
  description = "Access path to private key"
  type = string
}
```

## Other configuration: "locals.tf"

In the locals resource of the locals.tf file, several parameters should be adapted to your needs
```
locals {
    # Generic project prefix, to rename most components
    prefix                = "EB"    
    # Atlas organization where to provsion a new group
    organization_id       = "599ef70e9f78f769464e3729"
    # New empty Atlas project name to create in organization
    project_id            = "${local.prefix}-AWS-Linked-project"
    # Atlas region, https://docs.atlas.mongodb.com/reference/amazon-aws/std-label-amazon-aws
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
    aws_ec2_instance      = "t3.medium"
}

terraform {
  required_version = ">= 0.13.05"
}
```

## Give a go

In you favorite shell, run terraform apply and review the execution plan on what will be added, changed and detroyed. Acknowledge by typing: yes 

```
%>  terraform apply
```

Your final result should look like:
```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

Virtual_Machine_Address = 63.33.48.154
atlasclusterstring = mongodb+srv://sample-pl-0.HHHHHH.mongodb.net
user1 = demouser1
```

## Now login, if you have your ssh keys properly configured:
```
>$ ssh ubuntu@63.33.48.154
...
Last login: Mon Feb  8 09:47:34 2021 from **************************
testuser@demo-link:~$ mongo mongodb+srv://sample-pl-0.HHHHHH.mongodb.net --username testuser
MongoDB shell version v4.4.3
Enter password: 
connecting to: mongodb://pl-0-westeurope-azure.HHHHHH.mongodb.net:1026,pl-0-westeurope-azure.HHHHHH.mongodb.net:1025,pl-0-westeurope-azure.HHHHHH.mongodb.net:1024/?authSource=admin&compressors=disabled&gssapiServiceName=mongodb&replicaSet=atlas-zmjsri-shard-0&ssl=true
Implicit session: session { "id" : UUID("8ee43f82-3da4-41c7-a36a-3baf93ca7464") }
MongoDB server version: 4.2.12
WARNING: shell and server versions do not match
MongoDB Enterprise atlas-zmjsri-shard-0:PRIMARY> 
```
 
## Known Bugs
* let me know
