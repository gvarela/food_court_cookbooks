include_recipe "git"

template "#{node[:nginx][:conf_dir]}/sites-available/vagrant" do
  source "rails_app.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    :root_dir => '/vagrant',
    :server_name => '_'
  )
  if File.exists?("#{node[:nginx][:conf_dir]}/sites-enabled/vagrant")
    notifies :restart, resources(:service => "nginx"), :delayed
  end
  not_if { File.exists?("#{node[:nginx][:conf_dir]}/sites-enabled/vagrant") }
end

nginx_site 'vagrant'
