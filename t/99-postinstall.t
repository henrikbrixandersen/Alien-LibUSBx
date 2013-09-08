#!/usr/bin/perl -w

use strict;

use Test::More;
use Alien::LibUSBx;

my $libusbx = Alien::LibUSBx->new;

if ($libusbx->install_type eq 'system' || $ENV{POSTINSTALL_TESTING}) {
    eval 'use Inline';
    if ($@) {
        plan(skip_all => 'Inline required');
    } else {
        plan tests => 3;
    }
} else {
    plan(skip_all => 'Skipping post-install tests');
}

my $c = <<END;
#include <libusb.h>

SV*
version()
{
    const struct libusb_version *version;
    SV *sv;
    int res;

    res = libusb_init(NULL);
    if (res != 0) {
        sv = newSVpvf("Error: %s", libusb_error_name(res));
    } else {
        version = libusb_get_version();
        sv = newSVpvf("%d.%d.%d%s (%d)",
                      version->major, version->minor, version->micro,
                      version->rc, version->nano);
        libusb_exit(NULL);
    }

    return sv;
}
END

Inline->bind(C => $c, CCFLAGS => $libusbx->cflags, LIBS => $libusbx->libs);

my $version = version();
unlike($version, qr/^Error:/, 'Initialize libusb-1.0');
isnt($version, '', 'Nonempty version string');
isnt($version, undef, 'Defined version string');

my $type = $libusbx->install_type;
diag "Initialized libusb-1.0, version $version, install type $type\n";
