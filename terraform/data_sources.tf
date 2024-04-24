data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "tag:Name"
    values = ["public"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "tag:Name"
    values = ["private"]
  }
}

data "aws_caller_identity" "current" {}

data "aws_kms_key" "rds" {
  key_id = "alias/aws/rds"
}

data "aws_db_subnet_group" "data_persitance_subnet_group" {
  name = "data-persitance-subnet-${terraform.workspace}"
}
