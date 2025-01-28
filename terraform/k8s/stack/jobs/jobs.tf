/*provider "kubectl" {
  
}*/
terraform {
  required_providers {
    kubectl = {
     source = "gavinbunney/kubectl"
    }
  }
}

/*resource "kubernetes_manifest" "postgres_init" {
  manifest = yamldecode(file("${path.module}/postgres-init-job.yaml"))
}

resource "kubernetes_manifest" "opensearch_dashboards_init_job" {
  manifest = yamldecode(file("${path.module}/opensearch-dashboards-init-job.yaml"))
}*/

/*resource "null_resource" "postgres_init_job" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/postgres-init-job.yaml"
  }
}*/

/*resource "null_resource" "opensearch_dashboards_init_job" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/opensearch-dashboards-init-job.yaml"
  }
}*/
resource "kubectl_manifest" "opensearch_dashboards_init_job" {
  yaml_body = file("${path.module}/opensearch-dashboards-init-job.yaml")
}