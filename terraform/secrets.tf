resource "aws_secretsmanager_secret" "slack_token" {
  name = "response/${terraform.workspace}/slack-token"
  tags = local.tags
}

resource "aws_secretsmanager_secret" "slack_signing_key" {
  name = "response/${terraform.workspace}/slack-signing-key"
  tags = local.tags
}

resource "aws_secretsmanager_secret" "database_password" {
  name = "response/${terraform.workspace}/rds-password"
  tags = local.tags
}

data "aws_secretsmanager_secret_version" "database_password" {
  secret_id = aws_secretsmanager_secret.database_password.id
}

resource "aws_secretsmanager_secret" "django_secret_key" {
  name = "response/${terraform.workspace}/django-secret-key"
  tags = local.tags
}

resource "aws_secretsmanager_secret" "github_client_id" {
  name = "response/${terraform.workspace}/github-client-id"
  tags = local.tags
}

resource "aws_secretsmanager_secret" "github_client_secret" {
  name = "response/${terraform.workspace}/github-client-secret"
  tags = local.tags
}

resource "aws_secretsmanager_secret" "statuspage_io_page_id" {
  name = "response/${terraform.workspace}/statuspageio-page-id"
  tags = local.tags
}

resource "aws_secretsmanager_secret" "statuspage_io_api_key" {
  name = "response/${terraform.workspace}/statuspageio-api-key"
  tags = local.tags
}
