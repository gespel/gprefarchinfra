resource "kubernetes_manifest" "logstash_configmap" {
  manifest = yamldecode(file("${path.module}/logstash-configmap.yaml"))
}
resource "kubernetes_manifest" "logstash_service" {
  manifest = yamldecode(file("${path.module}/logstash-service.yaml"))
}
resource "kubernetes_manifest" "logstash_deployment" {
  manifest = yamldecode(file("${path.module}/logstash-deployment.yaml"))
  depends_on = [ kubernetes_manifest.logstash_configmap, kubernetes_manifest.logstash_service ]
}

resource "kubernetes_manifest" "opensearch_service" {
  manifest = yamldecode(file("${path.module}/opensearch-service.yaml"))
}
resource "kubernetes_manifest" "opensearch_deployment" {
  manifest = yamldecode(file("${path.module}/opensearch-deployment.yaml"))
  depends_on = [ kubernetes_manifest.opensearch_service ]
}

resource "kubernetes_manifest" "opensearch_dashboards_service" {
  manifest = yamldecode(file("${path.module}/opensearch-dashboards-service.yaml"))
}
resource "kubernetes_manifest" "opensearch_dashboards_deployment" {
  manifest = yamldecode(file("${path.module}/opensearch-dashboards-deployment.yaml"))
  depends_on = [ kubernetes_manifest.opensearch_dashboards_service ]
}

