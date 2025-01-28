terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

/*provider "random" {
}*/

resource "random_string" "token" {
  length  = 32
  special = true
}
resource "kubernetes_secret" "opensearch" {
  metadata {
    name      = "opensearch"
    namespace = "default"
  }
  type = "kubernetes.io/basic-auth"

  data = {
    username = "admin"
    password = random_string.token.result
  }
}

module "logging_stack" {
  source     = "./logging"
  depends_on = [kubernetes_secret.opensearch]
}

/*module "certificates_install" {
  source = "./certificates"
}*/

/*module "postgres" {
  source = "./database/postgres-operator"
}*/
/*module "postgres" {
  source = "./database/cnpg"
}*/

module "init_jobs" {
  source     = "./jobs"
  depends_on = [module.logging_stack]
}

/*module "apps" {
  source     = "./applications"
  depends_on = [module.init_jobs]
}

module "reverse_proxy" {
  source     = "./networking/nginx-reverse-proxy"
  depends_on = [module.apps]
}

module "prometheus" {
  source     = "./logging/prometheus"
  depends_on = [module.init_jobs]
}*/
