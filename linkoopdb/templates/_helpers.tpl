{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "linkoopdb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "linkoopdb.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "linkoopdb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "linkoopdb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "linkoopdb.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
-----------database start----------
*/}}
{{- define  "_database.pv" -}}
{{- range $index, $node := (lookup "v1" "Node" "" "").items -}}
{{ $labels := $node.metadata.labels }}
{{ $value := get $labels $.Values.server.nodeAffinity.key }}
{{- if eq (toString $.Values.server.nodeAffinity.value) $value }}
{{ get $labels "kubernetes.io/hostname" }}
{{- end }}
{{- end -}}
{{- end -}}

{{- define  "_database.nodes" -}}
{{- range $index, $node := (lookup "v1" "Node" "" "").items -}}
{{ $labels := $node.metadata.labels }}
{{ $value := get $labels $.Values.server.nodeAffinity.key }}
{{- if eq (toString $.Values.server.nodeAffinity.value) $value }}
{{ get $labels "kubernetes.io/hostname" }}
{{- end }}
{{- end -}}
{{- end -}}

{{- define  "database.nodes" -}}
{{ include "_database.nodes" . | trim }}
{{- end -}}

{{- define "database.mode" -}}
{{- if gt (.Values.server.replicas | default 1 | int) 1 -}}
    {{ "ha" }}
{{- else -}}
    {{ "single" }}
{{- end -}}
{{- end -}}

{{- define "ldb.database.ha.nodelist" -}}
{{- range $i := until (.Values.server.replicas | default 1 | int) -}}
{{- printf "%s-database-%d:%s-database-%d.%s-database:%s:%s," (include "linkoopdb.name" $)  $i (include "linkoopdb.name" $) $i (include "linkoopdb.name" $) ($.Values.server.ports.atomixPort | default 5001 | toString ) ($.Values.server.ports.jdbcPort| default 9105 | toString) -}}
{{- end -}}
{{- end -}}

{{- define "_ldb.database.uris.items" -}}
{{- range $i := until (.Values.server.replicas | default 1 | int) -}}
{{- printf "%s-database-%d.%s-database:%s|" (include "linkoopdb.name" $) $i (include "linkoopdb.name" $) ($.Values.server.ports.jdbcPort | default 9105 | toString) -}}
{{- end -}}
{{- end -}}

{{- define "ldb.database.uris" -}}
{{- if gt (.Values.server.replicas | default 1 | int) 1 -}}
{{- printf "jdbc:linkoopdb:cluster://" -}}
{{- else -}}
{{- printf "jdbc:linkoopdb:tcp://" -}}
{{- end -}}
{{- include "_ldb.database.uris.items" . | trimAll "|" -}}
{{- "/ldb" -}}
{{- end -}}
{{/*
-----------database end------------
*/}}

{{/*
-----------metastore start----------
*/}}
{{- define  "_metastore.nodes" -}}
{{- range $index, $node := (lookup "v1" "Node" "" "").items -}}
{{ $labels := $node.metadata.labels }}
{{ $value := get $labels $.Values.metastore.nodeAffinity.key }}
{{- if eq (toString $.Values.metastore.nodeAffinity.value) $value }}
{{ get $labels "kubernetes.io/hostname" }}
{{- end }}
{{- end -}}
{{- end -}}

{{- define  "metastore.nodes" -}}
{{ include "_metastore.nodes" . | trim }}
{{- end -}}

{{- define "metastore.mode" -}}
{{- if gt (.Values.metastore.replicas | default 1 | int) 1 -}}
    {{ "ha" }}
{{- else -}}
    {{ "single" }}
{{- end -}}
{{- end -}}

{{- define "ldb.metastore.ha.nodelist" -}}
{{- range $i := until (.Values.metastore.replicas | default 1 | int) -}}
{{- printf "%s-metastore-%d:%s-metastore-%d.%s-metastore:5002:9106," (include "linkoopdb.name" $) $i (include "linkoopdb.name" $) $i (include "linkoopdb.name" $) -}}
{{- end -}}
{{- end -}}

{{- define "_ldb.metastore.uris.items" -}}
{{- range $i := until (.Values.metastore.replicas | default 1 | int) -}}
{{- printf "%s-metastore-%d.%s-metastore:9106|" (include "linkoopdb.name" $) $i (include "linkoopdb.name" $) -}}
{{- end -}}
{{- end -}}

{{- define "ldb.metastore.uris" -}}
{{- if gt (.Values.metastore.replicas | default 1 | int) 1 -}}
{{- printf "jdbc:linkoopdb:cluster://" -}}
{{- else }}
{{- printf "jdbc:linkoopdb:tcp://" -}}
{{- end -}}
{{- include "_ldb.metastore.uris.items" . | trimAll "|" -}}
{{- "/ldb" -}}
{{- end -}}

{{- define "_ldb.metastore.extraJvmOpts" -}}
{{- printf "-Dlinkoopdb.kubernetes.pallas.env.PALLAS_STORAGE=%s/pallas/meta" .Values.shareDisk -}}
{{- printf "-Dlinkoopdb.kubernetes.pallas.env.STORAGE_NODE_PORT=9997" -}}
{{- if (include "metastore.storage.nodes" $ | empty | not) -}}
{{- printf "-Dlinkoopdb.kubernetes.pallas.num=%d" (len (regexSplit "\\s+" (include "metastore.storage.nodes" $ ) -1)) -}}
{{- range $index, $node := (regexSplit "\\s+" (include "metastore.storage.nodes" $ ) -1) -}}
{{- printf "-Dlinkoopdb.kubernetes.pallas.%d.nodeAffinity=%s" $index $node -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "ldb.metastore.extraJvmOpts" -}}
{{- include "_ldb.metastore.extraJvmOpts" . | replace "-D" " -D" -}}
{{- end -}}
{{/*
-----------metastore end------------
*/}}

