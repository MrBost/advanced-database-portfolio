#!/usr/bin/env bash
set -euo pipefail

# Password supplied by local .env, not stored in the repository.
psql -v ON_ERROR_STOP=1 --username postgres --dbname bookmania \
  --set=repl_password="$REPLICATION_PASSWORD" <<'SQL'
CREATE ROLE bookmania_repl WITH REPLICATION LOGIN PASSWORD :'repl_password';
SQL
printf '\nhost replication bookmania_repl all scram-sha-256\n' >> "$PGDATA/pg_hba.conf"
