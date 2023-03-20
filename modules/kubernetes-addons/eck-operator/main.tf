locals {
  name            = try(var.helm_config.name, "eck-operator")
  namespace       = try(var.helm_config.namespace, "elasticsearch")
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/elastic/cloud-on-k8s/tree/main/deploy/eck-operator/Chart.yaml
  helm_config = merge(
    {
      name             = local.name
      chart            = local.name
      repository       = "https://helm.elastic.co"
      version          = "2.5.0"
      namespace        = local.namespace
      description      = "ECK Operator"
    },
    var.helm_config
  )
  manage_via_gitops = var.manage_via_gitops

  addon_context = var.addon_context
}
