resource "aws_security_group" "apci_jupiter_alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_http_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_allow_http" {
  security_group_id = aws_security_group.apci_jupiter_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_allow_https" {
  security_group_id = aws_security_group.apci_jupiter_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.apci_jupiter_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# creating target group for alb -------------------------------------------------------------------------

resource "aws_lb_target_group" "apci_jupiter_tg" {
  name        = "apci-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

    health_check {
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200,301,302"
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

#creating alb -----------------------------------------------------------

resource "aws_lb" "apci_jupiter_alb" {
  name               = "apci-jupiter-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.apci_jupiter_alb_sg.id]
  subnets            = [var.apci_jupiter_public_subnet_az_1a, var.apci_jupiter_public_subnet_az_1c]

  enable_deletion_protection = false

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-alb"
  })
}

#creating alb listener-----------------------------------------------

resource "aws_lb_listener" "apci_jupiter_alb_listener" {
  load_balancer_arn = aws_lb.apci_jupiter_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Creating HTTPS listener-----------------------------------

resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.apci_jupiter_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apci_jupiter_tg.arn
  }
}