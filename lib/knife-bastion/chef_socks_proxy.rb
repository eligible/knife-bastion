require_relative 'base_socks_proxy'

# Override `http_client` method in `Chef::HTTP` to return proxy object instead
# of normal client object.
Chef::HTTP.class_eval do
  alias_method :http_client_without_bastion, :http_client
  protected :http_client_without_bastion

  protected

  def http_client(*args)
    client = http_client_without_bastion(*args)
    options = {
      local_port: ::Chef::Config[:knife][:bastion_local_port],
      error_handler: -> (_) {
        puts ::HighLine.color("WARNING:", [:bold, :red]) + " Failed to contact Chef server!"
        puts "You might need to start bastion connection with #{::HighLine.color("knife bastion start", [:bold, :magenta])} to access Chef."
        puts
        raise
      }
    }
    KnifeBastion::ClientProxy.new(client, options)
  end
end
