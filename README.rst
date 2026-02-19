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

Setup With Rados Gateway
------------------------

To setup Ceph with Rados Gateway and configure it as a Swift endpoint, you will need to enable following setting in your ``local.conf`` in addition to the settings mentioned in the previous section:

::

    ENABLE_CEPH_RGW=True

For a full example, please see file ``./examples/ceph-with-rgw-local.conf`` in this repository.

Test With Older Ceph Releases
-----------------------------

You can build devstack with older versions of ceph releases. Change the version of ceph release by overriding variable ``CONTAINER_IMAGE`` in your configuration file.

Supported releases are following:

::

    # Change Ceph Version by changing tag in CONTAINER_IMAGE.
    # Supported versions are:
    #   reef: quay.io/ceph/ceph:v18
    #   squid: quay.io/ceph/ceph:v19
    #   tentacle: quay.io/ceph/ceph:v20
    CONTAINER_IMAGE=quay.io/ceph/ceph:v20

Known Issues / Limitations
--------------------------

-  Rados Gateway with Keystone for Swift - works on Ubuntu only
-  Tempest test failures when using RGW as swift endpoint
-  Tempest fails due to verify-tempest-config erroring out, when using
   RGW as swift endpoint
-  Ceph requires passwordless SSH access to the ``root`` user on the machine.
   Adding ``PermitRootLogin prohibit-password`` to the sshd_config is
   sufficient.

Bugs
----

-  https://bugs.launchpad.net/devstack-plugin-ceph

