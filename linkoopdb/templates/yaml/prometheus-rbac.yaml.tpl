{{- if .Values.monitor.create }}
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: ["", "extensions", "apps"]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  - deployments
  - services
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: #{linkoopdb.kubernetes.namespace}
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
  - kind: ServiceAccount
    name: prometheus
    namespace: kube-system
  - kind: ServiceAccount
    name: prometheus
    namespace: #{linkoopdb.kubernetes.namespace}
{{- end }}