#################################################################
#          Terraform file depends on variables.tf               #
#################################################################

#################################################################
#          Terraform file depends on locals.tf                  #
#################################################################

# Some remaining variables are still hardcoded, such Atlas shape 
# details. There are only used once, and most likely they are 
# not required to change

#################################################################
##################### MONGODB ATLAS SECTION #####################
#################################################################

provider "mongodbatlas" {
  # variable are provided via ENV
  # public_key = ""
  # private_key  = ""
}

# Need a project
resource "mongodbatlas_project" "proj1" {
  name   = local.project_name
  org_id = var.organization_id
}

resource "mongodbatlas_privatelink_endpoint" "test" {
  project_id    = mongodbatlas_project.proj1.id
  provider_name = local.provider_name
  region        = local.region
}

# Private Link Endpoint service
resource "mongodbatlas_privatelink_endpoint_service" "test" {
  project_id            = mongodbatlas_privatelink_endpoint.test.project_id
  private_link_id       = mongodbatlas_privatelink_endpoint.test.private_link_id
  endpoint_service_id   = aws_vpc_endpoint.ptfe_service.id
  provider_name         = local.provider_name
}

resource "mongodbatlas_cluster" "this" {
 name                  = local.cluster_name
 project_id            = mongodbatlas_project.proj1.id

 replication_factor           = 3
 # not allowed for version 4.2 clusters and above
 # backup_enabled             = true
 # provider_backup_enabled    = true
 cloud_backup                 = true
 auto_scaling_disk_gb_enabled = true
 mongo_db_major_version       = "5.0"

 provider_name               = local.provider_name
 provider_instance_size_name = "M30"
 # this provider specific, why?
 provider_region_name        = local.region
}

output "atlasclusterstring" {
   value = mongodbatlas_cluster.this.connection_strings[0]
}

# DATABASE USER
resource "mongodbatlas_database_user" "user1" {
  username           = local.admin_username
  password           = var.admin_password
  project_id         = mongodbatlas_project.proj1.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
  labels {
    key   = "Name"
    value = local.admin_username
  }
  scopes {
    name = mongodbatlas_cluster.this.name
    type = "CLUSTER"
  }
}

output "user1" {
  value = mongodbatlas_database_user.user1.username
}
