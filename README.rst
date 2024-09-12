Devstack Ceph Plugin
====================

.. image:: https://governance.openstack.org/tc/badges/devstack-plugin-ceph.svg
   :target: https://governance.openstack.org/tc/reference/tags/index.html

Overview
--------

Devstack plugin to configure Ceph as the storage backend for openstack
services

As part of ``stack.sh``:

-  Creates a Ceph cluster for use with openstack services using Ceph orchestrator
-  Configures Ceph as the storage backend for Cinder, Cinder Backup,
   Nova, Manila, and Glance services
-  (Optionally) Sets up & configures Rados gateway (aka rgw or radosgw)
   as a Swift endpoint with Keystone integration. Set ``ENABLE_CEPH_RGW=True``
   in your ``localrc``
-  Supports Ceph cluster running local or remote to openstack services

As part of ``unstack.sh`` \| ``clean.sh``:

-  Tears down the Ceph cluster and its related services

Usage
-----

-  To get started quickly, just enable the plugin in your
   ``local.conf``:

   ``enable_plugin devstack-plugin-ceph https://opendev.org/openstack/devstack-plugin-ceph``

Run ``stack.sh`` in your devstack tree and boom! You're good to go.

-  Ceph is setup as the default storage backend for Cinder, Cinder
   Backup, Glance, Manila and Nova services. You have the ability to control
   each of the enabled services with the following configuration in your
   ``local.conf``:

   ::

       ENABLE_CEPH_CINDER=True     # ceph backend for cinder
       ENABLE_CEPH_GLANCE=True     # store images in ceph
       ENABLE_CEPH_C_BAK=True      # backup volumes to ceph
       ENABLE_CEPH_NOVA=True       # allow nova to use ceph resources
       ENABLE_CEPH_MANILA=True     # allow manila to use CephFS as backend (Native CephFS or CephFS via NFS)

Change any of the above lines to ``False`` to disable that feature
specifically.

Manila's CephFS Native driver that supports native Ceph protocol is enabled by
default. To use CephFS NFS-Ganesha driver that supports NFS protocol add
the setting:

::

    MANILA_CEPH_DRIVER=cephfsnfs

If you'd like to use a standalone NFS Ganesha service in place of ceph orchestrator
deployed ``ceph-nfs`` service, set:

::

    CEPHADM_DEPLOY_NFS=False

Make sure that the manila plugin is enabled before devstack-plugin-ceph
in the ``local.conf`` file.

-  Then run ``stack.sh`` and wait for the *magic* to happen :)

Known Issues / Limitations
--------------------------

-  Rados Gateway with Keystone for Swift - works on Ubuntu only
-  Tempest test failures when using RGW as swift endpoint
-  Tempest fails due to verify-tempest-config erroring out, when using
   RGW as swift endpoint

Bugs
----

-  https://bugs.launchpad.net/devstack-plugin-ceph