{{/*
-----------metastore pallas start----------
*/}}
{{- define  "_metastore.storage.nodes" -}}
{{- range $index, $node := (lookup "v1" "Node" "" "").items -}}
{{ $labels := $node.metadata.labels }}
{{ $value := get $labels $.Values.metastore.storage.nodeAffinity.key }}
{{- if eq (toString $.Values.metastore.storage.nodeAffinity.value) $value }}
{{ get $labels "kubernetes.io/hostname" }}
{{- end }}
{{- end -}}
{{- end -}}

{{- define  "metastore.storage.nodes" -}}
{{ include "_metastore.storage.nodes" . | trim }}
{{- end -}}
{{/*
-----------metastore pallas end------------
*/}}

{{- define "batchWorkerLocalDir" -}}
{{- range $key, $val := .Values.shuffleService.localDir -}}
{{- printf "%s," $val -}}
{{- end -}}
{{- end -}}

{{/*
PersistentVolume
*/}}
{{- define "metastore.pv.prefix" -}}
{{ include "linkoopdb.name" $ }}-metastore-{{ $.Release.Name }}
{{- end -}}
{{- define "database.pv.prefix" -}}
{{ include "linkoopdb.name" $ }}-database-{{ $.Release.Name }}
{{- end -}}
{{- define "nfs.pv.name" -}}
{{ include "linkoopdb.name" $ }}-nfs-{{ $.Release.Name }}
{{- end -}}

{{/*
Encapsulate configmap data tool
*/}}
{{- define "ldb-toolkit.utils.template" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $last := base $context.Template.Name }}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{ include $wtf $context }}
{{- end -}}

{{/*
Encapsulate database configmap data
*/}}
{{- define "ldb-configmap.data" -}}
ldb.properties: |-
{{ tuple "config/ldb/_ldb.properties.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
ldb-meta.properties: |-
{{ tuple "config/ldb/_ldb-meta.properties.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
storage.conf.tpl: |-
{{ tuple "config/ldb/_storage.conf.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
ldb-env.sh: |-
{{ tuple "config/ldb/_ldb-env.sh.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
storagebase.properties: |-
{{ tuple "config/ldb/_storagebase.properties.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
isql-client-defaults.yaml: |-
{{ tuple "config/ldb/_isql-client-defaults.yaml.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
monitor-agent-default.yaml: |-
{{ tuple "config/ldb/_monitor-agent-default.yaml.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
log4j.properties: |-
{{ tuple "config/ldb/_log4j.properties.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
log4j.driver.properties: |-
{{ tuple "config/ldb/_log4j.driver.properties.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
log4j.executor.properties: |-
{{ tuple "config/ldb/_log4j.executor.properties.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
log4j.stream.properties: |-
{{ tuple "config/ldb/_log4j.stream.properties.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
{{- end -}}

{{/*
Encapsulate batch worker configmap data
*/}}
{{- define "batch-configmap.data" -}}
spark-defaults.conf: |-
{{ toYaml $.Values.batchWorker.config | indent 2 }}
{{- end -}}


{{/*
Encapsulate stream worker configmap data
*/}}
{{- define "stream-configmap.data" -}}
flink-conf.yaml: |-
{{ toYaml $.Values.stream.config | indent 2 }}
  jobmanager.rpc.address: {{ include "linkoopdb.name" . }}-stream-jobmanager
  state.backend: filesystem
{{- if .Values.hadoop.dependecy }}
  state.checkpoints.dir: {{ .Values.server.config.storageBase | default "ldb:///opt/linkoopdb/data" }}/flink-checkpoints
  state.savepoints.dir: {{ .Values.server.config.storageBase | default "ldb:///opt/linkoopdb/data" }}/flink-savepoints
  yarn.properties-file.location: {{ .Values.server.config.storageBase | default "ldb:///opt/linkoopdb/data" }}/flink-yarn/session
{{- else }}
  state.checkpoints.dir: {{ .Values.nfs.mountPath | default "/fsshare"  }}/flink-checkpoints
  state.savepoints.dir: {{ .Values.nfs.mountPath | default "/fsshare"  }}/flink-savepoints
  yarn.properties-file.location: {{ .Values.nfs.mountPath | default "/fsshare"  }}/flink-yarn/session
{{- end }}
  blob.server.port: 6124
  queryable-state.server.ports: 6125
{{- end -}}

{{/*
Encapsulate nginx related services configmap data
*/}}
{{- define "tpls-configmap.data" -}}
ldb-dist.conf.template: |-
{{ tuple "config/tpls/_ldb-dist.conf.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
ldb-monitor.conf.template: |-
{{ tuple "config/tpls/_ldb-monitor.conf.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
ldb-server.conf.template: |-
{{ tuple "config/tpls/_ldb-server.conf.tpl" . | include "ldb-toolkit.utils.template" | indent 2 }}
{{- end -}}