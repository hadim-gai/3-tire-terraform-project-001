resource "aws_security_group" "apci_jupiter_app_sg" {
  name        = "jupiter_app-sg"
  description = "Allow SSH, and HTTP traffic from alb"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_ssh_http_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.apci_jupiter_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_from_alb" {
  security_group_id = aws_security_group.apci_jupiter_app_sg.id
  referenced_security_group_id = var.apci_jupiter_alb_sg
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.apci_jupiter_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# CREATING LAUNCH TEMPLATE FOR JUPITER SERVER----------------------------------------------
resource "aws_launch_template" "apci_jupiter_lt" {
  name_prefix   = "apci-jupiter-lt"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  user_data = base64encode(file("scripts/jupiter-app.sh"))

    network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.apci_jupiter_app_sg.id]
  }
}

#creating auto-scalling_group--------------------------------------------------

resource "aws_autoscaling_group" "apci_jupiter_asg" {
  name                      = "apci-jupiter-asg"
  max_size                  = 6
  desired_capacity          = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  vpc_zone_identifier       = [var.apci_jupiter_public_subnet_az_1a, var.apci_jupiter_public_subnet_az_1c]
  target_group_arns         = [var.apci_jupiter_tg]

  launch_template {
    id      = aws_launch_template.apci_jupiter_lt.id
    version = "$Latest"

  }
  tag {
    key                 = "Name"
    value               = "apci-jupiter-app-server"
    propagate_at_launch = true
  }
}