#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Inventory;
use FusionInventory::Agent::Task::Inventory::HPUX::Slots;

my %tests = (
    'hpux2-ioa' => [
        {
            DESIGNATION => 'System Bus Adapter (1229)',
        }
    ],
    'hpux2-ba' => [
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'PCItoPCI Bridge',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Core I/O Adapter',
        }
    ],
    'hpux1-ioa' => [
        {
            DESIGNATION => 'System Bus Adapter (1229)',
        }
    ],
    'hpux1-ba' => [
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'PCItoPCI Bridge',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Core I/O Adapter',
        }
    ]
);

plan tests => (2 * scalar keys %tests) + 1;

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'fatal' ],
    debug    => 1
);
my $inventory = FusionInventory::Agent::Inventory->new(logger => $logger);

foreach my $test (keys %tests) {
    my $file = "resources/hpux/ioscan/$test";
    my @slots = FusionInventory::Agent::Task::Inventory::HPUX::Slots::_getSlots(file => $file);
    cmp_deeply(\@slots, $tests{$test}, "$test ioscan parsing");
    lives_ok {
        $inventory->addEntry(section => 'SLOTS', entry => $_) foreach @slots;
    } "$test: registering";
}
