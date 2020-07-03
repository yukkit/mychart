apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: airs.datapps.k8s.io
  labels:
    app.kubernetes.io/component: metastorage
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
    app.kubernetes.io/name: {{ include "linkoopdb.name" $ }}
spec:
  group: datapps.k8s.io
  versions:
    - name: v1
      served: true
      storage: true
  scope: Namespaced
  names:
    plural: airs
    singular: air
    kind: Air
    shortNames:
    - air
---
apiVersion: datapps.k8s.io/v1
kind: Air
metadata:
  name: linkoopdb-metastorage
  labels:
    app.kubernetes.io/component: metastorage
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
    app.kubernetes.io/name: {{ include "linkoopdb.name" $ }}
