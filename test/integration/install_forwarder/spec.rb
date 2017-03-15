# frozen_string_literal: true
windows = os.windows?
splunk_path = windows ? 'c:\Program Files\SplunkUniversalForwarder' : '/opt/splunkforwarder'
splunk_command = windows ? "& \"#{splunk_path}\\bin\\splunk.exe\"" : "#{splunk_path}/bin/splunk"

describe package(windows ? 'UniversalForwarder' : 'splunkforwarder') do
  it { is_expected.to be_installed }
  its('version') { is_expected.to match(/6\.3\.4(\.0)?(-cae2458f4aef)?/) }
end

describe service(windows ? 'splunkforwarder' : 'splunk') do
  it { is_expected.to be_installed }
  it { is_expected.to be_running }
end

describe command("#{splunk_command} status") do
  its('exit_status') { is_expected.to eq 0 }
end

describe file(splunk_path) do
  it { is_expected.to be_directory }
  its('owner') { is_expected.to match(/splunkforwarder$/) } unless windows
end

describe file((Pathname.new(splunk_path) + 'etc/system/local/server.conf').to_s) do
  it { is_expected.to be_file }
  its('owner') { is_expected.to match(/splunkforwarder$/) } unless windows
  its('content') { is_expected.to match '[general]' }
  its('content') { is_expected.to match 'serverName = test-forwarder' }
  its('content') { is_expected.to match '[sslConfig]' }
  its('content') { is_expected.to match(/sslKeysfilePassword = .+/) }
end

unless windows
  describe file('/etc/init.d/splunk') do
    it { is_expected.to be_file }
    its('content') { is_expected.to match(/RETVAL=0\s+ulimit -n 3000/m) }
  end

  describe file("#{splunk_path}/restart_on_chef_client") do
    it { is_expected.not_to exist }
  end

  describe command('cat /proc/$(pgrep splunkd | sed -n 1p)/limits') do
    its('stdout') { is_expected.to match(/^Max open files \s+ \w+ \s+ 3000 \s+ files\s*$/m) }
  end
end
