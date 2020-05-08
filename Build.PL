#!/usr/bin/perl

use strict;
use warnings;

use Alien::Base::ModuleBuild;
use Archive::Tar;
use Carp;
use Config;
use Env qw/ALIEN_LIBUSBX_CFLAGS ALIEN_LIBUSBX_LIBS/;

# Override the CFLAGS/LIBS settings
sub alien_override($$$$) {
    my ($builder, $version, $cflags, $libs) = @_;
    my $dirname = '_dummy';
    my $filename = "dummy-$version.tar";

    unless (-d $dirname) {
        mkdir($dirname) or croak "Could not create temporary directory '$dirname': $!";
    }

    my $tarfile = Archive::Tar->new;
    $tarfile->add_data('dummy.txt', 'Dummy file')
        or croak "Could not add data to in-memory archive: " . $tarfile->error;
    $tarfile->write("$dirname/$filename", undef, "dummy-$version")
        or croak "Could not create archive '$dirname/$filename': " . $tarfile->error;

    $builder->alien_repository_default(undef);
    $builder->alien_repository({protocol => 'local',
                                location => $dirname,
                                exact_filename => $filename,
                                exact_version => $version});

    $builder->alien_build_commands(undef);
    $builder->alien_install_commands(undef);

    $builder->alien_provides_cflags($cflags);
    $builder->alien_provides_libs($libs);
}

my @alien_repos;
my $alien_repo = {
    host => "https://github.com/libusb/libusb/releases",
};
push @alien_repos, $alien_repo;

my $builder = Alien::Base::ModuleBuild->new(
    module_name => 'Alien::LibUSBx',
    dist_author => 'Henrik Brix Andersen <brix@cpan.org>',
    license  => 'perl',
    meta_merge => {
        resources => {
            repository => 'https://github.com/henrikbrixandersen/Alien-LibUSBx',
        },
        keywords => ['libusb', 'libusb-1.0', 'USB'],
    },

    configure_requires => {
        'Alien::Base' => '0.003',
        'Archive::Tar' => '0',
        'Carp' => '0',
        'Config' => '0',
        'Env' => '0',
        'Module::Build' => '0.4004',
	'Alien::Base::ModuleBuild' => '0',
    },

    test_requires => {
        'Config' => '0',
        'Test::More' => '0',
    },

    requires => {
        'perl' => '5.006',
        'Alien::Base' => '0.003',
    },

    alien_name => 'libusb-1.0',
    alien_repository_default => {
        protocol => 'https',
        pattern  => qr/^.*\.tar\.bz2$/,
    },
    alien_repository => \@alien_repos,

    add_to_cleanup => ['_Inline', '_dummy'],
);

if (defined($ALIEN_LIBUSBX_CFLAGS) || defined($ALIEN_LIBUSBX_LIBS)) {
    alien_override($builder, 'unknown', $ALIEN_LIBUSBX_CFLAGS, $ALIEN_LIBUSBX_LIBS);
} elsif ($Config{'osname'} =~ qr/freebsd/i) {
   # FreeBSD 8+ ships with a native libusb-1.0 compatible library
    if (!$builder->do_system($builder->alien_version_check)) {
        if ($Config{'osvers'} =~ qr/^(\d+).*/) {
            if ($1 < 8) {
                croak 'FreeBSD versions below 8.x is not supported';
            }
        } else {
            carp 'Could not determine FreeBSD major version';
        }
        # Some versions of FreeBSD (8.x, 9.x) ship with a native
        # libusb-1.0 compatible library but no libusb-1.0.pc file
        alien_override($builder, '1.0.9', '-I/usr/include', '-L/usr/lib -lusb');
    }
}

$builder->create_build_script;
