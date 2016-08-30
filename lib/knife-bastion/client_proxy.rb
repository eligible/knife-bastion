require 'socket'
require 'timeout'
require 'highline'
require 'openssl'

module KnifeBastion
  # Simple class, that delegates all the calls to the base client
  # object. The latter is overwritten to first configure SOCKS proxy,
  # and if connection fails - show warning about the bastion setup.
  class ClientProxy < BasicObject
    NETWORK_ERRORS = [
      ::SocketError,
      ::Errno::ETIMEDOUT,
      ::Errno::ECONNRESET,
      ::Errno::ECONNREFUSED,
      ::Timeout::Error,
      ::OpenSSL::SSL::SSLError,
    ].freeze

    # Initializes an instance of the generic client proxy which sends all the
    #   network traffic through the SOCKS proxy.
    # @param [Object] client the client object which communicates with the
    #   server over the network.
    # @param [Hash] options the configuration of the client proxy.
    # @option options [Integer] :local_port (4443) The local port of the SOCKS
    #   proxy.
    # @option options [Proc] :error_handler network errors handler.
    #   By default it prints out a message which explains that the error may
    #   occur becase the bastion proxy has not been started.
    def initialize(client, options = {})
      @client = client

      @local_port = options[:local_port] || 4443
      @network_errors_handler = options[:error_handler] || -> (_) {
        ::Kernel.puts ::HighLine.color("WARNING:", [:bold, :red]) + " Failed to contact server!"
        ::Kernel.puts "You might need to start bastion connection with #{::HighLine.color("knife bastion start", [:bold, :magenta])} to access server."
        ::Kernel.puts
        ::Kernel.raise
      }
    end

    # Wraps all original client calls into a with_socks_proxy method.
    def method_missing(method, *args, &block)
      with_socks_proxy do
        @client.send(method, *args, &block)
      end
    end

    # Routes all network connections through the bastion proxy.
    def with_socks_proxy
      old_socks_server, old_socks_port = ::TCPSocket::socks_server, ::TCPSocket::socks_port
      ::TCPSocket::socks_server, ::TCPSocket::socks_port = '127.0.0.1', @local_port
      yield
    rescue *NETWORK_ERRORS => e
      @network_errors_handler.call(e)
    ensure
      ::TCPSocket::socks_server, ::TCPSocket::socks_port = old_socks_server, old_socks_port
    end
  end
end
