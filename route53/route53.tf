resource "aws_route53_record" "dns_record" {
  zone_id = var.dns_zone_id
  name    = var.dns_name
  type    = "A"

  alias {
    name                   = var.apci_jupiter_alb_dns_name
    zone_id                = var.apci_jupiter_alb_zone_id
    evaluate_target_health = true
  }
}