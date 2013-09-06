#!/usr/bin/perl -w

use strict;

use Config;
use Test::More tests => 5;

BEGIN { use_ok('Alien::LibUSBx'); }
require_ok('Alien::LibUSBx');

diag("Testing Alien::LibUSBx $Alien::LibUSBx::VERSION, Perl $], $^X, OS $^O ($Config{'archname'})");

my $alien = new_ok('Alien::LibUSBx');

isa_ok($alien, 'Alien::Base');

can_ok($alien, qw/cflags libs/);
