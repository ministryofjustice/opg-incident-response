resource "aws_secretsmanager_secret" "slack_token" {
  name = "response/${local.environment}/slack-token"
}

resource "aws_secretsmanager_secret" "slack_signing_key" {
  name = "response/${local.environment}/slack-signing-key"
}

resource "aws_secretsmanager_secret" "slack_team_id" {
  name = "response/${local.environment}/slack-team-id"
}

resource "aws_secretsmanager_secret" "database_password" {
  name = "response/${local.environment}/rds-password"
}

data "aws_secretsmanager_secret_version" "database_password" {
  secret_id = aws_secretsmanager_secret.database_password.id
}

resource "aws_secretsmanager_secret" "django_secret_key" {
  name = "response/${local.environment}/django-secret-key"
}

resource "aws_secretsmanager_secret" "github_client_id" {
  name = "response/${local.environment}/github-client-id"
}

resource "aws_secretsmanager_secret" "github_client_secret" {
  name = "response/${local.environment}/github-client-secret"
}

resource "aws_secretsmanager_secret" "statuspage_io_page_id" {
  name = "response/${local.environment}/statuspageio-page-id"
}

resource "aws_secretsmanager_secret" "statuspage_io_api_key" {
  name = "response/${local.environment}/statuspageio-api-key"
}

resource "aws_secretsmanager_secret" "pagerduty_api_key" {
  name = "response/${local.environment}/pagerduty-api-key"
}
