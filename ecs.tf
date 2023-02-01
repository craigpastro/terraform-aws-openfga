resource "aws_security_group" "ecs_task" {
  name   = "${local.name}-task-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    protocol        = "tcp"
    from_port       = local.port
    to_port         = local.port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_ecs_cluster" "this" {
  name = local.name
  tags = local.tags
}

resource "aws_ecs_task_definition" "run" {
  family                   = "run"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.task_cpu
  memory                   = local.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name        = local.name
      image       = "openfga/openfga:latest"
      command     = ["run"]
      networkMode = "awsvpc"
      essential   = true
      portMappings = [
        {
          containerPort = local.port
          hostPort      = local.port
        }
      ],
      environment = [
        {
          name  = "OPENFGA_PLAYGROUND_ENABLED"
          value = "false"
        },
        {
          name  = "OPENFGA_LOG_FORMAT"
          value = "json"
        },
        {
          name  = "OPENFGA_DATASTORE_ENGINE"
          value = local.db_type
        },
        {
          name  = "OPENFGA_DATASTORE_URI"
          value = local.db_conn_string
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.id
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs"
        }
      },
    }
  ])

  tags = local.tags
}

resource "aws_ecs_service" "run" {
  name                = "${local.name}-run"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.run.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = local.service_count

  network_configuration {
    subnets          = aws_subnet.public.*.id
    assign_public_ip = true # needed to pull from docker hub
    security_groups  = [aws_security_group.ecs_task.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = local.name
    container_port   = local.port
  }

  depends_on = [
    aws_lb_listener.this,
    aws_rds_cluster_instance.this,
    aws_iam_role.ecs_task_execution_role,
    aws_ecs_service.migrate,
  ]

  tags = local.tags
}

resource "aws_ecs_task_definition" "migrate" {
  count = local.migrate ? 1 : 0

  family                   = "migrate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.task_cpu
  memory                   = local.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name        = "${local.name}-migrate"
      image       = "openfga/openfga:latest"
      command     = ["migrate"]
      networkMode = "awsvpc"
      essential   = true
      environment = [
        {
          name  = "OPENFGA_DATASTORE_ENGINE"
          value = local.db_type
        },
        {
          name  = "OPENFGA_DATASTORE_URI"
          value = local.db_conn_string
        }
      ],
    }
  ])

  tags = local.tags
}

resource "aws_ecs_service" "migrate" {
  count = local.migrate ? 1 : 0

  name                = "${local.name}-migrate"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.migrate[0].arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = 1

  network_configuration {
    subnets          = aws_subnet.public.*.id
    assign_public_ip = true # needed to pull from docker hub
    security_groups  = [aws_security_group.ecs_task.id]
  }

  depends_on = [
    aws_lb_listener.this,
    aws_rds_cluster_instance.this,
    aws_iam_role.ecs_task_execution_role,
  ]

  tags = local.tags
}
