#!/bin/bash
__dir__=$(dirname ${BASH_SOURCE[0]})
source $__dir__/console.sh
source $__dir__/gcloud/ssh.sh
source $__dir__/gcloud/disk.sh
source $__dir__/gcloud/instance.sh
source $__dir__/gcloud/glusterfs.sh
source $__dir__/gcloud/heketi.sh
