#!/bin/bash

function disk_id()
{
  local instance_idx=$1
  local disk_idx=$2

  if [[ -z "$ZONEID" ]]
  then
    exit -1
  fi

  echo "$PREFIX-gluster-$ZONEID-disk-$instance_idx-$disk_idx"
}

function instance_id()
{
  local instance_idx=$1
  echo "$PREFIX-gluster-$ZONEID-$instance_idx"
}

function instance_info()
{
    local instance_id=$1
    local cache_file="deployments/$DEPLOYMENT_ID/cache/$instance_id.json"
    if [[ ! -f "$cache_file" ]]
    then
        gcloud compute instances describe --format json $instance_id > $cache_file
    fi
    cat $cache_file
}

function delete_disk()
{
    local disk=$1
    gcloud compute disks delete --quiet "$disk"
}

# create_disk "$PREFIX-gluster-$ZONEID-disk-$i"
function create_disk()
{
    local disk=$1
    local zone=$ZONE

    if [[ -z "$zone" ]]
    then
        zone="asia-east1-a"
    fi
    gcloud compute disks create --quiet "$disk" \
        --zone "$zone" \
        --size "$DISK_SIZE" \
        --labels "$DISK_LABELS" \
        --type "$DISK_TYPE"
}
