## Description

The skew_guard gem is a rubygems plugin that checks for clock skew when you
install a gem. If significant clock skew is detected, then you will be warned
and prompted as to whether or not you wish to continue.

The --skew-max flag is now available for the `gem install` command, which you
can set as the maximum permissable amount of clock skew (in seconds) that will
not cause a warning. By default, this is 5 minutes.

## Installation

`gem install skew_guard`

## Adding the trusted cert
`gem cert --add <(curl -Ls https://raw.githubusercontent.com/djberg96/skew_guard/main/certs/djberg96_pub.pem)`

## Usage
  Once installed you can use the default of 5 minutes or pass the `--skew-max` argument
  as part of the install command. 

  ```
  # Let's pretend there's a clock skew over 2 minutes. You would see this:
  gem install --skew-max 120 some_gem

  Checking for clock skew...

  Your clock appears to be skewed by 120 or more seconds. Gem installation attempts may fail.

  Please consider running 'sudo ntpdate some.time.server' (Unix) or 'w32tm /resync' (Windows)
  in order to get your computer's clock synced before proceeding.

  Proceed with gem installation? (y/N):
  ```

## More Details
By default the plugin will try to read your ntp server out of the /etc/ntp.conf file. If
that cannot be found, then it will default to "pool.ntp.org".

There will be 3 attempts made to contact the ntp server, with 3 seconds between attempts.
So long as at least one attempt works there will not be an issue, otherwise you may see
an error.

The default skew max check is 300 seconds (5 minutes), based on various experiences with
both the Azure and AWS providers. Modify via the command line as you see fit.

## Known Bugs
None that I'm aware of. Please report bugs on the project page at:

https://github.com/djberg96/skew_guard

## License
Apache-2.0

## Copyright
(C) 2022 Daniel J. Berger, All Rights Reserved

## Warranty
This package is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantability and fitness for a particular purpose.

## Author
Daniel J. Berger
