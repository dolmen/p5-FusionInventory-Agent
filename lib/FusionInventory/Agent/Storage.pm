package FusionInventory::Agent::Storage;
        
use strict;
use warnings;

use Config;
use English qw(-no_match_vars);
use File::Glob ':glob';
use File::Path qw(make_path);
use Storable;

use FusionInventory::Agent::Logger;

sub new {
    my ($class, %params) = @_;

    die "no directory parameter" unless $params{directory};

    if (!-d $params{directory}) {
        make_path($params{directory}, {error => \my $err});
        if (@$err) {
            my (undef, $message) = %{$err->[0]};
            die "Can't create $params{directory}: $message";
        }
    }

    if (! -w $params{directory}) {
        die "Can't write in $params{directory}";
    }

    my $self = {
        logger    => $params{logger} ||
                     FusionInventory::Agent::Logger->new(),
        directory => $params{directory}
    };

    bless $self, $class;

    return $self;
}

sub getDirectory {
    my ($self) = @_;

    return $self->{directory};
}

sub _getFileName {
    my ($self, %params) = @_;

    my $module = $params{module};

    if (!$module) {
        my $i = 0;
        while ($module = caller($i++)) {
            last if $module ne 'FusionInventory::Agent::Storage';
        }
    }

    my $fileName = $module;
    $fileName =~ s/::/-/g; # Drop prohibited caracters

    return $fileName;
}

sub _getFilePath {
    my ($self, %params) = @_;

    my $idx = $params{idx};
    die "idx is not an integer" if defined $idx && $idx !~ /^\d+$/;
    my $module = $params{module};

    my $fileName = $self->_getFileName(
        module => $module
    );

    my $extension = defined $idx ? ".$idx" : "";

    return $self->{directory}."/".$fileName.$extension.".dump";
}

sub has {
    my ($self, %params) = @_;

    my $file = $self->_getFilePath(%params);

    return -f $file;
}

sub save {
    my ($self, %params) = @_;

    my $file = $self->_getFilePath(%params);

    store($params{data}, $file) or warn;
}

sub restore {
    my ($self, %params) = @_;

    my $file = $self->_getFilePath(%params);

    return unless -f $file;
    return retrieve($file);
}

sub remove {
    my ($self, %params) = @_;

    my $file = $self->_getFilePath(%params);

    unlink $file or $self->{logger}->error("can't unlink $file");
}

sub removeAll {
    my ($self, %params) = @_;
    
    my $file = $self->_getFilePath(%params);

    unlink $file or $self->{logger}->error("can't unlink $file");
}

sub removeSubDumps {
    my ($self, %params) = @_;
   
    my $module = $params{module};

    my $fileDir = $self->getFileDir();
    my $fileName = $self->_getFileName(module => $module);

    foreach my $file (bsd_glob("$fileDir/$fileName.*.dump")) {
        unlink $file or $self->{logger}->error("can't unlink $file");
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Storage - A data serializer/deserializer

=head1 SYNOPSIS

  my $storage = FusionInventory::Agent::Storage->new(
      directory => '/tmp'
  );
  my $data = $storage->restore(
      module => "FusionInventory::Agent"
  );

  $data->{foo} = 'bar';

  $storage->save(data => $data);

=head1 DESCRIPTION

This is the object used by the agent to ensure data persistancy between
invocations.

Each data structure is saved in a file, whose name is automatically determined
according to object class name. An optional index number can be used to
differentiate between consecutives usages.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use

=item I<directory>

the directory to use for storing data (mandatory)

=back

=head2 getDirectory

Returns the underlying directory for this storage.

=head2 has(%params)

Returns true if a saved data structure exists. The following arguments are
allowed:

=over

=item module

The name of the module which saved the data structure (mandatory).

=item idx

The index number (optional).

=back

=head2 save(%params)

Save given data structure. The following parameters are allowed, as keys of the
%params hash:

=over

=item I<data>

The data structure to save (mandatory).

=item I<idx>

The index number (optional).

=back

=head2 restore(%params)

Restore a saved data structure. The following parameters are allowed, as keys
of the %params hash:

=over

=item I<module>

The name of the module which saved the data structure (mandatory).

=item I<idx>

The index number (optional).

=back

=head2 remove(%params)

Delete the file containing a seralized data structure for a given module. The
following parameters are allowed, as keys of the %params hash:

=over

=item I<module>

The name of the module which saved the data structure (mandatory).

=item I<idx>

The index number (optional).

=back

=head2 removeAll(%params)

Delete the files containing seralized data structure for all modules. The
following parameters are allowed, as keys of the %params hash:

=over

=item I<idx>

The index number (optional).

=back

=head2 removeSubDumps(%params)

Delete all files containing seralized data structure for a given module. The
following parameters are allowed, as keys of the %params hash:

=over

=item I<module>

The name of the module which saved the data structure (mandatory).

=back