set_unless[:nginx][:conf_dir] = "/etc/nginx"
set_unless[:apps] = [{ :name => "enki", :username => "site", :git_branch => "master"}]