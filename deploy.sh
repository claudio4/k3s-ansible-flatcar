#!/bin/bash
if [ -z "$1" ]
then
      echo "You need to provide a cluster name with $0 my-cluster-name"
      exit 1
fi

ansible-playbook bootstrap-python.yml -i "inventory/$1/hosts.ini"
ansible-playbook site.yml -i "inventory/$1/hosts.ini"