#creating Security Group for Bastion Host-------------------------------------------
resource "aws_security_group" "apci_jupiter_bastion_sg" {
  name        = "apci_jupiter_bastion-sg"
  description = "Allow SSH traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion_host_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.apci_jupiter_bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ssh_traffic_ipv4" {
  security_group_id = aws_security_group.apci_jupiter_bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#creating EC2 for Bastion Host-------------------------------------

resource "aws_instance" "apci_jupiter_bastion_host" {
  ami           = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  associate_public_ip_address = true
  subnet_id = var.apci_jupiter_public_subnet_az_1a
  security_groups = [aws_security_group.apci_jupiter_bastion_sg.id]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-bastion-host"
  })
}

#creating Security Group for private server--------------------------------------

resource "aws_security_group" "apci_jupiter_private_server_sg" {
  name        = "private_server"
  description = "Allow SSH traffic from bastion host"
  vpc_id      = var.vpc_id

  tags = {
    Name = "private_server_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_bastion_host" {
  security_group_id = aws_security_group.apci_jupiter_private_server_sg.id
  referenced_security_group_id = aws_security_group.apci_jupiter_bastion_sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_bastion_host_ssh_traffic_ipv4" {
  security_group_id = aws_security_group.apci_jupiter_private_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#craeting private server for az-1a-------------------------

resource "aws_instance" "apci_jupiter_private_server_az_1a" {
  ami           = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  associate_public_ip_address = false
  subnet_id = var.apci_jupiter_private_subnet_az_1a
  security_groups = [aws_security_group.apci_jupiter_private_server_sg.id]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_server_az_1a"
  })
}

#craeting private server for az-1c-------------------------

resource "aws_instance" "apci_jupiter_private_server_az_1c" {
  ami           = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  associate_public_ip_address = false
  subnet_id = var.apci_jupiter_private_subnet_az_1c
  security_groups = [aws_security_group.apci_jupiter_private_server_sg.id]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_server_az_1c"
  })
}