package Business::CPI::Cart;
# ABSTRACT: Shopping cart

use Moo;
use Business::CPI::Item;
use Business::CPI::Types qw/stringified_money/;

our $VERSION = '0.3'; # VERSION

has buyer => (
    is => 'ro',
    isa => sub { $_[0]->isa('Business::CPI::Buyer') or die "Must be a Business::CPI::Buyer" },
);

has tax => (
    coerce => \&stringified_money,
    required => 0,
    is => 'ro',
);

has handling => (
    coerce => \&stringified_money,
    required => 0,
    is => 'ro',
);

has discount => (
    coerce => \&stringified_money,
    required => 0,
    is => 'ro',
);

has _gateway => (
    is => 'ro',
    isa => sub { $_[0]->isa('Business::CPI::Gateway::Base') or die "Must be a CPI::Gateway::Base" },
);

has _items => (
    is => 'ro',
    #isa => 'ArrayRef[Business::CPI::Item]',
    default => sub { [] },
);

sub get_item {
    my ($self, $item_id) = @_;

    for (my $i = 0; $i < @{ $self->_items }; $i++) {
        my $item = $self->_items->[$i];
        if ($item->id eq "$item_id") {
            return $item;
        }
    }

    return undef;
}

sub add_item {
    my ($self, $info) = @_;

    my $item = ref $info && ref $info eq 'Business::CPI::Item' ? $info : Business::CPI::Item->new($info);

    push @{ $self->_items }, $item;

    return $item;
}

sub get_form_to_pay {
    my ($self, $payment) = @_;

    return $self->_gateway->get_form({
        payment_id => $payment,
        items      => [ @{ $self->_items } ], # make a copy for security
        buyer      => $self->buyer,
        cart       => $self,
    });
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Business::CPI::Cart - Shopping cart

=head1 VERSION

version 0.3

=head1 DESCRIPTION

Cart class for holding products to be purchased. Don't instantiate this
directly, use L<Business::CPI::Gateway::Base/new_cart> to build it.

=head1 ATTRIBUTES

=head2 buyer

The person paying for the shopping cart. See L<Business::CPI::Buyer>.

=head2 discount

Discount to be applied to the total amount. Positive number.

=head2 tax

Tax to be applied to the total amount. Positive number.

=head2 handling

Handling to be applied to the total amount. Positive number.

=head1 METHODS

=head2 add_item

Create a new Business::CPI::Item object with the given hashref, and add it to
cart.

=head2 get_item

Get item with the given id.

=head2 get_form_to_pay

Takes a payment_id as the only argument, and returns an HTML::Element form, to
submit to the gateway.

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
