resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus_operator" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  timeout    = 6000

  set {
    name  = "prometheusOperator.enabled"
    value = "true"
  }

  set {
    name  = "kubePrometheusStack.grafana.enabled"
    value = "true"
  }

  set {
    name  = "kubePrometheusStack.alertmanager.enabled"
    value = "true"
  }

  set {
    name  = "kubePrometheusStack.prometheus.enabled"
    value = "true"
  }
}
