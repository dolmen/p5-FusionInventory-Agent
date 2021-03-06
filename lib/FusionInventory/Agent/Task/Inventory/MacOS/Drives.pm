package FusionInventory::Agent::Task::Inventory::MacOS::Drives;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get filesystem types
    my @types =
        grep { ! /^(?:fdesc|devfs|procfs|linprocfs|linsysfs|tmpfs|fdescfs)$/ }
        getFilesystemsTypesFromMount(logger => $logger);

    # get filesystems for each type
    my @filesystems;
    foreach my $type (@types) {
        push @filesystems, getFilesystemsFromDf(
            logger  => $logger,
            command => "df -P -k -t $type",
            type    => $type,
        );
    }

    my %filesystems = map { $_->{VOLUMN} => $_ } @filesystems;

    foreach my $partition (_getPartitions()) {
        my $device = "/dev/$partition";

        my $info = _getPartitionInfo(partition => $partition);

        my $filesystem = $filesystems{$device};
        next unless $filesystem;

        if ($info->{'Total Size'} =~ /^([.\d]+ \s \S+)/x) {
            $filesystem->{TOTAL} = getCanonicalSize($1);
        }
        $filesystem->{SERIAL}     = $info->{'Volume UUID'} ||
                                    $info->{'UUID'};
        $filesystem->{FILESYSTEM} = $info->{'File System'} ||
                                    $info->{'Partition Type'};
        $filesystem->{LABEL}      = $info->{'Volume Name'};
    }

    # add filesystems to the inventory
    foreach my $key (keys %filesystems) {
        $inventory->addEntry(
            section => 'DRIVES',
            entry   => $filesystems{$key}
        );
    }
}

sub _getPartitions {
    my (%params) = @_;

    my $command = "diskutil list";
    my $handle = getFileHandle(command => $command, %params);
    return unless $handle;

    my @devices;
    while (my $line = <$handle>) {
        # partition identifiers look like disk0s1
        next unless $line =~ /(disk \d+ s \d+)$/x;
        push @devices, $1;
    }
    close $handle;

    return @devices;
}

sub _getPartitionInfo {
    my (%params) = @_;

    my $command = "diskutil info $params{partition}";
    my $handle = getFileHandle(command => $command, %params);
    return unless $handle;

    my $info;
    while (my $line = <$handle>) {
        next unless $line =~ /(\S[^:]+) : \s+ (\S.*\S)/x;
        $info->{$1} = $2;
    }
    close $handle;

    return $info;
}

1;
