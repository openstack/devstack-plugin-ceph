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


# How to use

* Enable the plugin in ```localrc```:

    ```enable_plugin devstack-plugin-ceph git://git.openstack.org/openstack/devstack-plugin-ceph```

* Ceph is setup as the default storage backend for Cinder, Cinder Backup,
  Glance and Nova services. To disable Ceph disable as the storage backend
  for a service use the following setting in the ```localrc``` file,

    ```
    ENABLE_CEPH_$SERVICE=False
    ```

  where $SERVICE can be CINDER, C_BAK, GLANCE or NOVA corresponding to
  Cinder, Cinder Backup, Glance, and Nova services respectively.

* Ceph can be enabled as the storage backend for Manila with the following
  setting  in the ```localrc``` file,

    ```
    ENABLE_CEPH_MANILA=True
    ```

  Make sure that the manila plugin is enabled before devstack-plugin-ceph in
  the ```localrc``` file.

* Then run ```stack.sh``` and wait for the _magic_ to happen :)


# Known Issues / Limitations

* Rados Gateway with Keystone for Swift - works on Ubuntu only
* Tempest test failures when using RGW as swift endpoint
* Tempest fails due to verify-tempest-config erroring out, when using RGW as swift endpoint
  * Patch sent @ https://review.openstack.org/#/c/264179/


# TODOs

* Fix Rados Gateway with Keystone for Swift on Fedora
* Add support for Ceph Infernalis release
* Add support for distro specific ceph repos
* Add Manila support for non-Ubuntu systems

# Bugs

* https://bugs.launchpad.net/devstack-plugin-ceph

