package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Ports;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $ports = _getPorts(logger => $logger);

    return unless $ports;

    foreach my $port (@$ports) {
        $inventory->addEntry(
            section => 'PORTS',
            entry   => $port
        );
    }
}

sub _getPorts {
    my $infos = getDmidecodeInfos(@_);

    return unless $infos->{8};

    my $ports;
    foreach my $info (@{$infos->{8}}) {
        my $port = {
            CAPTION     => $info->{'External Connector Type'},
            DESCRIPTION => $info->{'Internal Connector Type'},
            NAME        => $info->{'Internal Reference Designator'},
            TYPE        => $info->{'Port Type'},
        };

        push @$ports, $port;
    }

    return $ports;
}

1;