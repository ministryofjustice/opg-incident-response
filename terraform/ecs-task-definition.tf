
resource "aws_ecs_task_definition" "response" {
  family                   = "response"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  container_definitions    = "[${local.response}, ${local.nginx}]"
  task_role_arn            = aws_iam_role.response_primary.arn
  execution_role_arn       = aws_iam_role.execution_role.arn

  # volume {
  #   name      = "static_volume"
  #   host_path = "/app/opgincidentresponse/static/"
  # }
}


data "aws_ecr_repository" "response" {
  name     = "opg-incident-response"
  provider = aws.management
}
variable "nginx_tag" {
  default = "nginx-master-91fbac7"
}

variable "response_tag"{
  default = "master-91fbac7"
}

locals {

    nginx = jsonencode({
      cpu       = 0,
      essential = true,
      image     = "${data.aws_ecr_repository.response.repository_url}:${var.nginx_tag}",
      name      = "nginx",
      mountPoints = [
        # {
        #   containerPath = "/app/opgincidentresponse/static/",
        #   sourceVolume  = "static_volume"
        # }
      ],
      portMappings = [{
        containerPort = 80,
        hostPort      = 80,
        protocol      = "tcp"
      }],

      # healthCheck = {
      #   command     = ["CMD-SHELL", "curl -f http://localhost/nginx-health || exit 1"],
      #   startPeriod = 30,
      #   interval    = 15,
      #   timeout     = 10,
      #   retries     = 3
      # },
      # dependsOn = [{
      #   containerName = "response",
      #   condition     = "HEALTHY"
      # }],
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
          name  = "APP_NAME",
          value = "api"
        },
        {
          name  = "APP_PORT",
          value = "8000"
        },
        {
          name  = "NGINX_LOG_LEVEL",
          value = "info"
        }
      ]
    })

  response = jsonencode({
    cpu          = 0,
    essential    = true,
    image        = "${data.aws_ecr_repository.response.repository_url}:${var.response_tag}",
    mountPoints = [
      # {
      #   containerPath = "/app/opgincidentresponse/static/",
      #   sourceVolume  = "static_volume"
      # }
    ],
    name         = "response",
    portMappings = [{
      containerPort = 8000,
      hostPort      = 8000,
      protocol      = "tcp"
    }],
    # healthCheck = {
    #   command     = ["CMD-SHELL", "curl -f http://localhost/ht || exit 1"],
    #   startPeriod = 30,
    #   interval    = 15,
    #   timeout     = 10,
    #   retries     = 3
    # },
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
