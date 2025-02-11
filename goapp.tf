resource "aws_lb" "backend" {
  load_balancer_type         = "application"
  internal                   = true
  idle_timeout               = 60
  enable_deletion_protection = false
  security_groups            = [module.private_alb_sg.security_group_id]
  subnets                    = [aws_subnet.private_ap_1a.id, aws_subnet.private_ap_1c.id]

  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }

  tags = {
    Name = "demo-backend-alb"
  }
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = 8080
  protocol          = "HTTP"

  # 後述リスナールールのいずれも一致しない場合の動作設定
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = <<JSON
      {
        "err_msg": "No setting"
      }
      JSON
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "backend" {
  name                 = "demo-backend-alb-tg"
  target_type          = "ip" # Fargateでは"ip"固定
  vpc_id               = aws_vpc.demo.id
  port                 = 8080
  protocol             = "HTTP"
  deregistration_delay = 300 # ターゲットの登録解除前にALBが待機する時間(s)。デフォルトは300

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.backend]
}

resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.backend.arn
  priority     = 100

  # 本リスナールールに合致するものは、ターゲットグループへフォワードする
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    # すべてのパスをフォーワード
    path_pattern {
      values = ["/*"]
    }
  }
}

#
# ECS
# 
resource "aws_ecs_cluster" "backend" {
  name = "demo-backend"

  tags = {
    Name = "demo-backend"
  }
}
resource "aws_ecs_task_definition" "backend" {
  family                   = "demo-backend"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = <<JSON
  [
    {
      "name": "demo-backend",
      "image": "521825925159.dkr.ecr.ap-northeast-1.amazonaws.com/demo-backend:v1",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "nginx",
          "awslogs-group": "/demo/backend"
        }
      },
      "portMappings": [
        {
          "protocol": "tcp",
          "containerPort": 8080
        }
      ],
      "environment": [
        {
          "name": "DB_HOST",
          "value": "${aws_db_instance.mysql_8.address}"
        },
        {
          "name": "DB_PORT",
          "value": "3306"
        }
      ],
      "secrets": [
        {
          "name": "DB_USER",
          "valueFrom": "/demo/db_username"
        },
        {
          "name": "DB_PASSWORD",
          "valueFrom": "/demo/db_password"
        }
      ]
    }
  ]
  JSON
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}
resource "aws_ecs_service" "backend" {
  name                              = "demo-backend-service"
  cluster                           = aws_ecs_cluster.backend.arn
  task_definition                   = aws_ecs_task_definition.backend.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups  = [module.private_backend_ap.security_group_id]

    subnets = [
      aws_subnet.private_ap_1a.id,
      aws_subnet.private_ap_1c.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "demo-backend"
    container_port   = 8080
  }

  lifecycle {
    # ignore_changes = [task_definition]
  }
}

#
# RDS
#
resource "aws_db_parameter_group" "mysql_8" {
  name   = "demo"
  family = "mysql8.0"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

resource "aws_db_option_group" "mysql_8" {
  name                 = "demo"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}

resource "aws_db_subnet_group" "mysql_8" {
  name       = "demo"
  subnet_ids = [aws_subnet.private_db_1a.id, aws_subnet.private_db_1c.id]
}

resource "aws_db_instance" "mysql_8" {
  db_name                    = "todo_demo"
  identifier                 = "demo"
  engine                     = "mysql"
  engine_version             = "8.0.40"
  instance_class             = "db.t3.small"
  allocated_storage          = 20
  max_allocated_storage      = 30
  storage_type               = "gp2"
  storage_encrypted          = true
  kms_key_id                 = aws_kms_key.demo.arn
  username                   = aws_ssm_parameter.db_username.value
  password                   = aws_ssm_parameter.db_password.value
  multi_az                   = true
  publicly_accessible        = false
  backup_window              = "09:10-09:49"
  backup_retention_period    = 30
  maintenance_window         = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  deletion_protection        = false
  skip_final_snapshot        = true
  port                       = 3306
  apply_immediately          = false
  vpc_security_group_ids     = [module.mysql_sg.security_group_id]
  parameter_group_name       = aws_db_parameter_group.mysql_8.name
  option_group_name          = aws_db_option_group.mysql_8.name
  db_subnet_group_name       = aws_db_subnet_group.mysql_8.name

  lifecycle {
    ignore_changes = [password]
  }
}

#
# CloudWatch
#
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/demo/backend"
  retention_in_days = 180
}
