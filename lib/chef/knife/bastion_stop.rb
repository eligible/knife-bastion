require_relative 'bastion_base'

class Chef
  class Knife
    class BastionStop < BastionBase
      include Chef::Mixin::ShellOut

      banner "knife bastion stop (options)"
      category "bastion"

      def run
        initialize_params

        # Retrieve proxy process PID. Raises an error if something is wrong
        pid = tunnel_pid(@local_port)

        shell_out!("kill -9 '#{pid}'")

        ui.info ui.color("OK:  ", :green) + "Tunnel closed, you're safe now"
      end
    end
  end
end
