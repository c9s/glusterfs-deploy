#!/bin/bash
function info()
{
    local component=$1
    shift
    echo -e "[\033[32m$component\033[0m] $*" >&2
}

function gcloud_ssh_command()
{
    local instance_id=$1
    shift
    gcloud compute ssh $instance_id --command "$*"
}

source lib/gce/disk.sh
source lib/gce/instance.sh
source lib/gce/glusterfs.sh
source lib/gce/heketi.sh
