package Business::CPI::Buyer;
# ABSTRACT: Information about the client
use Moo;
use Locale::Country ();
use Email::Valid ();

our $VERSION = '0.908'; # VERSION

has email => (
    isa => sub {
        die "Must be a valid e-mail address"
            unless Email::Valid->address( $_[0] );
    },
    is => 'ro',
);

has name => (
#    isa => 'Str',
    is => 'ro',
);

has address_line1      => ( is => 'lazy' );
has address_line2      => ( is => 'lazy' );

has address_street     => ( is => 'ro', required => 0 );
has address_number     => ( is => 'ro', required => 0 );
has address_district   => ( is => 'ro', required => 0 );
has address_complement => ( is => 'ro', required => 0 );
has address_zip_code   => ( is => 'ro', required => 0 );
has address_city       => ( is => 'ro', required => 0 );
has address_state      => ( is => 'ro', required => 0 );
has address_country    => (
    is => 'ro',
    required => 0,
    isa => sub {
        for (Locale::Country::all_country_codes()) {
            return 1 if $_ eq $_[0];
        }
    },
    coerce => sub {
        my $country = lc $_[0];
        for (Locale::Country::all_country_codes()) {
            return $_ if $_ eq $country;
        }
        return Locale::Country::country2code($country);
    },
);

sub _build_address_line1 {
    my $self = shift;

    my $street = $self->address_street || '';
    my $number = $self->address_number || '';

    return unless $street;

    return $street unless $number;

    return "$street, $number";
}

sub _build_address_line2 {
    my $self = shift;

    my $distr = $self->address_district   || '';
    my $compl = $self->address_complement || '';

    return $distr if ($distr && !$compl);
    return $compl if (!$distr && $compl);

    return "$distr - $compl";
}

# TODO
# add all the other attrs.
#
# try and find the common ones between PagSeguro / PayPal / etc, and keep them
# here. Specific attrs can stay in Business::CPI::Buyer::${gateway}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Business::CPI::Buyer - Information about the client

=head1 VERSION

version 0.908

=head1 DESCRIPTION

This class holds information about the buyer in a shopping cart. The address
attributes are available so that if shipping is required, the buyer's address
will be passed to the gateway (if the attributes were set).

=head1 ATTRIBUTES

=head2 email

Buyer's e-mail, which usually is their unique identifier in the gateway.

=head2 name

Buyer's name.

=head2 address_line1

=head2 address_line2

Some gateways (such as PayPal) do not define the street address as specific
separate fields (such as Street, Number, District, etc). Instead, they only
accept two address lines. For our purposes, we define a lazy builder for these
attributes in case they are not directly set, using the specific fields
mentioned above.

=head2 address_street

Street name for shipping.

=head2 address_number

Address number for shipping.

=head2 address_district

District name.

=head2 address_complement

If any extra information is required to find the address set this field.

=head2 address_zip_code

Postal code.

=head2 address_city

City.

=head2 address_state

State.

=head2 address_country

Locale::Country code for the country. You can set using the ISO 3166-1
two-letter code, or the full name in English. It will coerce it and store the
ISO 3166-1 two-letter code.

=head1 NOTE

This class will soon be ported to use L<Business::CPI::Account>, either
becoming a role, or extending it via inheritance. So beware of
backcompatibility issues. In particular, all attributes prefixed with
C<address_*> will lose the prefix and be set using the
L<Business::CPI::Account::Address> class.

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
