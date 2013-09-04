#!/usr/bin/perl

use 5.006;
use strict;
use warnings FATAL => 'all';

use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Alien::LibUSBx' ) || print "Bail out!\n";
}

diag( "Testing Alien::LibUSBx $Alien::LibUSBx::VERSION, Perl $], $^X" );
