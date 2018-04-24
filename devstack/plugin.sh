# ceph.sh - DevStack extras script to install Ceph

if [[ "$1" == "source" ]]; then
    # Initial source
    source $TOP_DIR/lib/ceph
elif [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
    if [[ "$ENABLE_CEPH_RGW" = "True" ]] && (is_service_enabled swift); then
        die $LINENO \
        "You cannot activate both Swift and Ceph Rados Gateway, \
        please disable Swift or set ENABLE_CEPH_RGW=False"
    fi
    echo_summary "Installing Ceph"
    check_os_support_ceph
    if [ "$REMOTE_CEPH" = "False" ]; then
        if [ "$CEPH_CONTAINERIZED" = "True" ]; then
            echo_summary "Configuring and initializing Ceph"
            deploy_containerized_ceph
        else
            install_ceph
            echo_summary "Configuring Ceph"
            configure_ceph
            # NOTE (leseb): we do everything here
            # because we need to have Ceph started before the main
            # OpenStack components.
            # Ceph OSD must start here otherwise we can't upload any images.
            echo_summary "Initializing Ceph"
            init_ceph
            start_ceph
        fi
    else
        install_ceph_remote
    fi
elif [[ "$1" == "stack" && "$2" == "install" ]]; then
    # FIXME(melwitt): This is a hack to get around a namespacing issue with
    # Paste and PasteDeploy. For stable/queens, we use the Pike UCA packages
    # and the Ceph packages in the Pike UCA are pulling in python-paste and
    # python-pastedeploy packages. The python-pastedeploy package satisfies the
    # upper-constraints but python-paste does not, so devstack pip installs a
    # newer version of it, while python-pastedeploy remains. The mismatch
    # between the install path of paste and paste.deploy causes Keystone to
    # fail to start, with "ImportError: cannot import name deploy."
    if [[ "$TARGET_BRANCH" == stable/queens ]]; then
        pip_install -U --force PasteDeploy
    fi
elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
    if is_ceph_enabled_for_service glance; then
        echo_summary "Configuring Glance for Ceph"
        configure_ceph_glance
    fi
    if is_ceph_enabled_for_service nova; then
        echo_summary "Configuring Nova for Ceph"
        configure_ceph_nova
    fi
    if is_ceph_enabled_for_service cinder; then
        echo_summary "Configuring Cinder for Ceph"
        configure_ceph_cinder
    fi
    if is_ceph_enabled_for_service cinder || \
    is_ceph_enabled_for_service nova; then
        # NOTE (leseb): the part below is a requirement
        # to attach Ceph block devices
        echo_summary "Configuring libvirt secret"
        import_libvirt_secret_ceph
    fi
    if is_ceph_enabled_for_service manila; then
        echo_summary "Configuring Manila for Ceph"
        configure_ceph_manila
    fi

    if [ "$REMOTE_CEPH" = "False" ]; then
        if is_ceph_enabled_for_service glance; then
            echo_summary "Configuring Glance for Ceph"
            configure_ceph_embedded_glance
        fi
        if is_ceph_enabled_for_service nova; then
            echo_summary "Configuring Nova for Ceph"
            configure_ceph_embedded_nova
        fi
        if is_ceph_enabled_for_service cinder; then
            echo_summary "Configuring Cinder for Ceph"
            configure_ceph_embedded_cinder
        fi
        if is_ceph_enabled_for_service manila; then
            echo_summary "Configuring Manila for Ceph"
            configure_ceph_embedded_manila
        fi
        if [ "$ENABLE_CEPH_RGW" = "True" ]; then
            echo_summary "Configuring Rados Gateway with Keystone for Swift"
            configure_ceph_embedded_rgw
            if [ "$CEPH_CONTAINERIZED" = "False" ]; then
                start_ceph_embedded_rgw
            else
                _configure_ceph_rgw_container
            fi
        fi
    fi
elif [[ "$1" == "stack" && "$2" == "test-config" ]]; then
    if is_service_enabled tempest; then
        iniset $TEMPEST_CONFIG compute-feature-enabled swap_volume False

        # This is only being set because the tempest test
        # test_shelve_unshelve_server fails with an
        # "After unshelve, shelved image is not deleted"
        # failure.  Re-enable this feature when that test is fixed.
        # https://review.openstack.org/#/c/471352/
        iniset $TEMPEST_CONFIG compute-feature-enabled shelve False
    fi
fi



if [[ "$1" == "unstack" ]]; then
    if [ "$CEPH_CONTAINERIZED" = "False" ]; then
        if [ "$REMOTE_CEPH" = "True" ]; then
            cleanup_ceph_remote
        else
            stop_ceph
            cleanup_ceph_embedded
        fi
    else
        cleanup_containerized_ceph
    fi
    cleanup_ceph_general
fi

if [[ "$1" == "clean" ]]; then
    if [ "$REMOTE_CEPH" = "True" ]; then
        cleanup_ceph_remote
    else
        cleanup_ceph_embedded
    fi
    cleanup_ceph_general
fi
