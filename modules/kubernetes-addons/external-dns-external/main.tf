locals {
  name            = try(var.helm_config.name, "external-dns-external")
  service_account = try(var.helm_config.service_account, "${local.name}-sa")

  argocd_gitops_config = merge(
    {
      enable             = true
      serviceAccountName = local.service_account
    },
    var.helm_config
  )
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/bitnami/charts/blob/main/bitnami/external-dns/Chart.yaml
  helm_config = merge(
    {
      description = "ExternalDNS Helm Chart"
      name        = local.name
      chart       = "external-dns"
      repository  = "https://charts.bitnami.com/bitnami"
      version     = "6.13.2"
      namespace   = local.name
    },
    var.helm_config
  )

  set_values = try(var.helm_config.set_values, [])

  addon_context     = var.addon_context
  manage_via_gitops = var.manage_via_gitops
}
