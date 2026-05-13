#CREATING SECURITY GROUP FOR BATION HOST---------------------------------------------------------------
resource "aws_security_group" "bastion_host_sg" {
  name        = "bastion_host_sg"
  description = "Allow SSH traffic"
  vpc_id      = var.vpc_id

   tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-bastion-host-sg"
})
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.bastion_host_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_using_ssh" {
  security_group_id = aws_security_group.bastion_host_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#CREATING BATION HOST---------------------------------------- --------------------------------------------------------------------------
resource "aws_instance" "bastion_host" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_az_1a_id
  security_groups             = [aws_security_group.bastion_host_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = var.ec2_instance_profile_name

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-bastion-host"
  })
}

#CREATING SECURITY GROUP FOR PRIVATE SERVER ---------------------------------------------------------------
resource "aws_security_group" "private_server_sg" {
  name        = "private_server_sg"
  description = "Allow SSH traffic"
  vpc_id      = var.vpc_id

   tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-sg"
})
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_for_private_server" {
  security_group_id = aws_security_group.private_server_sg.id
  cidr_ipv4         = "0.0.0.0/0" #this cidr block range will be given by the networking team
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_using_ssh_for_private_server" {
  security_group_id = aws_security_group.private_server_sg.id
  cidr_ipv4         = "0.0.0.0/0" #this cidr block range will be given by the networking team
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# CREATING PRIVATE SERVER AZ-1A-----------------------------------------------------------
resource "aws_instance" "private_server_az_1a" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_az_1a_id
  security_groups             = [aws_security_group.private_server_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = false
  iam_instance_profile        = var.ec2_instance_profile_name

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-az-1a"
  })
}

# CREATING PRIVATE SERVER AZ-1B-----------------------------------------------------------
resource "aws_instance" "private_server_az_1b" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_az_1b_id
  security_groups             = [aws_security_group.private_server_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = false
  iam_instance_profile        = var.ec2_instance_profile_name

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-az-1b"
  })
}
