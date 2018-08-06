#!/bin/bash

function heketi:init_instance_id()
{
    HEKETI_INSTANCE=$1
}

function heketi:get_config_file()
{
    local instance_id=$1
    local target=$2
    info "heketi" "Downloading the default heketi json config..."
    gcloud compute scp $instance_id:/etc/heketi/heketi.json $target
}


function heketi:put_config_file()
{
    local instance_id=$1
    local target=$2

    info "heketi" "Uploading heketi json config..."
    gcloud compute scp "$target" $instance_id:./heketi.json
    gcloud compute ssh $instance_id --command "sudo cp -v $HEKETI_KEY_DIR/heketi.json{,bak} \
        && sudo cp -v heketi.json $HEKETI_KEY_DIR/heketi.json \
        && sudo chown heketi: $HEKETI_KEY_DIR/heketi.json"

    info "heketi" "Restarting heketi server..."
    heketi:start_on "$instance_id"
}


function heketi:patch_config_file()
{
    local target=$1
    local patch_file=$(mktemp /tmp/heketi-json-patch.XXXXXX)

    info "heketi" "Generating json patch file..."

    cat <<PATCH > $patch_file
[
    { "op": "replace", "path": "/glusterfs/sshexec/keyfile", "value": "$HEKETI_KEY_DIR/id_rsa" },
    { "op": "replace", "path": "/glusterfs/sshexec/user", "value": "root" },
    { "op": "replace", "path": "/glusterfs/sshexec/port", "value": "22" },
    { "op": "replace", "path": "/glusterfs/sshexec/fstab", "value": "/etc/fstab" },
    { "op": "replace", "path": "/glusterfs/executor", "value": "ssh" },
    { "op": "replace", "path": "/jwt/user/key", "value": "$HEKETI_JWT_USER_SECRET" },
    { "op": "replace", "path": "/jwt/admin/key", "value": "$HEKETI_JWT_ADMIN_SECRET" }
]
PATCH

    info "heketi" "Patching heketi json config..."
    local tmp_config_file=$(mktemp /tmp/heketi-json.XXXXX)
    cat $target | json-patch -p "$patch_file" \
        | json_pp > $tmp_config_file
    mv $tmp_config_file $target
}

function heketi:selfcheck()
{
    local instance_id=$1
    info "heketi" "Checking heketi service..."
    gcloud compute ssh $instance_id --command "curl -s $instance_id:8080/hello"
}

function heketi_get_external_ip()
{
    local instance_id=$1

    info "heketi" "Getting external IP from the NAT network interface"

    local ip=$(gcloud:instance_info "$instance_id" | jq --raw-output '.networkInterfaces[0].accessConfigs[0].natIP')
    echo $ip
}

function heketi:start_on()
{
    local instance_id=$1
    info "$instance_id: Starting heketi..."
    gcloud:ssh_command "$instance_id" "[[ -f /etc/heketi/container_id ]] \
        && sudo docker stop heketi5 \$(/etc/heketi/container_id) \
        && sudo docker rm heketi5 \$(/etc/heketi/container_id) \
        || true"
    gcloud:ssh_command "$instance_id" "sudo docker run --detach --publish 8080:8080 \
             --name heketi5 \
             --restart=always \
             --volume /etc/heketi:/etc/heketi \
             --volume /etc/heketi/db:/var/lib/heketi \
             heketi/heketi:5 | sudo tee /etc/heketi/container_id"
}

function heketi:install_on()
{
    local instance_id=$1

    local heketi_version=v5.0.1
    local heketi_arch=amd64
    local heketi_os=linux

    info "$instance_id: Installing docker..."
    gcloud:ssh_command "$instance_id" "sudo yum update -y && sudo yum install -y --quiet docker && sudo systemctl start docker"

    info "$instance_id: Installing heketi..."
    gcloud:ssh_command "$instance_id" "curl -L -O https://github.com/heketi/heketi/releases/download/${heketi_version}/heketi-${heketi_version}.${heketi_os}.${heketi_arch}.tar.gz \
        && tar xvzf heketi-${heketi_version}.${heketi_os}.${heketi_arch}.tar.gz \
        && sudo rsync -av heketi/ /etc/heketi/"
    # we can't install heketi via yum now...
    # gcloud:ssh_command "$instance_id" "sudo yum update -y && sudo yum -y --quiet install heketi heketi-client"
}

function gcloud:instance_add_tag()
{
    local instance_id=$1
    shift
    info "$instance_id" "Adding tags {$*}..."
    gcloud compute instances add-tags "$instance_id" --tags "$*" --zone "$ZONE"
}
