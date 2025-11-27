# output "nginx_ingress_lb_dns" {
#   value = data.aws_lb.nginx_ingress.dns_name
# }

# output "nginx_lb_ip" {
#   value = data.aws_lb.nginx_ingress.ip_address_type == "ipv4" ? data.aws_lb.nginx_ingress.dns_name : ""
# }
# output "nginx_ingress_load_balancer_hostname" {
#   value = data.aws_lb.nginx_ingress.dns_name
# }
output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}
