# Activate socks proxy for Knife
if defined?(Chef::Application::Knife)
  require_relative 'chef_socks_proxy'
end

# Activate socks proxy for Berkshelf
if defined?(Berkshelf)
  require_relative 'berkshelf_socks_proxy'
end
