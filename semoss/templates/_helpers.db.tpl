{{- /* templates/_helpers.db.tpl */ -}}

{{- /* 
Minimal helpers to build a Postgres JDBC URL, with fallback requiring explicit connectionUrl 
when not Postgres or when driver/rdbmsType differ. 
*/ -}}

{{- define "semoss.db.jdbcUrl" -}}
{{- $e := . -}}

{{- /* If an explicit URL is provided, use it as-is */ -}}
{{- if $e.connectionUrl -}}
{{- $e.connectionUrl -}}
{{- else -}}
  {{- /* Assume Postgres; require explicit URL if a different type/driver/rdbmsType is set */ -}}
  {{- $type := default "postgres" $e.type | lower -}}
  {{- if ne $type "postgres" -}}
    {{- required (printf "connectionUrl required for db.type=%q" $e.type) $e.connectionUrl -}}
  {{- else -}}
    {{- /* If caller sets driver/rdbmsType to unexpected values, require explicit URL */ -}}
    {{- if and $e.driver (ne $e.driver "org.postgresql.Driver") -}}
      {{- required (printf "connectionUrl required when driver=%q (expected org.postgresql.Driver)" $e.driver) $e.connectionUrl -}}
    {{- else if and $e.rdbmsType (ne $e.rdbmsType "POSTGRES") -}}
      {{- required (printf "connectionUrl required when rdbmsType=%q (expected POSTGRES)" $e.rdbmsType) $e.connectionUrl -}}
    {{- else -}}
      {{- $host := required "db.host is required for postgres URL" $e.host -}}
      {{- $port := default 5432 $e.port -}}
      {{- $db   := required "database is required for postgres URL" $e.database -}}
      {{- $schema := default "public" $e.schema -}}
jdbc:postgresql://{{ $host }}:{{ $port }}/{{ $db }}?currentSchema={{ $schema }}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- /*
Generic wrapper for any per-DB node.
Inputs:
- .root : the root scope (.)
- .node : the per-DB values map (e.g., .Values.securityDb)
- .name : a display name for clearer error messages (e.g., "securityDb")
*/ -}}
{{- define "semoss.db.urlFor" -}}
{{- $root := .root -}}
{{- $node := .node -}}
{{- $name := default "dbNode" .name -}}

{{- /* Fail fast, but keep messages generic and reusable */ -}}
{{- $host     := required "db.host is required" $root.Values.db.host -}}
{{- $database := required (printf "%s.database is required" $name) $node.database -}}
{{- $schema   := default $root.Values.db.schema $node.schema -}}

{{- include "semoss.db.jdbcUrl" (dict
      "host"          $host
      "port"          $root.Values.db.port
      "database"      $database
      "schema"        $schema
      "type"          $root.Values.db.type
      "driver"        $root.Values.db.driver
      "rdbmsType"     $root.Values.db.rdbmsType
      "connectionUrl" $node.connectionUrl
   ) -}}
{{- end -}}