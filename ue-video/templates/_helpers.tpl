{{- define "ue-video.fullname" -}}
{{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}

{{- define "ue-video.ueYAML" -}}
# auto-generated UE config for UERANSIM
# minimal config: one UE entry rendered from Helm values
ues:
  - supi: "imsi-{{ .Values.mcc }}{{ .Values.mnc }}{{ .Values.initialMSISDN }}"
    mcc: "{{ .Values.mcc }}"
    mnc: "{{ .Values.mnc }}"
    key: "{{ .Values.key }}"
    op: "{{ .Values.op }}"
    opType: "{{ .Values.opType }}"
{{- end -}}