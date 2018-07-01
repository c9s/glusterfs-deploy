#!/bin/bash

function gcloud:instance_external_ip()
{
    local instance=$1
    gcloud:instance_info $instance | jq --raw-output '.networkInterfaces[0].accessConfigs[0].natIP'
}

function gcloud_instance_network_ip()
{
    local instance=$1
    gcloud:instance_info $instance | jq --raw-output '.networkInterfaces[0].networkIP'
}


function gcloud:instance_info()
{
    local instance_id=$1
    local cache_dir="deployments/$DEPLOYMENT_ID/cache"
    local cache_file="deployments/$DEPLOYMENT_ID/cache/$instance_id.json"
    mkdir -p $cache_dir
    if [[ ! -f "$cache_file" ]]
    then
        gcloud compute instances describe --format json $instance_id > $cache_file
    fi
    cat $cache_file
}
