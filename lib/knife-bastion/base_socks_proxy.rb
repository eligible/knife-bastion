require_relative 'client_proxy'

# Load socksify gem, required to make Chef work with SOCKS proxy
begin
  require 'socksify'
rescue LoadError
  puts HighLine.color("FATAL:", [:bold, :red]) + " Failed to load #{HighLine.color("socksify", [:bold, :magenta])} gem. Please run #{HighLine.color("bundle install", [:bold, :magenta])} to continue"
  # Hard exit to skip Chef exception reporting
  exit! 1
end
