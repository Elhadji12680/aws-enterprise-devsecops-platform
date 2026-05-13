#CREATING SECURITY GROUP FOR JUPITER APP---------------------------------------------------------------
resource "aws_security_group" "jupiter_server_sg" {
  name        = "jupiter_server_sg"
  description = "Allow SSH and HTTP and HTTPS traffic"
  vpc_id      = var.vpc_id

   tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-jupiter-server-sg"
})
}

#CREATING INGRESS RULES FOR JUPITER SERVER SECURITY GROUP-----------------------------------------------------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_for_jupiter_server" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_for_jupiter_server" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_for_jupiter_server" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


#CREATING OUTBOUND RULES FOR JUPITER SERVER SECURITY GROUP-----------------------------------------------------------------------------------------------
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_using_ssh_for_jupiter_server" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#CREATING LAUNCH TEMPLATE FOR JUPITER APP--------------------------------------------------------------------------------------------------------------------------------
resource "aws_launch_template" "jupiter_launch_template" {
  name_prefix   = "jupiter_launch_template"  
  image_id      = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  user_data = base64encode(file("scripts/jupiter-app-deployment.sh"))
    network_interfaces {
        security_groups = [aws_security_group.jupiter_server_sg.id]
        associate_public_ip_address = true
    }
    
     tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-launch-template"
})
}

# CREATING AUTO SCALING GROUP FOR JUPITER APP--------------------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "jupiter_app_asg" {
  name                      = "jupiter_app_asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.desired_capacity
  force_delete              = true
  vpc_zone_identifier       = [var.public_subnet_az_1a_id, var.public_subnet_az_1b_id]
  target_group_arns = var.jupiter_app_tg_arn
  launch_template {
    id      = aws_launch_template.jupiter_launch_template.id
    version = "$Latest"
  }
  

}