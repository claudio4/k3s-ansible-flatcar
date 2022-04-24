# Automated build of HA k3s Cluster with kube-vip for Flatcar

This playbook will build an HA Kubernetes cluster on Flatcar hosts with `k3s`, `kube-vip` via `ansible`.

This project tries to be unoppiniated so it just install the bare-minimum required for having an HA cluster that can handle your `kubectl` commands. This means that an installation produced from this project will lack important things like a CNI, an IngressController and a LoadBalancer, and yes the ones included with k3s are disabled.

This is based on the work from [this fork](https://github.com/techno-tim/k3s-ansible) which is based on [this other fork](https://github.com/212850a/k3s-ansible) ] which is based [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible). It uses [kube-vip](https://kube-vip.chipzoller.dev/) to create a load balancer for control plane.


## 📖 k3s Ansible Playbook

Build a Kubernetes cluster using Ansible with k3s. The goal is easily install a HA Kubernetes cluster on machines running:

- [X] Flatcar
- [ ] Fedora CoreOS (not tested)

on processor architecture:

- [X] x64
- [X] arm64

## ✅ System requirements

* Deployment environment must have Ansible 2.4.0+.  If you need a quick primer on Ansible [you can check out TechnoTim's docs and setting up Ansible](https://docs.technotim.live/posts/ansible-automation/).
* `server` and `agent` nodes should have passwordless SSH access, if not you can supply arguments to provide credentials `ñg-ask-pass --ask-become-pass` to ach command.

## 🚀 Getting Started

### 🍴 Preparation

First create a new directory based on the `sample` directory within the `inventory` directory:

```bash
cp -R inventory/sample inventory/my-cluster
```

Second, edit `inventory/my-cluster/hosts.ini` to match the system information gathered above. 

For example:

```ini
[master]
192.168.30.38
192.168.30.39
192.168.30.40

[node]
192.168.30.41
192.168.30.42

[k3s_cluster:children]
master
node
```

If multiple hosts are in the master group, the playbook will automatically set up k3s in [HA mode with etcd](https://rancher.com/docs/k3s/latest/en/installation/ha-embedded/).

This requires at least k3s version `1.19.1` however the version is configurable by using the `k3s_version` variable.

If needed, you can also edit `inventory/my-cluster/group_vars/all.yml` to match your environment.

### 🐍 Bootstrap Python
For most of it operations Ansible requires Python installed in the remote host, this is an issue as Flatcar does not include Python. Fortunately we can still use the parts of ansible that do not require Python to install pypy (a minimal python distribution) in the Flatcar nodes.

```bash
ansible-playbook bootstrap-python.yml -i inventory/my-cluster/hosts.ini
```

### ☸️ Create Cluster

Start provisioning of the cluster using the following command:

```bash
ansible-playbook site.yml -i inventory/my-cluster/hosts.ini
```

After deployment control plane will be accessible via virtual ip-address which is defined in inventory/group_vars/all.yml as `apiserver_endpoint`

### 🔁 Rerunning the site.yml playbook
Rerunning this playbook will have no effect in the cluster if no variables or template files are modified.

#### ✅ Operations that this playbook can perform in reruns after installation
* Joining new nodes/masters. Simply add them to the hosts.ini and rerun (⚠️ This operations causes the restart of the k3s daemon and it may produce downtime).
* Modifying the systemd service (including the process arguments) and k3s manifests. Edit them/the variable they use and rerun.
#### ❌ Operations that this playbook can NOT perform in reruns after installation
* Upgrading k3s. This is best done via the [Rancher’s system-upgrade-controller](https://rancher.com/docs/k3s/latest/en/upgrades/automated/).
* Removing nodes. This is best done manually or with an specialized tool. Removing a node from the inventory will just case that future runs of the playbook wodn't know of the node existance.

### 🔥 Remove k3s cluster
Be aware that the ability of removing the cluster has low priority in this project and it's highly advised to reinstall the flatcar hosts instead.

```bash
ansible-playbook reset.yml -i inventory/my-cluster/hosts.ini
```

>You should also reboot these nodes due to the VIP not being destroyed

## ⚙️ Kube Config

To copy your `kube config` locally so that you can access your **Kubernetes** cluster run:

```bash
scp debian@master_ip:~/.kube/config ~/.kube/config
```

### 🔨 Testing your cluster

See the commands [here](https://docs.technotim.live/posts/k3s-etcd-ansible/#testing-your-cluster).

### 🔷 Vagrant

You may want to kickstart your k3s cluster by using Vagrant to quickly build you all needed VMs with one command.
Head to the `vagrant` subfolder and type `vagrant up` to get your environment setup.
After the VMs have got build, deploy k3s using the Ansible playbook `site.yml` by the
`vagrant provision --provision-with ansible` command.

## Thanks 🤝

This repo is really standing on the shoulders of giants. To all those who have contributed.

Thanks to these repos for code and ideas:

* [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible)
* [geerlingguy/turing-pi-cluster](https://github.com/geerlingguy/turing-pi-cluster)
* [212850a/k3s-ansible](https://github.com/212850a/k3s-ansible) 
* [techno-tim/k3s-ansible](https://github.com/techno-tim/k3s-ansible)