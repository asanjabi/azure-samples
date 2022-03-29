#!/bin/bash

SCRIPTS_DIR="$( dirname "${BASH_SOURCE[0]}" )"
export SCRIPTS_DIR

sourceIfExists() {
    if [ -f "$1" ]; then
        source "$1"
    fi
}

checkEnvDefined(){
    eval temp_var=\${"$1":-}
    if [ -z "$temp_var" ]; then
        echo "Environment variable Undefined: $1"
        error=1
    fi
}

exitIfDefined(){
    eval temp_var=\${"$1":-}
    if [ ! -z "$temp_var" ]; then
        echo "there was error"
        exit 1
    fi
}

getScriptDir(){
    SCRIPT_DIR="$( cd -- "$( dirname -- caller )" &> /dev/null && pwd )"
    echo "$SCRIPT_DIR"
}

loadEnvironment(){
    sourceIfExists ./env
    sourceIfExists ./.env
    sourceIfExists ./.env.local
}

createRg(){
    az group create -n "$1" -l "$2"
}

