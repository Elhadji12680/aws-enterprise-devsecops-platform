#CREATING SECURITY GROUP FOR APPLICATION LOAD BALANCER---------------------------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = var.vpc_id

   tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-alb-sg"
})
}

#CREATING INGRESS RULES FOR ALB SECURITY GROUP-----------------------------------------------------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "allow_http_for_dev_server" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_https_for_dev_server" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
#CREATING OUTBOUND RULES FOR ALB SECURITY GROUP-----------------------------------------------------------------------------------------------
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_using_ssh_for_alb" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# CREATING TARGET GROUP FOR ALB-------------------------------------------------------------------------------------------------------------------------------- 
resource "aws_lb_target_group" "jupiter_app_target_group" {
  name     = "jupiter-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

    health_check {
    healthy_threshold   = 5
    interval = 30
    path = "/"
    port = "80"
    timeout = 5
    unhealthy_threshold = 2
    
    }
}
# CREATING APPLICATION LOAD BALANCER--------------------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "jupiter_app_alb" {
  name               = "jupiter-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.public_subnet_az_1a_id, var.public_subnet_az_1b_id]

  enable_deletion_protection = false
    #access_logs {
   # bucket  = "alb-access-logs-bucket"
    #enabled = true }
  

   tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-jupiter-app-alb"
})
}

# CREATING LISTENER FOR ALB--------------------------------------------------------------------------------------------------------------------------------
resource "aws_lb_listener" "jupiter_app_http_listener" {
  load_balancer_arn = aws_lb.jupiter_app_alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy = "ELBSecurityPolicy-2016-08"
  #certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/your-certificate-id"

  default_action {
    type             = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
    
  }
}

# CREATING LISTENER FOR ALB ON PORT 443--------------------------------------------------------------------------------------------------------------------------------
resource "aws_lb_listener" "jupiter_app_https_listener" {
  load_balancer_arn = aws_lb.jupiter_app_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jupiter_app_target_group.arn
  }
}

   
    
 