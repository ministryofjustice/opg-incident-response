locals {
  config = {
    development = {
      django_settings       = "opgincidentresponse.settings.aws-dev"
      incident_bot_id       = "A070M293JRY"
      incident_bot_name     = "opg-incident-response-development"
      incident_channel_name = "incident-response"
    }
    production = {
      django_settings       = "opgincidentresponse.settings.prod"
      incident_bot_id       = "A01CXL45ZE1"
      incident_bot_name     = "opgincidentresponse"
      incident_channel_name = "opg-incident"
    }
  }
}
resource "aws_ecs_task_definition" "response" {
  family                   = "response"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  container_definitions    = "[${local.response}, ${local.nginx}]"
  task_role_arn            = aws_iam_role.response_primary.arn
  execution_role_arn       = aws_iam_role.execution_role.arn
}


data "aws_ecr_repository" "response" {
  name     = "opg-incident-response"
  provider = aws.management
}

data "aws_ecr_repository" "nginx" {
  name     = "incident-response/nginx"
  provider = aws.management
}

variable "nginx_tag" {
  default = "v1.117.0"
  type    = string
}

variable "response_tag" {
  default = "v1.117.0"
  type    = string
}

locals {

  nginx = jsonencode({
    cpu         = 0,
    essential   = true,
    image       = "${data.aws_ecr_repository.nginx.repository_url}:${var.nginx_tag}",
    name        = "nginx",
    mountPoints = [],
    portMappings = [{
      containerPort = 80,
      hostPort      = 80,
      protocol      = "tcp"
    }],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.response.name,
        awslogs-region        = "eu-west-1",
        awslogs-stream-prefix = "nginx"
      }
    },
    environment = [
      {
        name  = "APP_HOST",
        value = "localhost"
      },
      {
        name  = "APP_PORT",
        value = "8000"
      }
    ]
  })

  response = jsonencode({
    cpu         = 0,
    essential   = true,
    image       = "${data.aws_ecr_repository.response.repository_url}:${var.response_tag}",
    mountPoints = [],
    name        = "response",
    portMappings = [{
      containerPort = 8000,
      hostPort      = 8000,
      protocol      = "tcp"
    }],
    environment = [{
      name  = "DJANGO_SETTINGS_MODULE",
      value = local.config[terraform.workspace]["django_settings"]
      },
      {
        name  = "INCIDENT_BOT_NAME",
        value = local.config[terraform.workspace]["incident_bot_name"]
      },
      {
        name  = "INCIDENT_BOT_ID",
        value = local.config[terraform.workspace]["incident_bot_id"]
      },
      {
        name  = "INCIDENT_CHANNEL_NAME",
        value = local.config[terraform.workspace]["incident_channel_name"]
      },
      {
        name  = "INCIDENT_REPORT_CHANNEL_NAME",
        value = local.config[terraform.workspace]["incident_channel_name"]
      },
      {
        name  = "DB_HOST",
        value = aws_rds_cluster.db.endpoint
      },
      {
        name  = "DB_NAME",
        value = "response"
      },
      {
        name  = "DB_USER",
        value = "response"
      },
      {
        name  = "DB_SSL_MODE",
        value = "disable"
      },
      {
        name  = "SITE_URL",
        value = "https://${local.dns_prefix}.${data.aws_route53_zone.opg_service_justice_gov_uk.name}"
      },
      {
        name  = "PAGERDUTY_SERVICE",
        value = "PWKF9XO"
      },
      {
        name  = "PAGERDUTY_EMAIL",
        value = "thomas.withers@digital.justice.gov.uk"
      }
    ],
    secrets = [{
      name      = "SLACK_TOKEN",
      valueFrom = aws_secretsmanager_secret.slack_token.arn
      },
      {
        name      = "SLACK_SIGNING_SECRET",
        valueFrom = aws_secretsmanager_secret.slack_signing_key.arn
      },
      {
        name      = "SLACK_TEAM_ID",
        valueFrom = aws_secretsmanager_secret.slack_team_id.arn
      },
      {
        name      = "DB_PASSWORD",
        valueFrom = aws_secretsmanager_secret.database_password.arn
      },
      {
        name      = "SECRET_KEY"
        valueFrom = aws_secretsmanager_secret.django_secret_key.arn
      },
      {
        name      = "SOCIAL_AUTH_GITHUB_KEY",
        valueFrom = aws_secretsmanager_secret.github_client_id.arn
      },
      {
        name      = "SOCIAL_AUTH_GITHUB_SECRET"
        valueFrom = aws_secretsmanager_secret.github_client_secret.arn
      },
      {
        name      = "STATUSPAGEIO_PAGE_ID"
        valueFrom = aws_secretsmanager_secret.statuspage_io_page_id.arn
      },
      {
        name      = "STATUSPAGEIO_API_KEY"
        valueFrom = aws_secretsmanager_secret.statuspage_io_api_key.arn
      },
      {
        name      = "PAGERDUTY_API_KEY"
        valueFrom = aws_secretsmanager_secret.pagerduty_api_key.arn
      },
    ]
    volumesFrom = [],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.response.name,
        awslogs-region        = "eu-west-1",
        awslogs-stream-prefix = "response"
      }
    },
  })
}
