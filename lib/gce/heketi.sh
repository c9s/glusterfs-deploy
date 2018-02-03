#!/bin/bash

function heketi_init_instance_id()
{
    HEKETI_INSTANCE=$1
}

function heketi_get_config_file()
{
    local instance_id=$1
    local target=$2
    info "heketi" "Getting heketi json config..."
    gcloud compute scp $instance_id:/etc/heketi/heketi.json $target
}


function heketi_put_config_file()
{
    local instance_id=$1
    local target=$2

    info "heketi" "Uploading heketi json config..."
    gcloud compute scp "$target" $instance_id:./heketi.json

    info "heketi" "Restarting heketi server..."
    gcloud compute ssh $instance_id --command "sudo cp -v heketi.json $HEKETI_KEY_DIR/heketi.json \
        && sudo chown heketi: $HEKETI_KEY_DIR/heketi.json \
        && sudo systemctl enable heketi \
        && sudo systemctl restart heketi"
}


function heketi_patch_config_file()
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

function heketi_selfcheck()
{
    local instance_id=$1
    info "heketi" "Checking heketi service..."
    gcloud compute ssh $instance_id --command "curl -s $instance_id:8080/hello"
}
