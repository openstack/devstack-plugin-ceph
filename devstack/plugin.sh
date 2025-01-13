# cephadm.sh - DevStack extras script to install Ceph
if [[ "$1" == "source" ]]; then
    # Initial source
    source $TOP_DIR/lib/cephadm
elif [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
    if [[ "$ENABLE_CEPH_RGW" = "True" ]] && (is_service_enabled swift); then
        die $LINENO \
        "You cannot activate both Swift and Ceph Rados Gateway, \
        please disable Swift or set ENABLE_CEPH_RGW=False"
    fi
    echo_summary "[cephadm] Configuring system services ceph"
    pre_install_ceph
elif [[ "$1" == "stack" && "$2" == "install" ]]; then
    if [[ "$REMOTE_CEPH" = "False" ]]; then
        # Perform installation of service source
        echo_summary "[cephadm] Installing ceph"
        install_ceph
        set_memory_config
        set_min_client_version
    else
        echo "[CEPHADM] Remote Ceph: Skipping install"
        get_cephadm
    fi
elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
    echo_summary "[cephadm] Configuring additional Ceph services"
    configure_ceph
    if [[ "$MDS_LOGS" == "True" ]]; then
        enable_verbose_mds_logging
    fi
elif [[ "$1" == "stack" && "$2" == "test-config" ]]; then
    if is_service_enabled tempest; then
        iniset $TEMPEST_CONFIG compute-feature-enabled swap_volume False
        iniset $TEMPEST_CONFIG compute-feature-enabled shelve True
        iniset $TEMPEST_CONFIG volume-feature-enabled extend_attached_volume True
        iniset $TEMPEST_CONFIG volume-feature-enabled volume_revert True
    fi
elif [[ "$1" == "unstack" || "$1" == "clean" ]]; then
    cleanup_ceph
fi
