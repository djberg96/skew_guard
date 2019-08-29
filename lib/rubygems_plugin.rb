require 'net/ntp'
require 'attempt'

Gem.pre_install do |installer|
  offset = 0

  if Gem.win_platform?
    server = 'pool.ntp.org' # TODO: Find better default?
  else
    server = IO.read("/etc/ntp.conf")[/^server\s([\p{Alnum}\.]*)/, 1] || 'pool.ntp.org'
  end

  attempt(tries: 3, interval: 3) do
    offset = Net::NTP.get(server, 'ntp', 5).offset.abs
  end

  if offset > 300
    msg = %Q{
Your clock appears to be skewed by 5 or more minutes. Gem installation attempts may fail.

Please consider running 'sudo ntpdate some.time.server' (Unix) or 'w32tm /resync' (Windows)
in order to get your computer's clock synced before proceeding.
}

    puts msg
    print "\nProceed with gem installation? (y/n): "

    case choice = $stdin.gets.chomp
      when /\Ay/i
      when /\An/i then next false
      else fail "cannot understand '#{choice}'"
    end
  else
    puts "No significant clock skew detected, proceeding..."
  end
end
