

function gcloud_instance_info()
{
    local instance_id=$1
    local cache_file="deployments/$DEPLOYMENT_ID/cache/$instance_id.json"
    if [[ ! -f "$cache_file" ]]
    then
        gcloud compute instances describe --format json $instance_id > $cache_file
    fi
    cat $cache_file
}