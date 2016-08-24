# knife-bastion

[![Code Climate](https://codeclimate.com/github/eligible/knife-bastion/badges/gpa.svg)](https://codeclimate.com/github/eligible/knife-bastion)
[![Gem Version](https://badge.fury.io/rb/knife-bastion.svg)](https://badge.fury.io/rb/knife-bastion)

This plugin allows Knife to access Chef server over a secure SSH connection,
without exposing Chef server port to your VPN network.

## Installation

Add this line to your Chef repository's Gemfile:

```ruby
gem 'knife-bastion'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install knife-bastion

## Usage

Configure your bastion server in `.chef/knife.rb` (at the bottom):

```ruby
# ...
# your knife configurations goes here
# ...

# Bastion host SSH settings
knife[:bastion_host] = "bastion.mycorp.net"
knife[:bastion_user] = ENV["MYCORP_USER"] || ENV["CHEF_USER"] || ENV["USER"]

# If you have multiple networks, that require different MFA tokens, specify
# each network name here. (This configuration is referenced to clarify the
# token a user should employ.)
# knife[:bastion_network] = "mynet"

# By default, the proxy server is created on port 4443. You may configure the
# local bastion port here:
# knife[:bastion_local_port] = 4443

require "knife-bastion/activate"
```

Now, your workflow will look like this:

1. Run `knife bastion start` - this command will establish SSH connection to
   bastion box for 10 minutes, and create a SOCKS proxy on port `4443`, that
   will forward all Chef requests to Chef server via bastion box.
2. Use Chef to do your work.
3. At any time you can use `knife bastion status` - which will verify the proxy
   and make sure everything works as expected.
4. After you finished, run `knife bastion stop` to shutdown the connection
   and turn off the proxy. If you forget to do this, it will die automatically
   after 10 minutes.

Sometimes when you work on a big change, default timeout of 10 minutes is too short.
You can increase timeout with `--timeout` flag:

```
knife bastion start --timeout 1800
```

Maximum timeout is 3600 (1 hour) for security reasons. You can re-establish bastion
connection by executing `knife bastion start` (if the connection is currently active,
it will be forcibly closed.)

### Bastion troubleshooting

If something is not right, you need to ensure you have access to bastion box.
Try connecting to `bastion.mycorp.net` via SSH:

```bash
ssh ${MYCORP_USER-$USER}@bastion.mycorp.net
```

Check current bastion connection status (it will tell you if there is anything
wrong with your box):

```
knife bastion status
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Bug reports and pull requests are welcome on GitHub at https://github.com/eligible/knife-bastion.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
