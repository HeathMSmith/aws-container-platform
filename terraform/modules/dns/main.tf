resource "aws_route53_record" "service" {
  zone_id = var.hosted_zone_id
  name    = var.service_hostname
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
