locals {
  name            = try(var.helm_config.name, "memcached")
  namespace       = try(var.helm_config.namespace, "kube-system")
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/bitnami/charts/blob/main/bitnami/memcached/Chart.yaml
  helm_config = merge(
    {
      name             = local.name
      chart            = local.name
      repository       = "https://charts.bitnami.com/bitnami"
      version          = "6.3.3"
      namespace        = local.namespace
      description      = "Memcached"
    },
    var.helm_config
  )
  manage_via_gitops = var.manage_via_gitops

  addon_context = var.addon_context
}
