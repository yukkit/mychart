ldb.worker.batch.resource.master.memory={{ .Values.metastore.config.resources.master.memory | default "4G" }}
ldb.worker.batch.resource.taskmanger.memory={{ .Values.metastore.config.resources.taskmanger.memory | default "6G" }}
ldb.worker.batch.resource.taskmanger.cpuCores={{ .Values.metastore.config.resources.taskmanger.cpuCores | default 3 }}
ldb.worker.batch.resource.taskmanger.number={{ .Values.metastore.config.resources.taskmanger.number | default 3 }}
ldb.worker.batch.yarn.jars={{ .Values.server.config.batchWorkerJars }}

{{- if gt 3 (len (regexSplit "\\s+" (include "metastore.storage.nodes" $ ) -1)) }}
ldb.storage.pallas.shardDuplicateNumber=1
ldb.storage.pallas.minShardDuplicateNumber=1
{{- end }}
ldb.server.mode={{ include "metastore.mode" . }}
ldb.storage.base={{ .Values.server.config.storageBase | default "ldb:///opt/linkoopdb/data" }}/metastore
ldb.storage.launcher=k8s
ldb.worker.launcher=k8s
ldb.worker.batch.master.extraJavaOptions={{ .Values.metastore.config.jvmOpts }}
ldb.server.kerberos.keytab={{ .Values.server.config.keytab }}

ldb.worker.batch.k8s.container.image={{ .Values.image.repository }}:{{ .Values.image.tag }}
ldb.worker.batch.k8s.container.image.pullPolicy={{ .Values.image.pullPolicy }}

ldb.server.workerRegister.port=17772
{{- if eq "single" (include "metastore.mode" .) }}
ldb.server.host={{ include "linkoopdb.name" . }}-metastore-0.{{ include "linkoopdb.name" . }}-metastore
{{- end }}
ldb.server.jdbc.port=9106
ldb.server.ha.nodelist={{ include "ldb.metastore.ha.nodelist" . | trimAll "," }}
ldb.worker.batch.k8s.ui.port={{ .Values.metastore.config.batchWorkerUiPort | default 30402 }}
ldb.worker.batch.local.dir={{ include "batchWorkerLocalDir" . | trimAll "," }}
