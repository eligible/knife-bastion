require 'knife-bastion'

# Only activate socks proxy for Knife
if defined?(Chef::Application::Knife)
  require_relative 'chef_socks_proxy'
end
