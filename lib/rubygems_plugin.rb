require 'net/ntp'
require 'attempt'

Gem.pre_install do |installer|
  offset = 0
  default = 'pool.ntp.org'

  begin
    server = File.read("/etc/ntp.conf")[/^server\s([\p{Alnum}\.]*)/, 1] || default
  rescue Errno::ENOENT
    server = default
  end

  # TODO: Make this configurable as a flag to the install command.
  attempt(tries: 3, interval: 3) do
    puts "Checking for clock skew..."
    offset = Net::NTP.get(server, 'ntp', 5).offset.abs
  end

  # TODO: Make this configurable as a flag to the install command.
  if offset > 300
    msg = %Q{
Your clock appears to be skewed by 5 or more minutes. Gem installation attempts may fail.

Please consider running 'sudo ntpdate some.time.server' (Unix) or 'w32tm /resync' (Windows)
in order to get your computer's clock synced before proceeding.
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
