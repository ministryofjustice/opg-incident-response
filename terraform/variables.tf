locals {
  accounts = {
    development = 679638075911
    production  = 997462338508
  }

  dns_prefixes = {
    "development" = "dev.incident"
    "production"  = "incident"
  }

  mandatory_moj_tags = {
    business-unit    = "OPG"
    application      = "opg-incident-response"
    environment-name = terraform.workspace
    is-production    = tostring(terraform.workspace == "production" ? true : false)
    owner            = "OPG Webops: opgteam@digital.justice.gov.uk"
  }

  optional_tags = {
    infrastructure-support = "OPG Webops: opgteam@digital.justice.gov.uk"
    terraform-managed      = "Managed by Terraform"
  }

  tags = merge(local.mandatory_moj_tags, local.optional_tags)
}

variable "default_role" {
  default = "incident-response-ci"
  type    = string
}

variable "management_role" {
  default = "incident-response-ci"
  type    = string
}
