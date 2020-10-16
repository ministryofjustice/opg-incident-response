
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
variable "nginx_tag" {
  default = "nginx-master-fd08ce6"
}

variable "response_tag"{
  default = "master-fd08ce6"
}

locals {

    nginx = jsonencode({
      cpu       = 0,
      essential = true,
      image     = "${data.aws_ecr_repository.response.repository_url}:${var.nginx_tag}",
      name      = "nginx",
      mountPoints = [],
      portMappings = [{
        containerPort = 80,
        hostPort      = 80,
        protocol      = "tcp"
      }],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group        = aws_cloudwatch_log_group.response.name,
          awslogs-region       = "eu-west-1",
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
    cpu          = 0,
    essential    = true,
    image        = "${data.aws_ecr_repository.response.repository_url}:${var.response_tag}",
    mountPoints = [],
    name         = "response",
    portMappings = [{
      containerPort = 8000,
      hostPort      = 8000,
      protocol      = "tcp"
    }],
    environment = [{
        name  = "DJANGO_SETTINGS_MODULE",
        value = "opgincidentresponse.settings.prod"
      },
      {
        name  = "INCIDENT_BOT_NAME",
        value = "opg_response"
      },
      {
        name  = "INCIDENT_CHANNEL_NAME",
        value = "incidents"
      },
      {
        name  = "INCIDENT_REPORT_CHANNEL_NAME",
        value = "incident-reports"
      },
      {
        name  = "POSTGRES",
        value = "True"
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
        value = "${local.dns_prefix}.${data.aws_route53_zone.opg_service_justice_gov_uk.name}"
      }
    ],
    secrets     = [{
        name      = "SLACK_TOKEN",
        valueFrom = aws_secretsmanager_secret.slack_token.arn
      },
      {
        name      = "SLACK_SIGNING_SECRET",
        valueFrom = aws_secretsmanager_secret.slack_signing_key.arn
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
