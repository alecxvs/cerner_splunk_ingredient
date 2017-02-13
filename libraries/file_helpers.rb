module CernerSplunk
  # Provider helper methods for platform-agnostic managing of files
  module FileHelpers
    def change_ownership(path, desired_owner, desired_group = nil, options = {})
      declare_resource(:file, path) do
        owner desired_owner
        group desired_group if desired_group
        rights options[:access], desired_owner, applies_to_self: true, applies_to_children: options[:inherit] if options[:access] && platform_family?('windows')
        action :create_if_missing
      end
        # require 'chef/win32/security'
        # win32 = Chef::ReservedNames::Win32
        # securable_object = win32::Security::SecurableObject.new(path)

        # securable_object.owner = owner.is_a?(win32::Security::SID) ? owner : win32::Security::SID.from_account(owner)
        # securable_object.group = group.is_a?(win32::Security::SID) ? group : win32::Security::SID.from_account(group)

        # descriptor = win32::Security.get_named_security_info(path)
        # real_descriptor, _, _, dacl, = win32::Security.make_absolute_sd descriptor
        # if options[:inherited]
        #   full_inheritance = win32::API::Security::OBJECT_INHERIT_ACE | win32::API::Security::CONTAINER_INHERIT_ACE
        #   access = win32::Security::ACE.access_allowed(sid[:owner], win32::API::Security::STANDARD_RIGHTS_ALL, full_inheritance)
        #   Chef::Log.warn(dacl.struct.to_s)
        #   Chef::Log.warn(access)
        #   dacl.push(access)
        #   # real_descriptor.
        # elsif !options[:skip_access]
        #   win32::Security.add_access_allowed_ace(acl, sid[:owner], win32::API::Security::STANDARD_RIGHTS_ALL)
        # end
        # win32::Security.set_named_security_info(path.to_s, :SE_FILE_OBJECT, sid)
      # else
      #   require 'fileutils'
      #   FileUtils.chown(owner, group, path.to_s)
      # end
    end

    def deep_change_ownership(path, owner, group = nil)
      change_ownership(path, owner, group, access: :full_control, inherit: true)
      Pathname.glob(Pathname.new(path).join('**/*')).each { |sub_path| change_ownership(sub_path, owner, group) }
    end

    # def self.add_aces_to_acl(existing_acl, *aces)
    #   combined_aces = aces.clone
    #   existing_acl.each do |acl_ace|
    #     next if aces.any? { |ace| ace.sid == acl_ace.sid }
    #     combined_aces << acl_ace
    #   end
    #   Chef::ReservedNames::Win32::Security::ACE.create(combined_aces)
    # end
  end
end
