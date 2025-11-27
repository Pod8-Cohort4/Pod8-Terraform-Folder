# namecheap-name-servers.tf

# The Namecheap domain resource is disabled since API access is not available
# resource "namecheap_domain_records" "my-domain2-com" {
#   domain      = var.domain-name
#   mode        = "OVERWRITE"
#   nameservers = aws_route53_zone.r53_zone.name_servers
#
#   depends_on = [aws_route53_zone.r53_zone]
#
#   lifecycle {
#     ignore_changes = all
#   }
# }
