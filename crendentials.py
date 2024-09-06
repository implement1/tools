#!/usr/bin/env python

"""Two factor utility to generate one-time passwords or QR codes (in the
terminal).  Supports looking up <host> names in .netrc.  Just put your OTP
secret in the `account` field in .netrc.  For instance,

`machine my.nsone.net login IGNORED password IGNORED account MY_OTP_SECRET`


Usage: 2factor.py (gen | get | qr | render) <secret> [--title <t>] | <host>

Options:
 get <secret>
 gen <secret>  Generate a time-based one-time password based on the given
               secret that's usable right now.

 render <secret>
 qr <secret>   Render a QR code to the terminal based on the given secret.
               Pass --title if you want to give the generated QR code a
               special title.

 <host>        Lookup the given host in .netrc and use the "account" field as
               a secret and output a one-time password based on it.  If an
               exact match is not found then a partial match is attempted.
"""

from __future__ import print_function
from netrc import netrc
import re
import sys

from docopt import docopt
import pyotp
import pyqrcode

if __name__ == '__main__':
    opts = docopt(__doc__, version='1.0')

    exit_code = 0

    if opts['gen'] or opts['get']:
        totp = pyotp.TOTP(opts['<secret>'])
        print(totp.now())
    elif opts['qr'] or opts['render']:
        title = "QRCODE from pyqrcode" if not opts['--title'] else opts['<t>']
        url = "otpauth://totp/%s?secret=%s" % (title, opts['<secret>'])
        qr = pyqrcode.create(url)
        print(qr.terminal())
    else:
        hostname = opts['<host>']
        account = None

        n = netrc()

        if hostname in n.hosts:
            # Try an exact match first...
            _, account, _ = n.hosts[hostname]
        else:
            # Look for a partial match among all machines in netrc.
            regex = re.compile('.*%s.*' % hostname)
            match = [h for h in n.hosts.iterkeys() if re.match(regex, h)]
            if match:
                print("(Matched netrc entry '%s')" % match[0], file=sys.stderr)
                _, account, _ = n.hosts[match[0]]

        # Did we determine account by any means above?
        if account is not None:
            totp = pyotp.TOTP(account)
            print(totp.now())
        else:
            print("No netrc entry matching '%s'" % hostname, file=sys.stderr)
            exit_code = 1

    sys.exit(exit_code)
