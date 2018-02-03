#!/bin/bash
function info()
{
    local component=$1
    shift
    echo -e "[\033[32m$component\033[0m] $*" >&2
}


__dir__=$(dirname ${BASH_SOURCE[0]})
source $__dir__/gcloud/ssh.sh
source $__dir__/gcloud/disk.sh
source $__dir__/gcloud/instance.sh
source $__dir__/gcloud/glusterfs.sh
source $__dir__/gcloud/heketi.sh
