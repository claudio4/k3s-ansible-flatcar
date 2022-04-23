#!/bin/bash
ansible-playbook bootstrap-python.yml -i inventory/my-cluster/hosts.ini
ansible-playbook site.yml -i inventory/my-cluster/hosts.ini