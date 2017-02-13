module CernerSplunk
  # Mixin Helper methods for Splunk Ingredient resources' providers
  module ProviderHelpers
    def changed?(*properties)
      converge_if_changed(*properties) do
      end
    end

    def change_ownership(path, desired_owner, desired_group = nil, options = {})
      path = Pathname.new(path)
      if platform_family?('windows')
        if options[:access]
          declare_resource(:directory, path.to_s) do
            rights options[:access], desired_owner, applies_to_self: true, applies_to_children: options[:inherit] 
            action :create
          end
        end

        require 'chef/win32/security'
        security_const = Chef::ReservedNames::Win32::Security
        securable_object = security_const::SecurableObject.new(path.to_s)

        securable_object.owner = desired_owner.is_a?(security_const::SID) ? desired_owner : security_const::SID.from_account(desired_owner)
        securable_object.group = desired_group.is_a?(security_const::SID) ? desired_group : security_const::SID.from_account(desired_group)
      else
        require 'fileutils'
        FileUtils.chown(desired_owner, desired_group, path.to_s)
      end
    end

    def deep_change_ownership(path, owner, group = nil)
      change_ownership(path, owner, group, access: :full_control, inherit: true)
      Pathname.glob(Pathname.new(path).join('**/*')).each { |sub_path| change_ownership(sub_path, owner, group) }
    end
  end
end
