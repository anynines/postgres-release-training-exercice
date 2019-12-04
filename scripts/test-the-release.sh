#!/usr/bin/env bash

set -o errexit
set -o pipefail
IFS=$'\n\t'

export deployment_name="${1:-$BOSH_DEPLOYMENT}"
export director_name="${2:-$BOSH_DIRECTOR}"

echo "Running with deployment '${deployment_name}' and director '${director_name}'."

set -o nounset

export PGHOST="$(bosh vms -d ${deployment_name} --json | jq -r '.Tables[].Rows[] | select(.instance | contains("postgres")) | .ips')"
export PGPORT=5524
export PGPASSWORD="$(credhub get -n /${director_name}/${deployment_name}/pgadmin_database_password -j | jq ".value" -r)"
export PGUSER="pgadmin"
export PGDATABASE="sandboxes"

if [[ -z $PGPASSWORD ]]; then
  echo "No password found in CredHub! Is your deployment generating a value for 'pgadmin_dadabase_password'?"
  echo "Try to deployment with the templates/operations/set-properties.yml ops file."
  exit 1
fi

results=$(psql -f ${BASH_SOURCE%/*}/test-the-release/find-tables.sql)

if [[ "$results" == *"sandcastles"* ]]; then
  echo "Everything's fine! The table is there."
  exit 0
else
  echo "Something's wrong. The table is not there :("
  exit 1
fi
