# ----------------------------------------------------------------------------
#  Copyright 2005-2013 WSO2, Inc. http://www.wso2.org
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# ----------------------------------------------------------------------------
#

# appserver cartridge node
node /[0-9]{1,12}.(manager|worker).appserver/ inherits base {
  $docroot = "/mnt/${server_ip}/wso2as-5.2.1"
  require java	
  class {'agent':}
  class {'appserver':

        version            => '5.2.1',
        sub_cluster_domain => 'test',
	members            => undef,
	offset		   => 0,
        hazelcast_port     => 4000,
	config_db          => 'AS_CONFIG_DB',
        config_target_path => 'AS_CONFIG_PATH',
        maintenance_mode   => 'zero',
        depsync            => false,
        clustering         => CLUSTERING,
	cloud		   => true,
        owner              => 'root',
        group              => 'root',
        target             => "/mnt/${server_ip}"
  }

  Class['stratos_base'] -> Class['java'] -> Class['appserver']
}

node /as-mgt/ inherits base {

    notify { $name: 
      message => "On mgt node",
    }

  $docroot = "/mnt/${server_ip}/wso2as-5.2.1"
  class {'python_agent':}
  class {'appserver':

        version            => '5.2.1',
        sub_cluster_domain => 'mgt',
	members            => undef,
	offset		   => 0,
        hazelcast_port     => 4000,
	config_db          => 'AS_CONFIG_DB',
        config_target_path => 'AS_CONFIG_PATH',
        maintenance_mode   => 'zero',
        depsync            => false,
        clustering         => true,
	cloud		   => true,
        owner              => 'root',
        group              => 'root',
        target             => "/mnt/${server_ip}"
  }
  
  require stratos_base 
  require java	

  Class['stratos_base'] -> Class['java'] -> Class['appserver'] ~> Class['python_agent']
}

node /as-worker/ inherits base {

    notify { $name: 
      message => "On worker node",
    }

  $docroot = "/mnt/${server_ip}/wso2as-5.2.1"
  class {'python_agent':}
  class {'appserver':

        version            => '5.2.1',
        sub_cluster_domain => 'worker',
	members            => undef,
	offset		   => 0,
        hazelcast_port     => 4000,
	config_db          => 'AS_CONFIG_DB',
        config_target_path => 'AS_CONFIG_PATH',
        maintenance_mode   => 'zero',
        depsync            => false,
        clustering         => true,
	cloud		   => true,
        owner              => 'root',
        group              => 'root',
        target             => "/mnt/${server_ip}"
  }
  
  require stratos_base 
  require java	

  Class['stratos_base'] -> Class['java'] -> Class['appserver'] ~> Class['python_agent']
}
