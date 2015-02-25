# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

class agent(
  $version                = '4.0.0-wso2v1',
  $owner                  = 'root',
  $group                  = 'root',
  $target                 = "/mnt/${server_ip}",
  $type                   = 'default',
  $enable_artifact_update = true,
  $auto_commit            = false,
  $auto_checkout          = true,
){

  $deployment_code = 'cartridge-agent'
  $carbon_version  = $version
  $service_code    = 'cartridge-agent'
  $carbon_home     = "${target}/apache-stratos-${service_code}-${carbon_version}"

  tag($service_code)

  $service_templates = [
    'bin/stratos.sh',
    'bin/ciphertool.sh',
    'conf/jndi.properties',
    'conf/log4j.properties',   
    'conf/cipher-text.properties',   
    'conf/secret-conf.properties',   
    'extensions/clean.sh',
    'extensions/instance-activated.sh',
    'extensions/instance-started.sh',
    'extensions/start-servers.sh',
    'extensions/artifacts-copy.sh',
    'extensions/artifacts-updated.sh',
    'extensions/complete-tenant.sh',
    'extensions/complete-topology.sh',
    'extensions/member-activated.sh',
    'extensions/member-suspended.sh',
    'extensions/member-terminated.sh',
    'extensions/mount-volumes.sh',
    'extensions/subscription-domain-added.sh',
    'extensions/subscription-domain-removed.sh',
    ]

  agent::initialize { $deployment_code:
    repo      => $package_repo,
    version   => $carbon_version,
    service   => $service_code,
    local_dir => $local_package_dir,
    target    => $target,
    owner     => $owner,
  }

  exec { 'copy launch-params to carbon_home':
    path    => '/bin/',
    command => "mkdir -p ${carbon_home}/payload; cp /tmp/payload/launch-params ${carbon_home}/payload/launch-params",
    require => Agent::Initialize[$deployment_code];
  }

  agent::push_templates {
    $service_templates:
      target    => $carbon_home,
      require   => Agent::Initialize[$deployment_code];
  }

  agent::start { $deployment_code:
    owner   => $owner,
    target  => $carbon_home,
    require => [
      Exec['copy launch-params to carbon_home'],
      Agent::Push_templates[$service_templates],
    ];
  }
}
