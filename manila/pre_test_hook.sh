#!/bin/bash -xe
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# This script is executed inside pre_test_hook function in devstack gate.

# Import devstack function 'trueorfalse'.
source $BASE/new/devstack/functions

# === Handle script arguments ===
# Handle script arguments as detailed here in the manila CI job template,
# https://github.com/openstack-infra/project-config/commit/6ae99cee70a33d6cc312a7f9a83aa6db8b39ce21

# First argument specifies the type of share driver -- whether the driver
# handles or does not handle share servers -- to be configured. It is a boolean
# value, 'True' for driver that handles share servers, and 'False' for driver
# that does not.
MANILA_DHSS=$1
MANILA_DHSS=$(trueorfalse False MANILA_DHSS)

# Second argument specifies the type of cephfs driver to be set up. Currently,
# 'cephfsnative' is the only option.
MANILA_CEPH_DRIVER=$2
MANILA_CEPH_DRIVER=${MANILA_CEPH_DRIVER:-cephfsnative}

# Third argument specifies the type of backend configuration. It can either be
# 'singlebackend' or 'multiplebackend'.
MANILA_BACKEND_TYPE=$3
MANILA_BACKEND_TYPE=${MANILA_BACKEND_TYPE:-singlebackend}

localconf=$BASE/new/devstack/local.conf

echo "[[local|localrc]]" >> $localconf
if [[ $MANILA_BACKEND_TYPE == 'multibackend' ]]; then
    echo "MANILA_MULTI_BACKEND=True" >> $localconf
elif [[ $MANILA_BACKEND_TYPE == 'singlebackend' ]]; then
    echo "MANILA_MULTI_BACKEND=False" >> $localconf
fi

echo "DEVSTACK_GATE_TEMPEST_ALLOW_TENANT_ISOLATION=1" >> $localconf
echo "API_RATE_LIMIT=False" >> $localconf
echo "MANILA_USE_DOWNGRADE_MIGRATIONS=True" >> $localconf


# NOTE(rraja): Enable when need arises, for example, when the CI does scenario
# testing.
echo "MANILA_SERVICE_IMAGE_ENABLED=False" >> $localconf

# Enable isolated metadata in Neutron because Tempest creates isolated
# networks and created VMs in scenario tests don't have access to Nova Metadata
# service. This leads to unavailability of created VMs in scenario tests.
echo 'ENABLE_ISOLATED_METADATA=True' >> $localconf

# Go to Tempest dir and checkout stable commit to avoid possible
# incompatibilities for plugin stored in Manila repo.
cd $BASE/new/tempest

source $BASE/new/manila/contrib/ci/common.sh

# Print current Tempest status.
git status
