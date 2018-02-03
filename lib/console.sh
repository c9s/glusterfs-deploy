#!/bin/bash
function info()
{
    local component=$1
    shift
    echo -e "[\033[32m$component\033[0m] $*" >&2
}
