module Knife
  module Bastion
    # Simple class, that delegates all the calls to the base client object, except
    # for `request`. The latter is overwritten to first configure SOCKS proxy,
    # and if connection fails - show warning about the bastion setup.
    class ClientProxy < BasicObject
      NETWORK_ERRORS = [
        ::SocketError,
        ::Errno::ETIMEDOUT,
        ::Errno::ECONNRESET,
        ::Errno::ECONNREFUSED,
        ::Timeout::Error,
        ::OpenSSL::SSL::SSLError,
      ]

      attr_reader :local_port

      def initialize(client, options = {})
        @local_port = options[:local_port] || 4443
        @client = client
      end

      def method_missing(method, *args, &block)
        with_socks_proxy do
          @client.send(method, *args, &block)
        end
      end

      def with_socks_proxy
        old_socks_server, old_socks_port = ::TCPSocket::socks_server, ::TCPSocket::socks_port
        ::TCPSocket::socks_server, ::TCPSocket::socks_port = '127.0.0.1', local_port
        yield
      rescue *NETWORK_ERRORS
        network_errors_handler
      ensure
        ::TCPSocket::socks_server, ::TCPSocket::socks_port = old_socks_server, old_socks_port
      end

      def network_errors_handler
        puts ::HighLine.color("WARNING:", [:bold, :red]) + " Failed to contact server!"
        puts "You might need to start bastion connection with #{::HighLine.color("knife bastion start", [:bold, :magenta])} to access server."
        puts
        raise
      end
    end
  end
end
