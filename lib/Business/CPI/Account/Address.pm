package Business::CPI::Account::Address;
# ABSTRACT: Business::CPI class for Addresses
use Moo;
use utf8;
use Locale::Country ();

our $VERSION = '0.907'; # VERSION

# TODO:
# move this to Business::CPI core

has line1      => ( is => 'lazy' );
has line2      => ( is => 'lazy' );

has street     => ( is => 'rw' );
has number     => ( is => 'rw' );
has district   => ( is => 'rw' );
has complement => ( is => 'rw' );
has zip_code   => ( is => 'rw' );
has city       => ( is => 'rw' );
has state      => ( is => 'rw' ); # TODO: compare against Brazilian UF's, if country eq br
has country => (
    is => 'rw',
    isa => sub {
        # TODO: optimize
        for (Locale::Country::all_country_codes()) {
            return 1 if $_ eq $_[0];
        }
        die 'Must provide a valid country code';
    },
    coerce => sub {
        my $country = lc $_[0];
        # TODO: optimize
        for (Locale::Country::all_country_codes()) {
            return $_ if $_ eq $country;
        }
        return Locale::Country::country2code($country);
    },
);

sub _build_line1 {
    my $self = shift;

    my $street = $self->street     || '';
    my $number = $self->number     || '';
    my $compl  = $self->complement || '';

    return unless $street;

    return $street unless ($number || $compl);

    return "$street, $number" unless $compl;
    return "$street - $compl" unless $number;

    return "$street, $number - $compl";
}

sub _build_line2 {
    my $self = shift;

    return $self->district;
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Business::CPI::Account::Address - Business::CPI class for Addresses

=head1 VERSION

version 0.907

=head1 SYNOPSIS

    $cpi->create_account({
        # ...
        address    => {
            street     => 'Av. ABC',
            number     => '1000',
            complement => '7º andar',
            district   => 'Bairro XYZ',
            city       => 'Rio de Janeiro',
            state      => 'RJ',
            country    => 'br',
        },
        # ...
    });

=head1 DESCRIPTION

This class represents addresses in the context of accounts in gateways, both of
individuals and companies.

=head1 ATTRIBUTES

=head2 line1

The first line of the complete address. This may be set directly in the
constructor, or it will be generated automatically using the other fields.

=head2 line2

Second line of the complete address. As with the first line, it can be
automatically generated using the other fields.

=head2 street

The name of the street, route, avenue, etc.

=head2 number

The address number in the street.

=head2 district

District, borough or neighborhood.

=head2 complement

Complement, such as the apartment number, for example.

=head2 zip_code

Zip or postal code.

=head2 city

The city of the address.

=head2 state

The state in which the city is located. L<Business::CPI> will always store the
code of the state, if it exists, even if the gateway expects the full name.

=head2 country

Locale::Country code for the country. You can set using the ISO 3166-1
two-letter code, or the full name in English. It will coerce it and store the
ISO 3166-1 two-letter code.

=head1 SPONSORED BY

Estante Virtual - L<http://www.estantevirtual.com.br>

=head1 SEE ALSO

L<Business::CPI>, L<Business::CPI::Account>, L<Business::CPI::Account::Business>

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
