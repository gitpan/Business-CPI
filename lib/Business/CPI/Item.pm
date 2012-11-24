package Business::CPI::Item;
# ABSTRACT: Product in the cart
use Moo;

has id => (
    coerce => sub { '' . $_[0] },
    is => 'ro',
);

has price => (
    coerce => sub { 0 + $_[0] },
    is => 'ro',
);

has description => (
    coerce => sub { '' . $_[0] },
    is => 'ro',
);

has quantity => (
    coerce => sub { int $_[0] },
    is => 'ro',
);

around price => sub {
    my $orig = shift;
    my $self = shift;

    return sprintf( "%.2f", $self->$orig(@_) );
};

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Business::CPI::Item - Product in the cart

=head1 VERSION

version 0.1

=head1 DESCRIPTION

This class holds information about the products in a shopping cart.

=head1 ATTRIBUTES

=head2 id

Unique identifier for this product in your application.

=head2 price

The price (in the chosen currency; see
L<Business::CPI::Gateway::Base/currency>) of one item. This will be multiplied
by the quantity.

=head2 description

The description or name of the product.

=head2 quantity

How many of this product is being bought?

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
