#!/bin/sh
set -e

export PGHOST="$(bosh vms -d postgres --json| jq -r '.Tables[].Rows[] | select(.instance | contains("postgres")) | .ips')"
export PGPORT=5524
export PGPASSWORD="$(credhub get -n /bosh-lite/postgres/pgadmin_database_password -j | jq ".value" -r)"
export PGUSER="pgadmin"
export PGDATABASE="sandbox"

results=$(psql -f ./scripts/test-the-release/find-tables.sql)

if [[ "$results" == *"sandcastles"* ]]; then
  echo "Everything's fine! The table is there."
  exit 0
else
  echo "Something's wrong. The table is not there :("
  exit 1
fi
