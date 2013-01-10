package Business::CPI::Item;
# ABSTRACT: Product in the cart
use Moo;
use Business::CPI::Types qw/stringified_money/;

our $VERSION = '0.5'; # VERSION

has id => (
    coerce => sub { '' . $_[0] },
    is => 'ro',
);

has price => (
    coerce => \&stringified_money,
    is => 'ro',
);

has weight => (
    coerce => sub { 0 + $_[0] },
    required => 0,
    is => 'ro',
);

has shipping => (
    coerce => \&stringified_money,
    required => 0,
    is => 'ro',
);

has shipping_additional => (
    coerce => \&stringified_money,
    required => 0,
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

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Business::CPI::Item - Product in the cart

=head1 VERSION

version 0.5

=head1 DESCRIPTION

This class holds information about the products in a shopping cart.

=head1 ATTRIBUTES

=head2 id

Unique identifier for this product in your application.

=head2 price

The price (in the chosen currency; see
L<Business::CPI::Gateway::Base/currency>) of one item. This will be multiplied
by the quantity.

=head2 shipping

The shipping cost (in the chosen currency, same as in the price above) for this
particular item.

=head2 shipping_additional

The cost of each additional quantity of this item. For example, if the quantity
is 5, the L</shipping> attribute is set to 1.50, and this attribute is set to
0.50, then the total shipping cost will be 1*1.50 + 4*0.50 = 3.50. Note that
not all gateways implement this. In PayPal, for instance, it's called
shipping2.

=head2 weight

The weight of this item. If you define the L</shipping>, this will probably be
ignored by the gateway.

=head2 description

The description or name of the product.

=head2 quantity

How many of this product is being bought?

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
