# Load socksify gem, required to make Chef work with SOCKS proxy
begin
  require 'socksify'
rescue LoadError
  puts HighLine.color("FATAL:", [:bold, :red]) + " Failed to load #{HighLine.color("socksify", [:bold, :magenta])} gem. Please run #{HighLine.color("bundle install", [:bold, :magenta])} to continue"
  # Hard exit to skip Chef exception reporting
  exit! 1
end

# Simple class, that delegates all the calls to the base client object, except
# for `request`. The latter is overwritten to first configure SOCKS proxy,
# and if connection fails - show warning about the bastion setup.
class BastionChefClientProxy < BasicObject
  NETWORK_ERRORS = [
    ::SocketError,
    ::Errno::ETIMEDOUT,
    ::Errno::ECONNRESET,
    ::Errno::ECONNREFUSED,
    ::Timeout::Error,
    ::OpenSSL::SSL::SSLError,
  ]

  def initialize(client)
    @client = client
  end

  def request(*args, &block)
    with_socks_proxy do
      @client.request(*args, &block)
    end
  end

  def method_missing(method, *args, &block)
    @client.send(method, *args, &block)
  end

  def with_socks_proxy
    old_socks_server, old_socks_port = ::TCPSocket::socks_server, ::TCPSocket::socks_port
    ::TCPSocket::socks_server, ::TCPSocket::socks_port = '127.0.0.1', ::Chef::Config[:knife][:bastion_local_port] || 4443
    yield
  rescue *NETWORK_ERRORS
    puts ::HighLine.color("WARNING:", [:bold, :red]) + " Failed to contact Chef server!"
    puts "You might need to start bastion connection with #{::HighLine.color("knife bastion start", [:bold, :magenta])} to access Chef."
    puts
    raise
  ensure
    ::TCPSocket::socks_server, ::TCPSocket::socks_port = old_socks_server, old_socks_port
  end
end

# Override `http_client` method in `Chef::HTTP` to return proxy object instead
# of normal client object.
Chef::HTTP.class_eval do
  alias_method :http_client_without_bastion, :http_client
  protected :http_client_without_bastion

  protected

  def http_client(*args)
    BastionChefClientProxy.new(http_client_without_bastion(*args))
  end
end
