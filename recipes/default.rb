%w(curl sudo bash openssl).each do |pkg|
  package pkg
end

raise 'Jumpcloud API key is not set' if node['jumpcloud']['connect_key'].nil?

remote_file "#{Chef::Config[:file_cache_path]}/kickstart.sh" do
  source 'https://kickstart.jumpcloud.com/Kickstart'
  headers('x-connect-key' => node['jumpcloud']['connect_key'])
  mode 0755
  action :create
  sensitive true
  notifies :run, 'execute[install_jumpcloud]', :delayed
end

execute 'install_jumpcloud' do
  command "#{Chef::Config[:file_cache_path]}/kickstart.sh"
  timeout 120
  action :nothing
  not_if { ::File.exist?('/opt/jc/bin/jumpcloud-agent') }
  creates '/opt/jc'
end

# https://support.jumpcloud.com/customer/portal/articles/2399081-deploying-the-jumpcloud-agent-using-a-template-or-system-image
# If using the chef to provision an image its likely you want to enable this
if node['jumpcloud']['prepare_for_image']
  service_provider = nil
  service_provider = if node['platform_version'].to_i > 6
                       Chef::Provider::Service::Systemd
                     end

  service 'jcagent' do
    provider service_provider if service_provider
    supports status: true, restart: true, enable: true, start: true
    action :nothing
    subscribes :stop, 'execute[install_jumpcloud]', :delayed
  end

  %w(/opt/jc/ca.crt /opt/jc/client.crt /opt/jc/client.key /opt/jc/jcagent.conf).each do |filename|
    file filename do
      action :nothing
      subscribes :delete, 'execute[install_jumpcloud]', :delayed
    end
  end
end
