#!/usr/bin/env python

"""Two factor utility to generate one-time passwords or QR codes."""

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
            _, account, _ = n.hosts[hostname]
        else:
            regex = re.compile('.*%s.*' % hostname)
            match = [h for h in n.hosts.iterkeys() if re.match(regex, h)]
            if match:
                print("(Matched netrc entry '%s')" % match[0], file=sys.stderr)
                _, account, _ = n.hosts[match[0]]

        if account is not None:
            totp = pyotp.TOTP(account)
            print(totp.now())
        else:
            print("No netrc entry matching '%s'" % hostname, file=sys.stderr)
            exit_code = 1

    sys.exit(exit_code)
