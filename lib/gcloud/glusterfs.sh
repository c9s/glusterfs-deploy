#!/bin/bash

function glusterfs_instance_id()
{
  local instance_idx=$1
  echo "$PREFIX-gluster-$ZONEID-$instance_idx"
}

# glusterfs_init_instance_list init the gluster instance ID list
function glusterfs_init_instance_list()
{
  for ((i=1; i<=$N; i++))
  do
    GLUSTER_INSTANCES+=("$PREFIX-gluster-$ZONEID-$i")
  done
}

# glusterfs_init_heketi_instance_id assigns the first glusterfs instance as the heketi instance
function glusterfs_init_heketi_instance_id()
{
    HEKETI_INSTANCE=${GLUSTER_INSTANCES[0]}
}


function glusterfs_uninstall_on()
{
    local instance_id=$1
    gcloud_ssh_command $instance_id "sudo yum remove --assumeyes --quiet centos-release-gluster310 && \
                sudo yum remove --assumeyes --quiet glusterfs glusterfs-libs glusterfs-server lvm2"
}


function glusterfs_init_probe_instance_list()
{
    GLUSTER_PROBE_INSTANCES=(${GLUSTER_INSTANCES[@]})
    GLUSTER_PROBE_INSTANCES=(${GLUSTER_PROBE_INSTANCES[@]:1})
}

function glusterfs_install_server_on()
{
    local instance_id=$1
    info "$instance_id" "Installing packages..."
    gcloud_ssh_command $instance_id "sudo yum install --assumeyes --quiet centos-release-gluster310 && \
                sudo yum install --assumeyes --quiet glusterfs gluster-cli glusterfs-libs glusterfs-server lvm2"

    info "$instance_id" "Setting up gluster service..."
    gcloud_ssh_command $instance_id "sudo setenforce 0 && sudo systemctl enable --now glusterd.service"

    info "$instance_id" "Set permit root login => without password ..."
    gcloud_ssh_command $instance_id "sudo sed -i 's/PermitRootLogin no/PermitRootLogin without-password/g' /etc/ssh/sshd_config && \
            sudo systemctl restart sshd.service"
}

function glusterfs_peer_probe()
{
    local instance_id=$1
    local probe_instance_id=$2
    info "$HEKETI_INSTANCE" "peer probe $probe ..."
    gcloud_ssh_command "$instance_id" \
        "sudo gluster peer probe ${probe_instance_id}"
}
