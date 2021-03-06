#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::Solaris::Networks;

my %ifconfig_tests = (
    'solaris-10' => [
        {
            IPSUBNET    => '127.0.0.0',
            IPMASK      => '255.0.0.0',
            DESCRIPTION => 'lo0',
            TYPE        => 'ethernet',
            STATUS      => 'Up',
            SPEED       => undef,
            IPADDRESS   => '127.0.0.1'
        },
        {
            IPMASK      => '255.255.254.0',
            MACADDR     => '00:15:17:7a:60:31',
            STATUS      => 'Up',
            SPEED       => undef,
            IPSUBNET    => '130.79.0.0',
            DESCRIPTION => 'aggr1',
            TYPE        => 'ethernet',
            IPADDRESS   => '130.79.0.1'
        },
        {
            IPMASK      => '255.255.255.128',
            MACADDR     => '00:15:17:7a:60:30',
            STATUS      => 'Up',
            SPEED       => undef,
            IPSUBNET    => '130.79.0.0',
            DESCRIPTION => 'e1000g0',
            TYPE        => 'ethernet',
            IPADDRESS   => '130.79.0.2'
        },
        {
            IPMASK      => '255.255.255.128',
            MACADDR     => '00:15:17:7a:60:32',
            STATUS      => 'Up',
            SPEED       => undef,
            IPSUBNET    => '130.79.0.0',
            DESCRIPTION => 'e1000g2',
            TYPE        => 'ethernet',
            IPADDRESS   => '130.79.0.3'
        },
        {
            IPMASK      => '255.255.255.0',
            MACADDR     => '00:15:17:7a:60:33',
            STATUS      => 'Up',
            SPEED       => undef,
            IPSUBNET    => '192.168.19.0',
            DESCRIPTION => 'e1000g3',
            TYPE        => 'ethernet',
            IPADDRESS   => '192.168.19.1'
        },
        {
            IPMASK      => '255.255.255.224',
            MACADDR     => '00:15:17:8a:48:30',
            STATUS      => 'Up',
            SPEED       => undef,
            IPSUBNET    => '130.79.255.0',
            DESCRIPTION => 'e1000g4',
            TYPE        => 'ethernet',
            IPADDRESS   => '130.79.255.1'
        },
        {
            IPMASK      => '255.255.255.0',
            MACADDR     => '00:15:17:6a:44:4c',
            STATUS      => 'Up',
            SPEED       => undef,
            IPSUBNET    => '192.168.20.0',
            DESCRIPTION => 'igb0',
            TYPE        => 'ethernet',
            IPADDRESS   => '192.168.20.1'
        }
    ],
    'opensolaris' => [
        {
            IPSUBNET    => '127.0.0.0',
            IPMASK      => '255.0.0.0',
            DESCRIPTION => 'lo0',
            TYPE        => 'ethernet',
            STATUS      => 'Up',
            SPEED       => undef,
            IPADDRESS   => '127.0.0.1'
        },
        {
            IPMASK      => '255.255.255.0',
            MACADDR     => '08:00:27:fc:ad:56',
            STATUS      => 'Up',
            SPEED       => undef,
            IPSUBNET    => '192.168.0.0',
            DESCRIPTION => 'e1000g0',
            TYPE        => 'ethernet',
            IPADDRESS   => '192.168.0.41'
        },
        {
            IPSUBNET    => undef,
            DESCRIPTION => 'lo0',
            TYPE        => 'ethernet',
            STATUS      => 'Up',
            SPEED       => undef
        },
        {
            IPSUBNET    => undef,
            MACADDR     => '08:00:27:fc:ad:56',
            DESCRIPTION => 'e1000g0',
            TYPE        => 'ethernet',
            STATUS      => 'Up',
            SPEED       => undef
        },
        {
            IPSUBNET    => undef,
            DESCRIPTION => 'e1000g0:1',
            TYPE        => 'ethernet',
            STATUS      => 'Up',
            SPEED       => undef
        }
    ]

);

plan tests => (2 * keys %ifconfig_tests) + 3;

my $inventory = FusionInventory::Test::Inventory->new();

foreach my $test (keys %ifconfig_tests) {
    my $file = "resources/generic/ifconfig/$test";
    my @interfaces = FusionInventory::Agent::Task::Inventory::Solaris::Networks::_getInterfaces(file => $file);
    cmp_deeply(\@interfaces, $ifconfig_tests{$test}, "$test: parsing");
    lives_ok {
        $inventory->addEntry(section => 'NETWORKS', entry => $_)
            foreach @interfaces;
    } "$test: registering";
}

my @parsefcinfo = (
      {
            FIRMWARE     => '05.03.02',
            STATUS       => 'Up',
            SPEED        => '4Gb',
            DRIVER       => 'qlc',
            DESCRIPTION  => 'HBA_Port_WWN_1 /dev/cfg/c0',
            MANUFACTURER => 'QLogic Corp.',
            MODEL        => 'QLE2462',
            WWN          => '200000e08b94b4a3'
      },
      {
            FIRMWARE     => '05.03.02',
            STATUS       => 'Up',
            SPEED        => '4Gb',
            DRIVER       => 'qlc',
            DESCRIPTION  => 'HBA_Port_WWN_2 /dev/cfg/c1',
            MANUFACTURER => 'QLogic Corp.',
            MODEL        => 'QLE2462',
            WWN          => '200100e08bb4b4a3'
      }
);
my $file = "resources/solaris/fcinfo_hba-port/sample-1";
my @interfaces = FusionInventory::Agent::Task::Inventory::Solaris::Networks::_parsefcinfo(file => $file);
cmp_deeply(\@interfaces, \@parsefcinfo, "fcinfo: parsing");
lives_ok {
    $inventory->addEntry(section => 'NETWORKS', entry => $_)
        foreach @interfaces;
} "fcinfo: registering;"
