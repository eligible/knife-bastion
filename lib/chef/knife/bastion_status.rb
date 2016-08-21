require_relative 'bastion_base'

class Chef
  class Knife
    class BastionStatus < BastionBase
      include Chef::Mixin::ShellOut

      banner "knife bastion status (options)"
      category "bastion"

      def print_tunnel_info(header, timeout: nil, pid: nil)
        ui.info <<-INFO
#{header}
  * Bastion host: #{ui.color "#{@bastion_user}@#{@bastion_host}", [:bold, :white]}
  *    Chef host: #{ui.color @chef_host, [:bold, :white]}
  *   Local port: #{ui.color @local_port.to_s, [:bold, :white]}
        INFO
        if timeout
          ui.info <<-INFO
  *      Timeout: #{ui.color timeout.to_s, [:bold, :white]} seconds
          INFO
        end
        if pid
          ui.info <<-INFO
  *    Proxy PID: #{ui.color pid.to_s, [:bold, :white]}
          INFO
        end
      end

      def run
        initialize_params

        # Retrieve proxy process PID. Raises an error if something is wrong
        proxy_pid = tunnel_pid(@local_port)
        print_tunnel_info("Found an esablished tunnel:", pid: proxy_pid)

        require 'socksify'
        TCPSocket::socks_server = "127.0.0.1"
        TCPSocket::socks_port   = @local_port

        # This line will raise an exception if tunnel is broken
        rest.get_rest("/policies")
        ui.info ui.color("OK:  ", :green) + "The tunnel is up and running"
      end
    end
  end
end
