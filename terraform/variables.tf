locals {
  accounts = {
    development = 679638075911
    production  = 997462338508
  }

  config = {
    development = {
      dns_prefix            = "dev.incident"
      incident_bot_id       = "A070M293JRY"
      incident_bot_name     = "opg-incident-response-development"
      incident_channel_name = "incident-response"
    }
    production = {
      dns_prefix            = "incident"
      incident_bot_id       = "A01CXL45ZE1"
      incident_bot_name     = "opgincidentresponse"
      incident_channel_name = "opg-incident"
    }
  }

  environment = terraform.workspace == "production" ? "production" : "development"

  mandatory_moj_tags = {
    business-unit    = "OPG"
    application      = "opg-incident-response"
    environment-name = local.environment
    is-production    = tostring(local.environment == "production" ? true : false)
    owner            = "OPG Webops: opgteam@digital.justice.gov.uk"
  }

  optional_tags = {
    infrastructure-support = "OPG Webops: opgteam@digital.justice.gov.uk"
    terraform-managed      = "Managed by Terraform"
  }

  tags = merge(local.mandatory_moj_tags, local.optional_tags)
}

variable "app_tag" {
  default = "v1.147.0"
  type    = string
}

variable "default_role" {
  default = "incident-response-ci"
  type    = string
}

variable "management_role" {
  default = "incident-response-ci"
  type    = string
}
