locals {
  name      = "datadog"
  namespace = "monitoring"
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/DataDog/helm-charts/blob/main/charts/datadog/Chart.yaml
  helm_config = merge(
    {
      name             = local.name
      chart            = local.name
      repository       = "https://helm.datadoghq.com"
      version          = "3.6.4"
      namespace        = local.namespace
      create_namespace = true
      description      = "Datadog"
    },
    var.helm_config
  )
  manage_via_gitops = var.manage_via_gitops

  addon_context = var.addon_context
}
