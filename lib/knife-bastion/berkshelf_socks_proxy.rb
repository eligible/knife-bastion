require_relative 'base_socks_proxy'

# Override `ridley_connection` method in `Berkshelf` to enable Socks proxy
# for the connection.
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
