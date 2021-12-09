terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "~>1.1.1"
    }
  }
  required_version = ">= 0.13"
}
