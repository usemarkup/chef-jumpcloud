%w(curl sudo bash openssl).each do |pkg|
  package pkg
end

raise 'Jumpcloud connect key is not set' if node['jumpcloud']['connect_key'].nil?

remote_file "#{Chef::Config[:file_cache_path]}/kickstart.sh" do
  source 'https://kickstart.jumpcloud.com/Kickstart'
  headers('x-connect-key' => node['jumpcloud']['connect_key'])
  mode '0755'
  action :create
  sensitive true
  notifies :run, 'execute[install_jumpcloud]', :delayed
end

file '/etc/jumpcloud_api.conf' do
  mode '0400'
  owner 'root'
  owner 'root'
  content "JUMPCLOUD_API_KEY=#{node['jumpcloud']['api_key']}"
  not_if { node['jumpcloud']['api_key'].nil? }
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
  # We must wait for Jumpcloud to complete its setup.. normally <15 seconds~
  execute 'waiting_for_jumpcloud_to_init' do
    command 'sleep 15'
    action :nothing
    live_stream true
    subscribes :run, 'execute[install_jumpcloud]', :immediately
  end

  service_provider = nil
  service_provider = if node['platform_version'].to_i > 6
                       Chef::Provider::Service::Systemd
                     end

  service 'jcagent' do
    provider service_provider if service_provider
    supports status: true, restart: true, enable: true, start: true
    action :nothing
    subscribes :stop, 'execute[install_jumpcloud]', :immediately
  end

  %w(/opt/jc/ca.crt /opt/jc/client.crt /opt/jc/client.key /opt/jc/jcagent.conf).each do |filename|
    file filename do
      action :nothing
      subscribes :delete, 'execute[install_jumpcloud]', :immediately
    end
  end
end
