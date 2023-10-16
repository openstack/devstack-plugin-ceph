# ceph.sh - DevStack extras script to install Ceph

if [[ "$1" == "source" ]]; then
    # Initial source
    if [[ "$CEPHADM_DEPLOY" = "True" ]]; then
        source $TOP_DIR/lib/cephadm
    else
        source $TOP_DIR/lib/ceph
    fi
elif [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
    if [[ "$ENABLE_CEPH_RGW" = "True" ]] && (is_service_enabled swift); then
        die $LINENO \
        "You cannot activate both Swift and Ceph Rados Gateway, \
        please disable Swift or set ENABLE_CEPH_RGW=False"
    fi
    if [[ "$CEPHADM_DEPLOY" = "True" ]]; then
        # Set up system services
        echo_summary "[cephadm] Configuring system services ceph"
        pre_install_ceph
    else
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
                start_ceph
            fi
        else
            install_ceph_remote
        fi
    fi
elif [[ "$1" == "stack" && "$2" == "install" ]]; then
    if [[ "$CEPHADM_DEPLOY" = "True" && "$REMOTE_CEPH" = "False" ]]; then
        # Perform installation of service source
        echo_summary "[cephadm] Installing ceph"
        install_ceph
        set_min_client_version
    elif [[ "$CEPHADM_DEPLOY" = "True" && "$REMOTE_CEPH" = "True" ]]; then
        echo "[CEPHADM] Remote Ceph: Skipping install"
        get_cephadm
    else
        # FIXME(melwitt): This is a hack to get around a namespacing issue with
        # Paste and PasteDeploy. For stable/queens, we use the Pike UCA packages
        # and the Ceph packages in the Pike UCA are pulling in python-paste and
        # python-pastedeploy packages. The python-pastedeploy package satisfies the
        # upper-constraints but python-paste does not, so devstack pip installs a
        # newer version of it, while python-pastedeploy remains. The mismatch
        # between the install path of paste and paste.deploy causes Keystone to
        # fail to start, with "ImportError: cannot import name deploy."
        pip_install -U --force PasteDeploy
        install_package python-is-python3
    fi
elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
    if [[ "$CEPHADM_DEPLOY" = "True" ]]; then
        # Configure after the other layer 1 and 2 services have been configured
        echo_summary "[cephadm] Configuring additional Ceph services"
        configure_ceph
    else
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
        if is_ceph_enabled_for_service nova; then
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
    fi
elif [[ "$1" == "stack" && "$2" == "test-config" ]]; then
    if is_service_enabled tempest; then
        iniset $TEMPEST_CONFIG compute-feature-enabled swap_volume False

        # Only enable shelve testing for branches which have the fix for
        # nova bug 1653953.
        if [[ "$TARGET_BRANCH" =~ stable/(ocata|pike) ]]; then
            iniset $TEMPEST_CONFIG compute-feature-enabled shelve False
        else
            iniset $TEMPEST_CONFIG compute-feature-enabled shelve True
        fi
        # Attached volume extend support for rbd was introduced in Stein by
        # I5698e451861828a8b1240d046d1610d8d37ca5a2
        if [[ "$TARGET_BRANCH" =~ stable/(ocata|pike|queens|rocky) ]]; then
            iniset $TEMPEST_CONFIG volume-feature-enabled extend_attached_volume False
        else
            iniset $TEMPEST_CONFIG volume-feature-enabled extend_attached_volume True
        fi
        # Volume revert to snapshot support for rbd was introduced in Ussuri by
        # If8a5eb3a03e18f9043ff29f7648234c9b46376a0
        if [[ "$TARGET_BRANCH" =~ stable/(ocata|pike|queens|rocky|stein|train) ]]; then
            iniset $TEMPEST_CONFIG volume-feature-enabled volume_revert False
        else
            iniset $TEMPEST_CONFIG volume-feature-enabled volume_revert True
        fi
    fi
fi



if [[ "$1" == "unstack" ]]; then
    if [[ "$CEPHADM_DEPLOY" = "True" ]]; then
        cleanup_ceph
    else
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
fi

if [[ "$1" == "clean" ]]; then
    if [[ "$CEPHADM_DEPLOY" = "True" ]]; then
        cleanup_ceph
    else
        if [ "$REMOTE_CEPH" = "True" ]; then
            cleanup_ceph_remote
        else
            cleanup_ceph_embedded
        fi
        cleanup_ceph_general
    fi
fi
