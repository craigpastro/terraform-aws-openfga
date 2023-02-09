data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = local.tags
}

resource "aws_subnet" "public" {
  count             = 3
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index + 101)
  availability_zone = data.aws_availability_zones.this.names[count.index]
  vpc_id            = aws_vpc.this.id

  tags = local.tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = local.tags
}

// All traffic will go through the igw
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = local.tags
}

resource "aws_route_table_association" "public" {
  count = 3

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "lb" {
  name   = "${local.name}-lb-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_lb" "this" {
  name               = "${local.name}-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.lb.id]

  enable_deletion_protection = false

  tags = local.tags
}

resource "aws_lb_target_group" "this" {
  name        = "${local.name}-lb-tg"
  protocol    = "HTTP"
  port        = var.port
  target_type = "ip"
  vpc_id      = aws_vpc.this.id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/healthz"
    unhealthy_threshold = "2"
  }

  tags = local.tags
}

// Listener checks for requests from clients and routes them.
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = local.tags
}
