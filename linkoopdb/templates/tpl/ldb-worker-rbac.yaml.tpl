apiVersion: v1
kind: ServiceAccount
metadata:
  name: spark
  namespace: #{linkoopdb.kubernetes.namespace}
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: edit-#{linkoopdb.kubernetes.namespace}
subjects:
  - kind: ServiceAccount
    name: spark
    namespace: #{linkoopdb.kubernetes.namespace}
  - kind: ServiceAccount
    name: default
    namespace: #{linkoopdb.kubernetes.namespace}
roleRef:
  kind: ClusterRole
  name: edit
  apiGroup: rbac.authorization.k8s.io