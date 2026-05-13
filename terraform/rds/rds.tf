# CREATING DB SUBNET GROUP
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [var.db_subnet_az_1a, var.db_subnet_az_1b]

tags =  merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-group"
})
}

# CREATING SECURITY GROUP FOR RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow db traffic"
  vpc_id      = var.vpc_id

   tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-rds-sg"
})
}

resource "aws_vpc_security_group_ingress_rule" "allow_db_traffic" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# CREATING MYSQL RDS IN SECRET MANAGER------------------------------------------------------------------------------------------------------------------
data "aws_secretsmanager_secret" "db_password" {
  name = "jupiter_db_credentials_001"
}
data "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

#CREATING MYSQL DB INSTANCE--------------------------------------------------------------------------------------------------
resource "aws_db_instance" "rds_mysql" {
  allocated_storage    = var.allocated_storage
  db_name              = var.db_name
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = jsondecode(data.aws_secretsmanager_secret_version.db_password_version.secret_string)   ["mysql_usename"]      #important
  password             = jsondecode(data.aws_secretsmanager_secret_version.db_password_version.secret_string)   ["mysql_usename"]   #important
  parameter_group_name = var.parameter_group_name
  skip_final_snapshot    = true
  multi_az               = true
  publicly_accessible    = false
  storage_type           = "gp2"   
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id    
  vpc_security_group_ids =     [aws_security_group.rds_sg.id]           
  iam_database_authentication_enabled =      true  

  tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-rds-mysql"
})
}     
                  

  
         