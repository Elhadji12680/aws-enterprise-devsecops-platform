vpc_cidr_block       = "10.0.0.0/16"
subnet_cidr_block    = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
availability_zone    = ["us-east-1a", "us-east-1b"]
ami                  = "ami-02dfbd4ff395f2a1b" # Amazon Linux 2 AMI (HVM), SSD Volume Type
instance_type        = "t3.micro"
key_name             = "jupiter-keys"
ssl_policy           = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
certificate_arn      = "arn:aws:acm:us-east-1:171239862305:certificate/cea96fdb-1ef5-4853-8163-fd12ef232d3b"
route53_zone_id      = "Z09425701ZBOOY51HU7PN" # Replace with your actual hosted zone ID
name                 = "elvictura.com"
allocated_storage    = 10
db_name              = "mydb"
engine               = "mysql"
engine_version       = "8.0"
instance_class       = "db.t3.micro"
parameter_group_name = "default.mysql8.0"
region               = "us-east-1"
account_id           = "171239862305"

kubernetes_version = "1.30"
node_instance_type = "t3.medium"
node_desired_size  = 2
node_min_size      = 1
node_max_size      = 4

argocd_chart_version   = "7.3.11"
argocd_git_repo_url    = "https://github.com/Elhadji12680/aws-enterprise-devsecops-platform.git"
argocd_git_repo_branch = "main"

trivy_chart_version     = "0.23.0"
sonarqube_chart_version = "10.6.0+3033"

prometheus_stack_chart_version = "61.3.2"
# grafana_admin_password is injected at runtime via GRAFANA_ADMIN_PASSWORD GitHub secret

