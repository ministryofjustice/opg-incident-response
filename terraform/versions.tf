terraform {
  backend "s3" {
    bucket         = "opg.terraform.state"
    key            = "opg-incident-response/terraform.tfstate"
    encrypt        = true
    region         = "eu-west-1"
    role_arn       = "arn:aws:iam::311462405659:role/incident-response-ci"
    dynamodb_table = "remote_lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.42.0"
    }
  }
  required_version = ">= 1.8.1"
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn     = "arn:aws:iam::${lookup(local.accounts, terraform.workspace, local.accounts["development"])}:role/${var.default_role}"
    session_name = "terraform-session"
  }

  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias  = "management"
  region = "eu-west-1"

  assume_role {
    role_arn     = "arn:aws:iam::311462405659:role/${var.management_role}"
    session_name = "terraform-session"
  }

  default_tags {
    tags = local.tags
  }
}
