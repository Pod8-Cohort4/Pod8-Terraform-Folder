provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}



# =========================================
# EKS AUTH
# =========================================
data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks.name
}

# =========================================
# NGINX INGRESS HELM RELEASE
# =========================================
resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress-${substr(replace(timestamp(), "[:-]", ""), 0, 10)}"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.12.0"
  namespace        = "ingress-nginx"
  create_namespace = true
  values           = [file("${path.module}/nginx-ingress-values.yaml")]

  depends_on = [aws_eks_node_group.eks_node_group]

  timeout = 1200
  atomic  = false
}




# =========================================
# OPTIONAL: WAIT FOR NGINX LB
# =========================================
# data "aws_lb" "nginx_ingress" {
#   tags = {
#     "kubernetes.io/service-name" = "ingress-nginx/nginx-ingress-ingress-nginx-controller"
#   }
#   depends_on = [helm_release.nginx_ingress]
# }

# =========================================
# CERT-MANAGER HELM RELEASE
# =========================================
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.14.5"
  namespace        = "cert-manager"
  create_namespace = true

  set = [
    {
      name  = "installCRDs"
      value = "true"
    }
  ]

  depends_on = [helm_release.nginx_ingress]
}

# =========================================
# ARGOCD HELM RELEASE
# =========================================
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.6"
  namespace        = "argocd"
  create_namespace = true
  values           = [file("${path.module}/argocd-values.yaml")]

  depends_on = [helm_release.nginx_ingress, helm_release.cert_manager]
}
