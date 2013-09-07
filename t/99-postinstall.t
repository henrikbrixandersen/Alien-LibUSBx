#!/usr/bin/perl -w

use strict;

use Test::More;

unless ($ENV{POSTINSTALL_TESTING}) {
    plan(skip_all => "Skipping post-install tests");
} else {
    plan tests => 2;
}

my $libusbx;
BEGIN {
    use Alien::LibUSBx;
    $libusbx = Alien::LibUSBx->new;
}
use Inline (C => 'DATA', CCFLAGS => $libusbx->cflags, LIBS => $libusbx->libs);

my $version = version();
unlike($version, qr/^Error:/);
isnt($version, '');

my $type = $libusbx->install_type;
diag "Initialized libusb-1.0, version $version, install type $type\n";

__DATA__
__C__

#include <libusb.h>

SV*
version()
{
    const struct libusb_version *version;
    SV *sv;
    int res;

    res = libusb_init(NULL);
    if (res != 0) {
        sv = newSVpvf("Error: %s", libusb_strerror(res));
    } else {
        version = libusb_get_version();
        sv = newSVpvf("%d.%d.%d%s (%d)",
                      version->major, version->minor, version->micro,
                      version->rc, version->nano);
        libusb_exit(NULL);
    }

    return sv;
}
