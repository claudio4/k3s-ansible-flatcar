#!/bin/bash
if [ -z "$1" ]
then
      echo "You need to provide a cluster name with $0 my-cluster-name"
      exit 1
fi

ansible-playbook reset.yml -i "inventory/$1/hosts.ini"
