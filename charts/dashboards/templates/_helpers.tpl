{{/*
Fix dashboard datasource references
*/}}
{{- define "dashboard.datasource.fix" -}}
{{- $dashboard := .dashboard -}}
{{- $datasourceUid := .datasourceUid -}}
{{- /* Make a copy without __inputs section */ -}}
{{- $newDashboard := omit $dashboard "__inputs" -}}

{{- /* Replace datasource references in panels */ -}}
{{- range $index, $panel := $newDashboard.panels -}}
  {{- if hasKey $panel "datasource" -}}
    {{- if hasKey $panel.datasource "uid" -}}
      {{- $_ := set $panel.datasource "uid" $datasourceUid -}}
    {{- end -}}
  {{- end -}}
  
  {{- /* Process panel targets */ -}}
  {{- if hasKey $panel "targets" -}}
    {{- range $tidx, $target := $panel.targets -}}
      {{- if hasKey $target "datasource" -}}
        {{- if hasKey $target.datasource "uid" -}}
          {{- $_ := set $target.datasource "uid" $datasourceUid -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  
  {{- /* Process nested panels */ -}}
  {{- if hasKey $panel "panels" -}}
    {{- range $nidx, $nestedPanel := $panel.panels -}}
      {{- if hasKey $nestedPanel "datasource" -}}
        {{- if hasKey $nestedPanel.datasource "uid" -}}
          {{- $_ := set $nestedPanel.datasource "uid" $datasourceUid -}}
        {{- end -}}
      {{- end -}}
      
      {{- /* Process nested panel targets */ -}}
      {{- if hasKey $nestedPanel "targets" -}}
        {{- range $ntidx, $nestedTarget := $nestedPanel.targets -}}
          {{- if hasKey $nestedTarget "datasource" -}}
            {{- if hasKey $nestedTarget.datasource "uid" -}}
              {{- $_ := set $nestedTarget.datasource "uid" $datasourceUid -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- /* Fix templating variables datasources */ -}}
{{- if hasKey $newDashboard "templating" -}}
  {{- if hasKey $newDashboard.templating "list" -}}
    {{- range $tidx, $template := $newDashboard.templating.list -}}
      {{- if hasKey $template "datasource" -}}
        {{- if hasKey $template.datasource "uid" -}}
          {{- $_ := set $template.datasource "uid" $datasourceUid -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- $newDashboard | toJson -}}
{{- end -}} 