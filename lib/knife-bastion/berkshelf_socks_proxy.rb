require_relative 'base_socks_proxy'

# Override `http_client` method in `Chef::HTTP` to return proxy object instead
# of normal client object.
Berkshelf.module_eval do
  class << self
    alias_method :ridley_connection_without_bastion, :ridley_connection

    def ridley_connection(*args, &block)
      options = {
        local_port: ::ChefConfig::Config[:knife][:bastion_local_port],
        server_type: 'Chef',
      }
      proxy = ::KnifeBastion::ClientProxy.new(Berkshelf, options)
      proxy.ridley_connection_without_bastion(*args, &block)
    end
  end
end
