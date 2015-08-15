package Fritz::Device;
use strict;
use warnings;

use Fritz::Data;
use Fritz::Error;
use Fritz::Service;

use Moo;
use namespace::clean;

with 'Fritz::IsNoError';

has fritz        => ( is => 'ro' );

has xmltree      => ( is => 'ro' );

has service_list => ( is => 'lazy', init_arg => undef );
has device_list  => ( is => 'lazy', init_arg => undef );

use constant ATTRIBUTES => qw(
deviceType
friendlyName
manufacturer
manufacturerURL
modelDescription
modelName
modelNumber
modelURL
UDN
presentationURL
);

for my $attr (ATTRIBUTES) {
    has $attr => ( is => 'ro' );
}

sub BUILD {
    # FIXME convert this to lazy attributes - but how to generate them dynamically?
    my $self = shift;

    my $xml = $self->xmltree;

    for my $attr (ATTRIBUTES) {
	if (exists $xml->{$attr}) {
	    $self->{$attr} = $xml->{$attr}->[0];
	}
    }
}

sub _build_service_list {
    my $self = shift;
    my $xml  = $self->xmltree;
    my @services;

    if (exists $xml->{serviceList}) {
	foreach my $service (@{$xml->{serviceList}->[0]->{service}}) {
	    push @services, Fritz::Service->new(
		xmltree => $service,
		fritz   => $self->fritz
		);
	}
    }

    return \@services;
}

sub _build_device_list {
    my $self = shift;
    my $xml  = $self->xmltree;
    my @devices;

    if (exists $xml->{deviceList}) {
	foreach my $device (@{$xml->{deviceList}->[0]->{device}}) {
	    push @devices, Fritz::Device->new(
		xmltree => $device,
		fritz   => $self->fritz
		);
	}
    }

    return \@devices;
}

sub get_service {
    my $self = shift;
    my $type = shift;

    foreach my $service (@{$self->service_list}) {
	if ($service->serviceType eq $type) {
	    return $service;
	}
    }

    foreach my $device (@{$self->device_list}) {
	my $service = $device->find_service($type);
	if (! $service->error) {
	    return $service;
	}
    }
    
    return Fritz::Error->new('service not found');
}

sub find_service {
    my $self = shift;
    my $type = shift;

    foreach my $service (@{$self->service_list}) {
	if ($service->serviceType =~ /$type/) {
	    return $service;
	}
    }

    foreach my $device (@{$self->device_list}) {
	my $service = $device->find_service($type);
	if (! $service->error) {
	    return $service;
	}
    }

    return Fritz::Error->new('service not found');
}

sub find_service_names {
    my $self = shift;
    my $type = shift;

    my @found = ();

    foreach my $service (@{$self->service_list}) {
	if ($service->serviceType =~ /$type/) {
	    push @found, $service->serviceType;
	}
    }

    foreach my $device (@{$self->device_list}) {
	my $data = $device->find_service_names($type);
	if (! $data->error) {
	    push @found, @{$data->raw};
	}
    }

    return Fritz::Data->new(\@found);
}

sub find_device {
    my $self = shift;
    my $type = shift;

    foreach my $device (@{$self->device_list}) {
	if ($device->deviceType eq $type) {
	    return $device;
	}
    }
    
    foreach my $device (@{$self->device_list}) {
	my $device = $device->find_device($type);
	if (! $device->error) {
	    return $device;
	}
    }
    
    return Fritz::Error( error => 'device not found' );
}

sub dump {
    my $self = shift;

    my $indent = shift;
    $indent = '' unless defined $indent;

    print "${indent}Fritz::Device:\n";
    $indent .= '  ';
    print "${indent}modelName       = " . $self->modelName . "\n";
    print "${indent}presentationURL = " . $self->presentationURL . "\n" if defined $self->presentationURL;

    if ($self->service_list) {
	print "${indent}subservices    = {\n";
	foreach my $service (@{$self->service_list}) {
	    $service->dump($indent . '  ');
	}
	print "${indent}}\n";
    }

    if ($self->device_list) {
	print "${indent}subdevices      = {\n";
	foreach my $device (@{$self->device_list}) {
	    $device->dump($indent . '  ');
	}
	print "${indent}}\n";
    }
}

1;
