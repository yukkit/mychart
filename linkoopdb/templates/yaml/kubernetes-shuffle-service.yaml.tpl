{{- if .Values.shuffleService.create }}
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: {{ include "linkoopdb.name" $ }}-shuffle
  labels:
{{ include "linkoopdb.labels" . | indent 4 }}
{{ include "linkoopdb.shuffle.label" . | indent 4 }}
spec:
  template:
    metadata:
      labels:
{{ include "linkoopdb.labels" . | indent 8 }}
{{ include "linkoopdb.shuffle.label" . | indent 8 }}
    spec:
      volumes:
      {{- range $key, $val := .Values.shuffleService.localDir }}
      - name: {{ $key }}
        hostPath:
          path: {{ $val | quote }}
          type: DirectoryOrCreate
      {{- end }}
      imagePullSecrets:
        - name: {{ .Values.image.imagePullSecrets }}
      containers:
      - name: shuffle
        image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        volumeMounts:
        {{- range $key, $val := .Values.shuffleService.localDir }}
        - name: {{ $key }}
          mountPath: {{ $val | quote }}
        {{- end }}
        args:
        - external-shuffle-service
        resources:
{{ toYaml .Values.server.resources | indent 12 }}
{{- end }}