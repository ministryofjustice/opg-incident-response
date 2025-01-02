resource "aws_rds_cluster" "cluster" {
  apply_immediately               = false
  availability_zones              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  backup_retention_period         = 14
  cluster_identifier              = "incident-response-${local.environment}"
  database_name                   = "response"
  db_subnet_group_name            = data.aws_db_subnet_group.data_persitance_subnet_group.name
  deletion_protection             = true
  engine                          = "aurora-postgresql"
  engine_mode                     = "provisioned"
  engine_version                  = "13.16"
  enabled_cloudwatch_logs_exports = ["postgresql"]
  final_snapshot_identifier       = "response-${local.environment}-final-snapshot"
  kms_key_id                      = data.aws_kms_key.rds.arn
  master_username                 = "response"
  master_password                 = data.aws_secretsmanager_secret_version.database_password.secret_string
  preferred_backup_window         = "05:15-05:45"
  preferred_maintenance_window    = "mon:05:50-mon:06:20"
  skip_final_snapshot             = false
  storage_encrypted               = true
  vpc_security_group_ids          = [aws_security_group.response_rds.id]

  serverlessv2_scaling_configuration {
    min_capacity = 0
    max_capacity = 4
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      engine_version
    ]
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                           = local.environment == "development" ? 1 : 2
  apply_immediately               = false
  auto_minor_version_upgrade      = false
  ca_cert_identifier              = "rds-ca-rsa2048-g1"
  cluster_identifier              = aws_rds_cluster.cluster.id
  db_subnet_group_name            = data.aws_db_subnet_group.data_persitance_subnet_group.name
  depends_on                      = [aws_rds_cluster.cluster]
  engine                          = aws_rds_cluster.cluster.engine
  engine_version                  = aws_rds_cluster.cluster.engine_version
  identifier                      = "${aws_rds_cluster.cluster.id}-${count.index}"
  instance_class                  = "db.serverless"
  monitoring_interval             = 30
  monitoring_role_arn             = "arn:aws:iam::${lookup(local.accounts, local.environment, local.accounts["production"])}:role/rds-monitoring-role-${local.environment}"
  performance_insights_enabled    = true
  performance_insights_kms_key_id = data.aws_kms_key.rds.arn
  publicly_accessible             = false

  timeouts {
    create = "180m"
    update = "90m"
    delete = "90m"
  }

  lifecycle {
    ignore_changes = [
      engine_version
    ]
  }
}

resource "aws_security_group" "response_rds" {
  name        = "response-rds-${local.environment}"
  description = "response rds access"
  vpc_id      = data.aws_vpc.default.id
  tags        = { "Name" = "response-api-${local.environment}" }
}

resource "aws_security_group_rule" "response_rds_ecs_task" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.response_rds.id
  source_security_group_id = aws_security_group.ecs_service.id
  description              = "Response RDS inbound from Response ECS tasks"
}
