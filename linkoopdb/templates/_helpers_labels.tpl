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
