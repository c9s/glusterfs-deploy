#!/bin/bash
function gcloud:ssh_command()
{
    local instance_id=$1
    shift
    gcloud compute ssh $instance_id --command "$*"
}
