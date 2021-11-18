variable "aws_account_id" {
  description = "Aws_account_id ..."
  type = string
}

variable "organization_id" {
  description = "Atlas organization"
  type = string
} 
variable "admin_password" {
  description = "Password for default users"
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

variable "provisioning_address_cdr" {
  description = "SSH firewall source address, home/office !?"
  type = string
}

variable "user_email" {
  description = "Email address to add as tag"
  type = string
  default = "somebody@example.com"
}