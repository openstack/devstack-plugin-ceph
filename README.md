Team and repository tags
========================

[![Team and repository tags](http://governance.openstack.org/badges/devstack-plugin-ceph.svg)](http://governance.openstack.org/reference/tags/index.html)

Devstack Ceph Plugin
====================

# Overview

Devstack plugin to configure Ceph as the storage backend for openstack services

As part of ```stack.sh```:

* Installs Ceph (client and server) packages
* Creates a Ceph cluster for use with openstack services
* Configures Ceph as the storage backend for Cinder, Cinder Backup, Nova,
  Manila (not by default), and Glance services
* (Optionally) Sets up & configures Rados gateway (aka rgw or radosgw) as a Swift endpoint with Keystone integration
  * Set ```ENABLE_CEPH_RGW=True``` in your ```localrc```
* Supports Ceph cluster running local or remote to openstack services

As part of ```unstack.sh``` | ```clean.sh```:

* Tears down the Ceph cluster and its related services

This plugin also gets used to configure Ceph as the storage backend for the upstream Ceph CI job named ```gate-tempest-dsvm-full-devstack-plugin-ceph```


# Usage

* To get started quickly, just enable the plugin in your ```local.conf```:

    ```enable_plugin devstack-plugin-ceph git://git.openstack.org/openstack/devstack-plugin-ceph```

  Run ```stack.sh``` in your devstack tree and boom!  You're good to go.

* Ceph is setup as the default storage backend for Cinder, Cinder Backup,
  Glance and Nova services.  You have the ability to control each of the
  enabled services with the following configuration in your ```local.conf```:

    ```
    ENABLE_CEPH_CINDER=True     # ceph backend for cinder
    ENABLE_CEPH_GLANCE=True     # store images in ceph
    ENABLE_CEPH_C_BAK=True      # backup volumes to ceph
    ENABLE_CEPH_NOVA=True       # allow nova to use ceph resources
    ```

  Change any of the above lines to ```False``` to disable that feature
  specifically.

* Ceph can be enabled as the storage backend for Manila with the following
  setting in your ```local.conf```:

    ```
    ENABLE_CEPH_MANILA=True
    ```

  CephFS Native driver that supports native Ceph protocol is used by default.
  To use CephFS NFS-Ganesha driver that supports NFS protocol add the setting:

    ```
    MANILA_CEPH_DRIVER=cephfsnfs
    ```

  Make sure that the manila plugin is enabled before devstack-plugin-ceph in
  the ```local.conf``` file.

* Then run ```stack.sh``` and wait for the _magic_ to happen :)


# Known Issues / Limitations

* Rados Gateway with Keystone for Swift - works on Ubuntu only
* Tempest test failures when using RGW as swift endpoint
* Tempest fails due to verify-tempest-config erroring out, when using RGW as swift endpoint
  * Patch sent @ https://review.openstack.org/#/c/264179/
* Manila with CephFS - for Ubuntu, support only for trusty and xenial

# TODOs

* Fix Rados Gateway with Keystone for Swift on Fedora

# Bugs

* https://bugs.launchpad.net/devstack-plugin-ceph
