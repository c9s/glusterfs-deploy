
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
    gcloud compute ssh $instance_id \
        --command "sudo yum remove --assumeyes --quiet centos-release-gluster310 && \
                sudo yum remove --assumeyes --quiet glusterfs glusterfs-libs glusterfs-server lvm2"
}


function glusterfs_init_probe_instance_list()
{
    GLUSTER_PROBE_INSTANCES=(${GLUSTER_INSTANCES[@]})
    GLUSTER_PROBE_INSTANCES=(${GLUSTER_PROBE_INSTANCES[@]:1})
}
