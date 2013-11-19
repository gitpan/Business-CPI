package Business::CPI::Types;
# ABSTRACT: Coersion and checks
use warnings;
use strict;
use Exporter 'import';
use Scalar::Util qw/looks_like_number/;

our $VERSION = '0.905'; # VERSION

our @EXPORT_OK = qw/stringified_money/;

sub stringified_money {
    my $r = looks_like_number($_[0]) ? $_[0] : 0;
    return sprintf( "%.2f", 0+$r);
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Business::CPI::Types - Coersion and checks

=head1 VERSION

version 0.905

=head1 DESCRIPTION

Coersions for the internal CPI attributes.

=head1 METHODS

=head2 stringified_money

Most gateways require the money amount to be provided with two decimal places.
This method coerces the value into number, and then to a string as expected by
the gateways.

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
