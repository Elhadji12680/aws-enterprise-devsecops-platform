# CREATING ROUTE 53 RECORD--------------------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "jupiter_app_route53_record" {
  zone_id = var.route53_zone_id
  name    = var.name
  type    = "A"
  

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}