package FusionInventory::Agent::Task::Inventory::Input::MacOS::USB;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

my $seen;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $device (_getDevices(logger => $logger)) {
        # avoid duplicates
        next if $seen->{$device->{SERIAL}}++;
        $inventory->addEntry(
            section => 'USBDEVICES',
            entry   => $device,
        );
    }
}

sub _getDevices {

    return 
        map {
            {
                VENDORID  => dec2hex($_->{'idVendor'}),
                PRODUCTID => dec2hex($_->{'idProduct'}),
                SERIAL    => $_->{'USB Serial Number'},
                NAME      => $_->{'USB Product Name'},
                CLASS     => $_->{'bDeviceClass'},
                SUBCLASS  => $_->{'bDeviceSubClass'}
            }
        }
        getIODevices(class => 'IOUSBDevice', @_);
}

1;