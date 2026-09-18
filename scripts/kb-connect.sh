#!/usr/bin/env bash

# KB Connect
# This script is designed to interact with Kubectl containers using gcloud tools
# By Nicholas Grogg
# Revision: 20260918

# Set exit on error
set -e

## Help function
function help_function(){
    printf "%s\n" \
    "Help" \
    "----------------------------------------------------" \
    " " \
    "help/Help" \
    "* Display this help message and exit" \
    " " \
    "pods/Pods" \
    "* List all pods" \
    "* Can filter out a specific pod" \
    "Ex. ./kb-connect.sh pods" \
    "Ex. ./kb-connect.sh pods alias " \
    " " \
    "ingress/Ingress" \
    "* List pod domains and public IPs" \
    "* Can filter out a specific pod" \
    "Ex. ./kb-connect.sh ingress" \
    "Ex. ./kb-connect.sh ingress alias" \
    " " \
    "connect/Connect" \
    "* Connect to pod" \
    "* Lists all pods before for easy copying" \
    "* Can provide a pod name to connect directly" \
    "* Can match on partials" \
    "Ex. ./kb-connect.sh connect" \
    "Ex. ./kb-connect.sh connect pod"
}

## Function to list all pods
function pods(){
    printf "%s\n" \
    "Pods" \
    "----------------------------------------------------"

    if [[ -z $1 ]]; then
        kubectl get pods
    else
        kubectl get pods | grep $1
    fi
}

## Function to list pod A records and public IPs
function ingress(){
    printf "%s\n" \
    "Ingress" \
    "----------------------------------------------------"

    if [[ -z $1 ]]; then
        kubectl get ingress
    else
        kubectl get ingress | grep $1
    fi
}

## Function to connect to pod
function connect(){
    printf "%s\n" \
    "Connect" \
    "----------------------------------------------------"
    if [[ -z $1 ]]; then
        # Output pods
        kubectl get pods

        # Get pod name
        printf "%s\n" \
        "Copy/Paste pod name to access" \
        "----------------------------------------------------"
        read podName

        kubectl exec -it $podName -- /bin/bash
    else
        kubectl exec -it $(kubectl get pods | grep $1) -- /bin/bash
    fi
}

## Main, read passed flags
    printf "%s\n" \
    "kb-connect.sh" \
    "----------------------------------------------------" \
    " " \
    "Checking flags passed" \
    "----------------------------------------------------"

## Check passed flags
case "$1" in
[[Hh]]elp)
    printf "%s\n" \
    "Running Help function" \
    "----------------------------------------------------"
    help_function
    exit
    ;;
[[Pp]]ods)
    printf "%s\n" \
    "Listing pods" \
    "----------------------------------------------------"
    pods $2
    ;;
[[Ii]]ngress)
    printf "%s\n" \
    "Listing Ingress" \
    "----------------------------------------------------"
    ingress $2
    ;;
[[Cc]]onnect)
    printf "%s\n" \
    "Connecting to pod" \
    "----------------------------------------------------"
    connect $2
    ;;
*)
    printf "%s\n" \
    "ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input"
    help_function
    exit
    ;;
esac
