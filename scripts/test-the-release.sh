#!/bin/sh
set -o errexit
set -o pipefail
IFS=$'\n\t'

set -o nounset

export PGHOST=${PGHOST}
export PGPORT=5524
export PGPASSWORD=${PGPASSWORD}
export PGUSER="pgadmin"
export PGDATABASE="sandboxes"

if [[ -z $PGPASSWORD ]]; then
  echo "No password found in CredHub! Is your deployment generating a value for 'pgadmin_database_password'?"
  echo "Try to deployment with the templates/operations/set-properties.yml ops file."
  exit 1
fi

results=$(psql -f ./scripts/test-the-release/find-tables.sql)

if [[ "$results" == *"sandcastles"* ]]; then
  echo "Everything's fine! The table is there."
  exit 0
else
  echo "Something's wrong. The table is not there :("
  exit 1
fi
