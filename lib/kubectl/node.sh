#!/bin/bash

function kubernetes_get_nodes()
{
    info "kubectl" "getting nodes..."
    kubectl get nodes --no-headers | awk '{ print $1 }'
}
