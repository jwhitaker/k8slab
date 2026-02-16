#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

valid_actions=("deploy" "teardown")

usage() {
    echo "Usage: $0 -a <deploy|teardown>"
    echo "  -a     action to perform.  defaults to deploy"
    echo "  -t     comma-separated list of tags to run.  defaults to all"
    echo "  -h     show help"
    exit 1
}

action="deploy"
tags="all"

while getopts ":ha:t:" opt; do
  case $opt in
  h)
    usage
    ;;
  a)
    action="$OPTARG"
    ;;
  t)
    tags="$OPTARG"
    ;;
  *)
    usage
    ;;
  esac
done

if [[ ! " ${valid_actions[*]} " =~ " ${action} " ]]; then
    echo "Invalid action: $action"
    usage
fi

echo $action

ansible-playbook \
    "$SCRIPT_DIR/../playbooks/${action}.yaml" \
    -i "$SCRIPT_DIR/../inventory.yaml" \
    --tags "${tags}" 