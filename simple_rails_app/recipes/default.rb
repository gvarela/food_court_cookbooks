include_recipe "git"

node[:apps].each do |app|
  home_path = "/home/#{app[:username]}"
  repos_path = "#{home_path}/repos/#{app[:name]}.git"
  app_path = "#{home_path}/#{app[:name]}"
  
  # initialize bare git repo
  bash "create repo folder" do
    user app[:username]
    code "mkdir -p #{repos_path} && cd #{repos_path} && git init --bare"
    not_if { File.exists?(repos_path) }
  end
  
  template "#{repos_path}/hooks/post-receive" do
    path "#{repos_path}/hooks/post-receive"
    source "post-receive.erb"
    owner app[:username]
    group app[:group] || app[:username]    
    mode 0755
    variables(
      :app_path => app_path,
      :git_branch => app[:git_branch] || "master"
    )
    action :create
  end
    
  # set web app permissions
  bash "clone git repo" do
    user app[:username]
    code "cd #{home_path} && git clone #{repos_path} #{app[:name]}"
    not_if { File.exists?(app_path) }
  end
  
  template "#{node[:nginx][:conf_dir]}/sites-available/#{app[:name]}" do
    source "rails_app.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
      :root_dir => app_path,
      :server_name => app[:server]
    )
    if File.exists?("#{node[:nginx][:conf_dir]}/sites-enabled/#{app[:name]}")
      notifies :reload, resources(:service => "nginx"), :delayed
    end
    not_if { File.exists?("#{node[:nginx][:conf_dir]}/sites-enabled/#{app[:name]}") }
  end

  nginx_site app[:name]
end