locals {
  name            = "external-secrets"
  service_account = try(var.helm_config.service_account, "${local.name}-sa")

  # https://github.com/external-secrets/external-secrets/blob/main/deploy/charts/external-secrets/Chart.yaml
  helm_config = merge(
    {
      name             = local.name
      chart            = local.name
      repository       = "https://charts.external-secrets.io"
      version          = "0.6.0"
      create_namespace = true
      namespace        = local.name
      description      = "The External Secrets Operator Helm chart default configuration"
    },
    var.helm_config
  )

  set_values = try(var.helm_config.set_values, [])

  irsa_config = {
    kubernetes_namespace                = local.helm_config["namespace"]
    kubernetes_service_account          = local.service_account
    create_kubernetes_namespace         = try(local.helm_config["create_kubernetes_namespace"], false)
    create_kubernetes_service_account   = try(local.helm_config["create_kubernetes_service_account"], false)
    create_service_account_secret_token = try(local.helm_config["create_service_account_secret_token"], false)
    irsa_iam_policies                   = try(var.helm_config["irsa_iam_policies"], null)
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account
  }
}
