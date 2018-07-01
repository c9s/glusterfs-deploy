#!/bin/bash
function gcloud:disk_name()
{
    local instance_idx=$1
    local disk_idx=$2
    echo "$PREFIX-gluster-$ZONEID-disk-$instance_idx-$di"
}

function gcloud:list_disks()
{
    gcloud compute disks list --filter="zone:($ZONE)"
}

function gcloud:delete_disk()
{
    local disk_name=$1
    gcloud compute disks delete --quiet "$disk_name"
}

# gcloud:create_disk "$PREFIX-gluster-$ZONEID-disk-$i"
function gcloud:create_disk()
{
    local disk_name=$1
    shift

    local zone=$ZONE
    if [[ -z "$zone" ]]
    then
        zone="asia-east1-a"
    fi
    gcloud compute disks create --quiet "$disk_name" --zone "$zone" $* > /dev/null
}

function gcloud:dd_disk()
{
    local instance_id=$1
    local device=$1
    gcloud:ssh_command $instance_id "sudo dd if=/dev/zero of=$device bs=512 count=10"
}
