#!/bin/bash
function gcloud_disk_name()
{
    local instance_idx=$1
    local disk_idx=$2
    echo "$PREFIX-gluster-$ZONEID-disk-$instance_idx-$di"
}

function delete_disk()
{
    local disk=$1
    gcloud compute disks delete --quiet "$disk"
}

# gcloud_create_disk "$PREFIX-gluster-$ZONEID-disk-$i"
function gcloud_create_disk()
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
        --type "$DISK_TYPE" > /dev/null
}

function gcloud_dd_disk()
{
    local instance_id=$1
    local device=$1
    gcloud_ssh_command $instance_id "sudo dd if=/dev/zero of=$device bs=512 count=10"
}
