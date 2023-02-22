{
  namespace: {
    apiVersion: "v1",
    kind: "Namespace",
    metadata: {
      name: $._config.namespace.name,
      labels: {
          "argocd.argoproj.io/instance": $._config.namespace.name
      }
    }
  }
}

