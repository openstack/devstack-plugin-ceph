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
    else
        install_ceph_remote
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
        fi
    fi
fi

if [[ "$1" == "unstack" ]]; then
    if [ "$REMOTE_CEPH" = "True" ]; then
        cleanup_ceph_remote
    else
        stop_ceph
        cleanup_ceph_embedded
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
