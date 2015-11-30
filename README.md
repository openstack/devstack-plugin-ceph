Devstack Ceph Plugin
====================

# Overview

Devstack plugin to configure Ceph as the storage backend for openstack services

As part of ```stack.sh```:

* Installs Ceph (client and server) packages
* Creates a Ceph cluster for use with openstack services
* Configures Ceph as the storage backend for Cinder, Cinder Backup, Nova & Glance services
* Supports Ceph cluster running local or remote to openstack services

As part of ```unstack.sh``` | ```clean.sh```:

* Tears down the Ceph cluster and its related services

This plugin also gets used to configure Ceph as the storage backend for the upstream Ceph CI job named ```gate-tempest-dsvm-full-devstack-plugin-ceph```


# How to use

* Enable the plugin in ```localrc```:

    ```enable_plugin devstack-plugin-ceph git://git.openstack.org/openstack/devstack-plugin-ceph```

* Then run ```stack.sh``` and wait for the _magic_ to happen :)

# TODOs

* Configuring Rados Gateway with Keystone for Swift

# Bugs

* https://bugs.launchpad.net/devstack-plugin-ceph

