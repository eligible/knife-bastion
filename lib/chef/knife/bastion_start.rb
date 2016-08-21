require_relative 'bastion_base'

class Chef
  class Knife
    class BastionStart < BastionBase
      option :timeout,
             long:        "--timeout SECONDS",
             description: "Sets the tunnel life time, in seconds (10 minutes by default)",
             default:     600,
             proc:        lambda { |s| s.to_i }

      deps do
        require 'shellwords'
      end

      banner "knife bastion start (options)"
      category "bastion"

      def initialize_params
        super

        @timeout = config[:timeout]
        @timeout = 600  if @timeout < 1    # timeout should be greater than 0
        @timeout = 3600 if @timeout > 3600 # timeout should be less than 1 hour
      end

      def run
        initialize_params

        # Check if proxy is already running and restart it
        kill_proxy_if_running

        print_tunnel_info("Creating a tunnel to Chef server:", timeout: @timeout)

        ui.info "Establishing connection to #{@bastion_host}"
        ui.warn "Please make sure to use your #{ui.color @bastion_network, [:bold, :magenta]} token" if @bastion_network

        start_proxy
      end

      def kill_proxy_if_running
        proxy_pid = tunnel_pid(@local_port, false)
        if proxy_pid
          ui.warn "Proxy on #{@local_port} is up and running. Restarting it"
          shell_out!("kill -9 '#{proxy_pid}'")
        end
      end

      def start_proxy
        # Not using shell_out! here because it disables tty via Process.setsid,
        # so it will not be possible to enter password/token for bastion host.
        system ssh_proxy_command(@timeout)

        if $?.exitstatus == 0
          ui.info ui.color("OK:  ", :green) + "Successfully started proxy on port #{@local_port}"
        else
          ui.fatal "Failed to start proxy"
        end
      end

      def ssh_proxy_command(timeout)
        cmd = [
          "/usr/bin/ssh",
          # go to background just before command execution
          "-f",
          # prevent reading from stdin
          "-n",
          # application-level port forwarding (SOCKS proxy)
          "-D", @local_port,
          # wait for all remote port forwards to be successfully established
          "-o", "ExitOnForwardFailure=yes",
          # Disable sharing of multiple connections
          "-o", "ControlPath=none",
          # SSH host to connect to
          "#{@bastion_user}@#{@bastion_host}",
          # Enforce tunnel timeout
          "sleep #{timeout}"
        ]
        Shellwords.join(cmd)
      end
    end
  end
end
