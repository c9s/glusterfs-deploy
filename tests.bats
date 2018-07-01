#!/usr/bin/env bats
export DEPLOYMENT_ID=aurora
export PREFIX=example
export ZONEID=asia-east1-a

source lib/functions.sh

@test "glusterfs_instance_id" {
  local instance_idx=1
  local disk_id=1
  local result="$(glusterfs_instance_id 1)"
  [[ "$result" == "$PREFIX-gluster-$ZONEID-$instance_idx" ]]
}

@test "gcloud:instance_info" {
  local instance_idx=1
  local result="$(gcloud:instance_info aurora-dev-gluster-a-1 | jq --raw-output .networkInterfaces[0].kind)"
  [[ "$result" =~ "networkInterface" ]]
}


