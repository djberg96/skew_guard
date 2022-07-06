require 'net/ntp'
require 'attempt'
require 'rubygems/commands/install_command'

class Gem::Commands::InstallCommand
  alias orig_init initialize

  def initialize
    orig_init
    add_option('--skew-max SECONDS', 'Set the maximum clock skew in seconds') do |max, options|
      options[:skew_max] = max
    end
  end
end

Gem.pre_install do |installer|
  cmd = Gem::CommandManager.instance[:install]
  offset = 0
  default = 'pool.ntp.org'

  begin
    server = File.read("/etc/ntp.conf")[/^server\s([\p{Alnum}\.]*)/, 1] || default
  rescue Errno::ENOENT
    server = default
  end

  # We'll give it 3 attempts, at 3 seconds between each attempt.
  attempt(tries: 3, interval: 3) do
    puts "Checking for clock skew..."
    offset = Net::NTP.get(server, 'ntp', 5).offset.abs
  end

  # Default to 5 minutes
  cmd.options[:skew_max] ||= 300
  puts "Maximum clock skew set to #{cmd.options[:skew_max]}..."

  if offset > cmd.options[:skew_max].to_i
    msg = %Q{
Your clock appears to be skewed by #{skew_max} or more minutes. Gem installation attempts may fail.

Please consider running 'sudo ntpdate some.time.server' (Unix) or 'w32tm /resync' (Windows)
in order to get your system's clock synced before proceeding.
}

    puts msg
    print "\nProceed with gem installation? (y/N): "

    case choice = $stdin.gets.chomp
      when /\Ay/i
      when /\An|^$/i then next false
      else fail "cannot understand '#{choice}'"
    end
  else
    puts "No significant clock skew detected, proceeding..."
  end
end
