{{/*
Common labels
*/}}
{{- define "linkoopdb.labels" -}}
app.kubernetes.io/name: {{ include "linkoopdb.name" . }}
helm.sh/chart: {{ include "linkoopdb.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "linkoopdb.nfs.label" -}}
app.kubernetes.io/component: nfs
{{- end -}}

{{- define "linkoopdb.hadoop.label" -}}
app.kubernetes.io/component: hadoop
{{- end -}}

{{- define "linkoopdb.metastore.label" -}}
app.kubernetes.io/component: metastore
{{- end -}}

{{- define "linkoopdb.database.label" -}}
app.kubernetes.io/component: database
{{- end -}}

{{- define "linkoopdb.batch.label" -}}
app.kubernetes.io/component: batch
{{- end -}}

{{- define "linkoopdb.stream.worker.label" -}}
app.kubernetes.io/component: stream-worker
{{- end -}}

{{- define "linkoopdb.stream.debugWorker.label" -}}
app.kubernetes.io/component: stream-debug-worker
{{- end -}}

{{- define "linkoopdb.stream.jobmanager.label" -}}
app.kubernetes.io/component: stream-jobmanager
{{- end -}}

{{- define "linkoopdb.stream.taskmanager.label" -}}
app.kubernetes.io/component: stream-taskmanager
{{- end -}}

{{- define "linkoopdb.shuffle.label" -}}
app.kubernetes.io/component: shuffle
{{- end -}}

{{- define "linkoopdb.metrics.monitor.label" -}}
app.kubernetes.io/component: metrics-monitor
{{- end -}}

{{- define "linkoopdb.metrics.pushgateway.label" -}}
app.kubernetes.io/component: metrics-pushgateway
{{- end -}}

{{- define "linkoopdb.metrics.prometheus.label" -}}
app.kubernetes.io/component: metrics-prometheus
{{- end -}}

{{- define "linkoopdb.metrics.exporter.label" -}}
app.kubernetes.io/component: metrics-exporter
{{- end -}}

{{- define "linkoopdb.studio.label" -}}
app.kubernetes.io/component: studio
{{- end -}}

{{- define "linkoopdb.tpls.label" -}}
app.kubernetes.io/component: tpls
{{- end -}}