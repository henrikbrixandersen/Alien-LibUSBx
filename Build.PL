#!/usr/bin/perl

use strict;
use warnings;

use Alien::Base::ModuleBuild;

my $libusbx_version = '1.0.16';

# Mirror list: http://sourceforge.net/apps/trac/sourceforge/wiki/Mirrors
my @mirrors = qw/aarnet dfn freefr garr heanet hivelocity internode
jaist kaz kent master nchc netcologne softlayer-dal switch tenet ufpr
waix/;

my @alien_repos;
foreach my $mirror (@mirrors) {
    my $alien_repo = {
        host => "$mirror.dl.sourceforge.net",
    };
    push @alien_repos, $alien_repo;
}

my $builder = Alien::Base::ModuleBuild->new(
    module_name => 'Alien::LibUSBx',
    dist_author => 'Henrik Brix Andersen <henrik@brixandersen.dk>',
    license  => 'perl',

    configure_requires => {
        'Alien::Base' => '0.003',
        'Module::Build' => '0.38',
    },

    requires => {
        'Alien::Base' => '0.003',
    },

    alien_name => 'libusbx',
    alien_repository_default => {
        protocol => 'http',
        location => '/project/libusbx/releases/1.0.16/source',
        exact_filename => "libusbx-$libusbx_version.tar.bz2",
        exact_version => $libusbx_version,
    },
    alien_repository => \@alien_repos,
);

$builder->create_build_script;
