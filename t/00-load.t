#!/usr/bin/perl -w

use strict;

use Test::More tests => 2;

BEGIN { use_ok('Alien::LibUSBx'); }
require_ok('Alien::LibUSBx');

diag("Testing Alien::LibUSBx $Alien::LibUSBx::VERSION, Perl $], $^X");
