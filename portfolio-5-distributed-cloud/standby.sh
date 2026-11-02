#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD="$REPLICATION_PASSWORD"
export PGAPPNAME=bookmania_standby
install -d -m 0700 -o postgres -g postgres "$PGDATA"

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  # Refuse a partial/nonempty directory rather than deleting existing data.
  if [ -n "$(find "$PGDATA" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
    echo 'Standby data directory is nonempty but incomplete; inspect it before retrying.' >&2
    exit 1
  fi
  gosu postgres pg_basebackup -h primary -U bookmania_repl \
    -D "$PGDATA" -Fp -Xs -R --no-password
fi

# A persisted standby may restart, but a promoted primary must not be mistaken for it.
if [ ! -f "$PGDATA/standby.signal" ]; then
  echo 'standby.signal missing; refusing to start as a writable primary.' >&2
  exit 1
fi
exec gosu postgres postgres -D "$PGDATA" -c hot_standby=on
