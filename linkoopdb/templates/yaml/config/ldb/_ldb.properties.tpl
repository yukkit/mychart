ldb.worker.totalMemory={{ .Values.batchWorker.resources.cluster.totalMemory | default "10T" }}
ldb.worker.totalCpuCores={{ .Values.batchWorker.resources.cluster.totalCpuCores | default 2048 }}
ldb.worker.numNodes={{ .Values.batchWorker.resources.cluster.numNodes | default 40 }}
ldb.worker.numExecutorsPerHost={{ .Values.batchWorker.resources.cluster.numNodes | default 10 }}
ldb.worker.totalGpuCores={{ .Values.batchWorker.resources.cluster.totalGpuCores | default 0 }}
ldb.worker.batch.resource.master.memory={{ .Values.batchWorker.resources.master.memory | default 0 }}
ldb.worker.batch.resource.taskmanger.memory={{ .Values.batchWorker.resources.taskmanger.memory | default 0 }}
ldb.worker.batch.resource.taskmanger.cpuCores={{ .Values.batchWorker.resources.taskmanger.cpuCores | default 0 }}
ldb.worker.batch.resource.taskmanger.number={{ .Values.batchWorker.resources.taskmanger.number | default 0 }}
ldb.worker.batch.resource.taskmanger.gpuCores={{ .Values.batchWorker.resources.taskmanger.number | default 0 }}
ldb.worker.batch.resource.queue={{ .Values.batchWorker.resources.cluster.queue }}
ldb.server.stream.enabled={{ .Values.stream.create | default true }}
ldb.server.mode={{ include "database.mode" . }}
ldb.storage.base={{ .Values.server.config.storageBase | default "ldb:///tmp/linkoopdb/" }}
ldb.storage.launcher=k8s
ldb.worker.launcher={{ .Values.batchWorker.launcher | default "k8s" }}
ldb.worker.batch.k8s.container.image={{ .Values.image.repository }}:{{ .Values.image.tag }}
ldb.worker.batch.k8s.container.image.pullPolicy={{ .Values.image.pullPolicy }}
ldb.worker.batch.yarn.jars={{ .Values.server.config.batchWorkerJars }}
ldb.server.sqlLog.enabled={{ .Values.server.config.sqlLogEnabled | default false }}
ldb.server.sqlHistory.enabled={{ .Values.server.config.sqlHistoryEnabled | default false }}
ldb.worker.batch.k8s.volumes.hostPath.pythonpv.options.path={{ "" }}
ldb.worker.batch.master.extraJavaOptions={{ .Values.batchWorker.config.jvmOpts }}
ldb.worker.hiveMetastoreUris={{ .Values.server.config.hiveMetastoreUris }}
ldb.worker.enableHiveSupport={{ .Values.server.config.enableHiveSupport | default false }}
ldb.server.metastore.type={{ .Values.metastore.type | default "LINKOOPDB" }}
{{- if eq "LINKOOPDB" (.Values.metastore.type | default "LINKOOPDB") }}
ldb.server.metastore.uris={{ include "ldb.metastore.uris" . }}
ldb.server.metastore.username={{ .Values.metastore.config.username | default "admin" }}
ldb.server.metastore.password={{ .Values.metastore.config.password | default "123456" }}
{{- else }}
ldb.server.metastore.driver={{ .Values.metastore.config.driver }}
ldb.server.metastore.uris={{ .Values.metastore.config.url }}
ldb.server.metastore.username={{ .Values.metastore.config.username }}
ldb.server.metastore.password={{ .Values.metastore.config.password }}
{{- end }}
ldb.server.kerberos.keytab={{ .Values.server.config.keytab }}
ldb.server.workerRegister.port={{ .Values.server.ports.regPort | default 17771 }}
ldb.server.dataSync.port={{ .Values.server.ports.dataSyncPort | default 33041 }}
{{- if eq "single" (include "database.mode" .) }}
ldb.server.host={{ include "linkoopdb.name" . }}-database-0.{{ include "linkoopdb.name" . }}-database
{{- end }}
ldb.server.jdbc.port={{ .Values.server.ports.jdbcPort | default 9105 }}
ldb.server.ha.nodelist={{ include "ldb.database.ha.nodelist" . | trimAll "," }}
ldb.worker.batch.k8s.ui.port={{ .Values.server.config.batchWorkerUiPort | default 30401 }}
ldb.worker.batch.k8s.shuffle.labels=app.kubernetes.io/name={{ include "linkoopdb.name" $ }},app.kubernetes.io/instance={{ $.Release.Name }},app.kubernetes.io/component=shuffle,app.kubernetes.io/managed-by={{ $.Release.Service }}
ldb.worker.batch.local.dir={{ include "batchWorkerLocalDir" . | trimAll "," }}
ldb.monitor.reporter.promgateway.host={{ include "linkoopdb.name" . }}-gateway
ldb.monitor.reporter.promgateway.port=9091
ldb.worker.stream.run.mode=REST
ldb.worker.stream.extLibs=/fsshare/{{ .Values.stream.streamWorker.libPath | default "ext" }}
ldb.worker.stream.kafkaLib=/fsshare/{{ .Values.stream.streamWorker.kafkaLibPath | default "kafka" }}
ldb.server.kerberos.krb5.conf=/etc/hadoop/conf/krb5.conf
ldb.worker.stream.extra.jdbc.lib=/fsshare/{{ .Values.stream.streamWorker.libPath | default "driver" }}
ldb.worker.stream.rest.web.address=http://{{ include "linkoopdb.name" . }}-stream-jobmanager:8081
ldb.worker.stream.resource.startup.mode=single
