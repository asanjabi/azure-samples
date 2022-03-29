#!/bin/bash

getUserSid(){
    USER_SID=$(az ad user show --id $1 --query 'objectId' -o tsv)
    echo $USER_SID
}

getLoggedInUserSid(){
    USER_SID=$(az ad signed-in-user show --query 'objectId' -o tsv)
    echo $USER_SID
}

getLoggedInUserLogin(){
    USER_ID=$(az ad signed-in-user show --query 'userPrincipalName' -o tsv)
    echo $USER_ID
}

getGroupSid(){
    GROUP_SID=$(az ad group show --group $1 --query 'objectId' -o tsv)
    echo $GROUP_SID
}


#Pass in userid or group name and variable names to assign Sid and type
#ex. getBestSid name@org.com Sid SidType
getBestSid(){
    local SID
    local SID_TYPE
    local LOGIN

    if [ $# -lt 4]
    then
        LOGIN=$1
        SID=$(getGroupSid $1)
        if [ ! -z "$SID" ]; then
            SID_TYPE='Group'
        else
            SID=$(getUserSid $1)
            SID_TYPE='User'
        fi
    else
        SID=$(getLoggedInUserSid)
        SID_TYPE='User'
        LOGIN=$(getLoggedInUserLogin)
    fi

    if [ $# -lt 3 ]
    then
        eval ${1:-}=$SID
        eval ${2:-}=$SID_TYPE
        eval ${3:-}=$LOGIN
    else
        eval ${2:-}=$SID
        eval ${3:-}=$SID_TYPE
        eval ${3:-}=$LOGIN
    fi
}