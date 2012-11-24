package Business::CPI::Buyer;
use Moo;

has email => (
    isa => sub {
        Email::Valid->address( $_[0] ) || die "Must be a valid e-mail address";
    },
    is => 'ro',
);

has name => (
#    isa => 'Str',
    is => 'ro',
);

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

Business::CPI::Buyer

=head1 VERSION

version 0.1

=head1 DESCRIPTION

This class holds information about the buyer in a shopping cart.

=head1 ATTRIBUTES

=head2 email

Buyer's e-mail, which usually is their unique identifier in the gateway.

=head2 name

Buyer's name.

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
