package Units::Base;
require 5.004;
require Exporter;

@ISA = qw(Exporter);

use vars qw($VERSION);

use Carp;

$VERSION = "0.10";

sub initialize {
    my $self = shift;
    $self->{default} 		= undef; 	# default unit
    $self->{conversions} 	= {};		# conversions
    $self->{synonyms} 		= {};		# unit synonyms and abbreviations
    $self->{multipliers} 	= {};		# multipliers
}

sub import {
    my $self = shift;

    my ($conversions, $synonyms, $multipliers, $default) = (@_);

    $self->{conversions} 	= $conversions;
    $self->{synonyms} 		= $synonyms;
    $self->{multipliers} 	= $multipliers;
    $self->{default} 		= $default;

    # if no default unit has been defined, look for any "base" unit

    unless (defined($self->{default}))
    {
        foreach (keys %{$self->{conversions}})
        {
            if (${$self->{conversions}}{$_}==1)
            {
                $self->{default} = $_;
            }
        }
    }

    # Add plural versions of unit names

    foreach (keys %{$self->{conversions}}) {
        ${$self->{conversions}}{$self->plural($_)} = ${$self->{conversions}}{$_};
    }

    foreach (keys %{$self->{multipliers}}) {
        ${$self->{multipliers}}{$self->plural($_)} = ${$self->{multipliers}}{$_};
    }

    # Add synonyms and abbreviations for units

    foreach (keys %{$self->{synonyms}}) {
        ${$self->{conversions}}{$_} = ${$self->{conversions}}{${$self->{synonyms}}{$_}};
    }
}

sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my $self = {};
    bless $self, $class;
    $self->initialize();
    $self->import(@_);
    return $self;
}

sub plural
{
    my $self = shift;

    local ($_) = shift;

    my $suff = "s";
    
    $suff = "es",	 if (m/(ch|s)$/);
    $suff = "ies", if (m/y$/);

    $_ .= $suff;

    $_ = "halves", if ($_ eq "halfs");	# exceptions
    $_ = "feet",   if ($_ eq "foots");

    return $_;
}

sub parse_unit
{
    my $self = shift;

    local ($_) = shift;
    m/^(\d*)\s*(\D*)$/;

    my $number = $1 || 1;
    my $unit   = $2 || $self->{default};

    unless (defined(${$self->{conversions}}{$unit}))
    {
        if ($unit =~ m/(\w+)([\s\-]of[\s\-]an?)?[\s\-](\w+)$/)
        {
            $number *= ${$self->{multipliers}}{$1};
            $unit = $3;
        }
    }

    unless (defined(${$self->{conversions}}{$unit}))
    {
        croak "Invalid unit: $unit";
    }

    return ($number, $unit);
}

sub convert_units
{
    my $self = shift;

    my ($amount, $unit) 	= $self->parse_unit (shift);
    my ($multiple, $unit_to) 	= $self->parse_unit (shift);
   
    unless (defined($unit_to)) {
        $unit_to 	= $default_unit;
    }

    my $inches 	= $amount * ${$self->{conversions}}{$unit};
    unless ($inches) {
        croak "Undefined unit: $unit";
    }
    my $result 	= $inches / ${$self->{conversions}}{$unit_to} / $multiple;

    return $result;
}

1;

__END__

=head1 NAME

Units::Base - base object for performing unit conversions

=head1 DESCRIPTION

Units::Base contains some low-level string parsing and conversion routines
that can be used by other modules to convert between units of measurement
(such as millimeters to feet or points to picas or even millimeters to
sixteenths-of-an-inch).

Among the nicities (I think so anyway...) of this unit are synonyms and
abbreviations for units, and the ability to use I<multipliers> (so that
you need only define a unit once but specify conversions based on
"hundreths of an inch" etc.

=head1 SEE ALSO

I<Units::Length> which demonstrates how this unit is used.

=head1 COPYRIGHT

Copyright (c) 1999 Robert Rothenberg. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

Robert Rothenberg <wlkngowl@unix.asb.com>

=cut
