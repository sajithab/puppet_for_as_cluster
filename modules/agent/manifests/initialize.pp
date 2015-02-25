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

# Initializing the deployment

define agent::initialize ($repo, $version, $service, $local_dir, $target, $owner,) {

  exec {
    "creating_target_for_${name}":
      path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      command => "mkdir -p ${target}";

    "creating_local_package_repo_for_${name}":
      path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/',
      unless  => "test -d ${local_dir}",
      command => "mkdir -p ${local_dir}";
  }

  file {
    "/${local_dir}/apache-stratos-${service}-${version}-bin.zip":
      ensure => present,
      source => ["puppet:///modules/agent/apache-stratos-${service}-${version}-bin.zip", "puppet:///packs/apache-stratos-${service}-${version}-bin.zip"],
      require   => Exec["creating_local_package_repo_for_${name}", "creating_target_for_${name}"];
  }

  exec {
    "extracting_stratos${service}-${version}.zip_for_${name}":
      path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      cwd       => $target,
      unless    => "test -d ${target}/apache-stratos-${service}-${version}/conf",
      command   => "unzip ${local_dir}/apache-stratos-${service}-${version}-bin.zip",
      logoutput => 'on_failure',
      creates   => "${target}/apache-stratos-${service}-${version}/repository",
      timeout   => 0,
      require   => File["/${local_dir}/apache-stratos-${service}-${version}-bin.zip"];

    "setting_permission_for_${name}":
      path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      cwd       => $target,
      command   => "chown -R ${owner}:${owner} ${target}/apache-stratos-${service}-${version} ;
                    chmod -R 755 ${target}/apache-stratos-${service}-${version}",
      logoutput => 'on_failure',
      timeout   => 0,
      require   => Exec["extracting_stratos${service}-${version}.zip_for_${name}"];

  }

  file { "/${target}/apache-stratos-${service}-${version}/lib":
    path         => "/${target}/apache-stratos-${service}-${version}/lib",
    ensure       => directory,
    require      => Exec["setting_permission_for_${name}"],
    source       => ["puppet:///modules/agent/${mb_type}"],
    sourceselect => all,
    recurse      => true,
  }


}
