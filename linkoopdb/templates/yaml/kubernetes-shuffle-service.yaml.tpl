{{- if .Values.shuffleService.create }}
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: {{ include "linkoopdb.name" $ }}-shuffle-service
  labels:
    app.kubernetes.io/name: {{ include "linkoopdb.name" $ }}
    app.kubernetes.io/instance: {{ $.Release.Name }}
    app.kubernetes.io/component: shuffle
    app.kubernetes.io/managed-by: {{ $.Release.Service }}
spec:
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "linkoopdb.name" $ }}
        app.kubernetes.io/instance: {{ $.Release.Name }}
        app.kubernetes.io/component: shuffle
        app.kubernetes.io/managed-by: {{ $.Release.Service }}
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