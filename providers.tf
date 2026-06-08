terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "2.1.0"
    }
  }
}

provider "openstack" {
  auth_url         = "api selectel"
  domain_name      = var.selectel_account_id
  tenant_id        = ""
  user_name        = var.selectel_username
  password         = var.selectel_password
  user_domain_name = var.selectel_account_id
  region           = "ru-6"
}