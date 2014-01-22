package Business::CPI::Role::Cart;
# ABSTRACT: Shopping cart or an order

use Moo::Role;
use Scalar::Util qw/blessed/;
use Carp qw/croak/;
use Business::CPI::Util::Types qw/Money to_Money/;

our $VERSION = '0.913'; # VERSION

has id => ( is => 'rw' );
has gateway_id => ( is => 'rw' );

has buyer => (
    is  => 'ro',
    isa => sub {
        $_[0]->does('Business::CPI::Role::Buyer')
          or $_[0]->does('Business::CPI::Role::Account')
          or die "Must implement Business::CPI::Role::Buyer or Business::CPI::Role::Account";
    },
);

has tax => (
    coerce  => \&to_Money,
    isa     => Money,
    is      => 'rw',
    default => sub { 0 },
);

has handling => (
    coerce  => \&to_Money,
    isa     => Money,
    is      => 'rw',
    default => sub { 0 },
);

has discount => (
    coerce  => \&to_Money,
    isa     => Money,
    is      => 'rw',
    default => sub { 0 },
);

has _gateway => (
    is       => 'ro',
    required => 1,
    isa      => sub {
        $_[0]->isa('Business::CPI::Gateway::Base')
          or die "Must be a Business::CPI::Gateway::Base";
    },
);

has _items => (
    is => 'ro',
    default => sub { [] },
);

has _receivers => (
    is => 'ro',
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

    if (blessed $info) {
        croak q|Usage: $cart->add_item({ ... })|;
    }

    my $item = $self->_gateway->item_class->new($info);

    push @{ $self->_items }, $item;

    return $item;
}

sub add_receiver {
    my ($self, $info) = @_;

    if (blessed $info) {
        croak q|Usage: $cart->add_receiver({ ... })|;
    }

    my $gateway = $self->_gateway;
    $info->{_gateway} = $gateway;

    my $item = $gateway->receiver_class->new($info);

    push @{ $self->_receivers }, $item;

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


sub get_checkout_code {
    my ($self, $payment) = @_;

    return $self->_gateway->get_checkout_code({
        payment_id => $payment,
        items      => [ @{ $self->_items } ],
        buyer      => $self->buyer,
        cart       => $self,
    });
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Business::CPI::Role::Cart - Shopping cart or an order

=head1 VERSION

version 0.913

=head1 DESCRIPTION

Cart class for holding products to be purchased. Don't instantiate this
directly, use L<Business::CPI::Gateway::Base/new_cart> to build it.

=head1 ATTRIBUTES

=head2 id

The id of the cart, if your application has one set for it.

=head2 gateway_id

The id your gateway has set for this cart, if there is one.

=head2 buyer

The person paying for the shopping cart. See L<Business::CPI::Role::Buyer> or
L<Business::CPI::Role::Account>.

=head2 discount

Discount to be applied to the total amount. Positive number.

=head2 tax

Tax to be applied to the total amount. Positive number.

=head2 handling

Handling to be applied to the total amount. Positive number.

=head1 METHODS

=head2 add_item

Create a new L<< Item | Business::CPI::Role::Item >> object with the given
hashref, and add it to cart.

=head2 add_receiver

Create a new L<< Receiver | Business::CPI::Role::Receiver >> object with the
given hashref, and add it to cart.

=head2 get_item

Get item with the given id.

=head2 get_form_to_pay

Takes a payment_id as the only argument, and returns an L<HTML::Element> form,
to submit to the gateway.

=head2 get_checkout_code

Very similar to get_form_to_pay, C<< $cart->get_checkout_code >> will send to
the gateway this cart, and return a token for it, so that the payment will be
made referring to this token. It receives the same arguments as
get_form_to_pay.

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
