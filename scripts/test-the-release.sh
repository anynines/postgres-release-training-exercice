#!/usr/bin/env bash
set -o errexit
set -o pipefail
IFS=$'\n\t'

set -o nounset

export PGPORT=5524
export PGPASSWORD=${PGPASSWORD}
export PGUSER="pgadmin"
export PGDATABASE="sandboxes"

results=$(psql -f ./scripts/test-the-release/find-tables.sql)

if [[ "$results" == *"sandcastles"* ]]; then
  echo "Everything's fine! The table is there."
  exit 0
else
  echo "Something's wrong. The table is not there :("
  exit 1
fi
