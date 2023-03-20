locals {
  name            = try(var.helm_config.name, "external-dns-internal")
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
      values = [
        <<-EOT
          provider: aws
          aws:
            region: ${var.addon_context.aws_region_name}
        EOT
      ]
    },
    var.helm_config
  )

  set_values = try(var.helm_config.set_values, [])

  irsa_config = {
    create_kubernetes_namespace         = try(var.helm_config.create_namespace, false)
    kubernetes_namespace                = try(var.helm_config.namespace, local.name)
    create_kubernetes_service_account   = try(var.helm_config["create_kubernetes_service_account"], false)
    create_service_account_secret_token = try(var.helm_config["create_service_account_secret_token"], false)
    kubernetes_service_account          = local.service_account
    irsa_iam_policies                   = try(var.helm_config["irsa_iam_policies"], null)
  }

  addon_context     = var.addon_context
  manage_via_gitops = var.manage_via_gitops
}

#------------------------------------
# IAM Policy
#------------------------------------

resource "aws_iam_policy" "external_dns_internal" {
  count       = var.create_irsa ? 1: 0 
  description = "External DNS Internal IAM policy."
  name        = "${var.addon_context.eks_cluster_id}-${local.name}-irsa"
  path        = var.addon_context.irsa_iam_role_path
  policy      = data.aws_iam_policy_document.external_dns_internal_iam_policy_document.json
  tags        = var.addon_context.tags
}
