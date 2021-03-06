require 'rspec/expectations'
require 'chefspec'
require 'compat_resource'
require 'chefspec/berkshelf'
require 'chef/application'
require_relative '../../libraries/path_helpers'
require_relative '../../libraries/platform_helpers'
require_relative '../../libraries/resource_helpers'
require_relative '../../libraries/restart_helpers'
require_relative '../../libraries/service_helpers'
require_relative '../../libraries/conf_helpers'

RSpec.configure do |config|
  config.extend(ChefSpec::Cacher)
  config.color = true
  config.formatter = 'documentation'

  # Specify the path for Chef Solo file cache path (default: nil)
  config.file_cache_path = './test/unit/.cache'

  # Specify the Chef log_level (default: :warn)
  config.log_level = :warn
end

def platform_package_matrix
  {
    'redhat' => {
      '7.1' => {
        splunk: 'https://download.splunk.com/products/splunk/releases/6.3.4/linux/splunk-6.3.4-cae2458f4aef-linux-2.6-x86_64.rpm',
        universal_forwarder: 'https://download.splunk.com/products/universalforwarder/releases/6.3.4/linux/splunkforwarder-6.3.4-cae2458f4aef-linux-2.6-x86_64.rpm'
      }
    },
    'ubuntu' => {
      '16.04' => {
        splunk: 'https://download.splunk.com/products/splunk/releases/6.3.4/linux/splunk-6.3.4-cae2458f4aef-linux-2.6-amd64.deb',
        universal_forwarder: 'https://download.splunk.com/products/universalforwarder/releases/6.3.4/linux/splunkforwarder-6.3.4-cae2458f4aef-linux-2.6-amd64.deb'
      }
    },
    'windows' => {
      '2012R2' => {
        splunk: 'https://download.splunk.com/products/splunk/releases/6.3.4/windows/splunk-6.3.4-cae2458f4aef-x64-release.msi',
        universal_forwarder: 'https://download.splunk.com/products/universalforwarder/releases/6.3.4/windows/splunkforwarder-6.3.4-cae2458f4aef-x64-release.msi'
      }
    },
    'suse' => { # Generic Linux
      '12.0' => {
        splunk: 'https://download.splunk.com/products/splunk/releases/6.3.4/linux/splunk-6.3.4-cae2458f4aef-Linux-x86_64.tgz',
        universal_forwarder: 'https://download.splunk.com/products/universalforwarder/releases/6.3.4/linux/splunkforwarder-6.3.4-cae2458f4aef-Linux-x86_64.tgz'
      }
    }
  }
end

def environment_combinations
  @env_per ||= [].tap do |array|
    platform_package_matrix.each do |platform, versions|
      versions.each do |version, packages|
        packages.each do |package, url|
          array << [platform, version, package, url]
        end
      end
    end
  end
end
