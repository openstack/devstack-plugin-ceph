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

  _Note: Ceph can be disabled as the storage backend for a service with the
  following setting in the ```localrc``` file,_

    ```
    ENABLE_CEPH_$SERVICE=False
    ```

  _where $SERVICE can be CINDER, C_BAK, GLANCE, or NOVA corresponding to
  Cinder, Cinder Backup, Glance, and Nova services respectively._

* Then run ```stack.sh``` and wait for the _magic_ to happen :)


# TODOs

* Configuring Rados Gateway with Keystone for Swift
* Add support for Ceph Infernalis release
* Add support for distro specific ceph repos

# Bugs

* https://bugs.launchpad.net/devstack-plugin-ceph

