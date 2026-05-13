output "jupiter_app_tg_arn" {
  value = [aws_lb_target_group.jupiter_app_target_group.arn]
}

output "alb_dns_name" {
  value = aws_lb.jupiter_app_alb.dns_name
}
output "alb_zone_id" {
  value = aws_lb.jupiter_app_alb.zone_id
}