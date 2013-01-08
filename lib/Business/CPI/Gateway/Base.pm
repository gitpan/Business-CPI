package Business::CPI::Gateway::Base;
# ABSTRACT: Father of all gateways
use Moo;
use Carp;
use Locale::Currency ();
use Email::Valid ();
use List::Util ();
use Business::CPI::Cart;
use Business::CPI::Buyer;
use HTML::Element;

our $VERSION = '0.3'; # VERSION

has name => (
    is      => 'ro',
#    isa     => 'Str',
    default => sub {
        my $self  = shift;
        my $class = ref $self;
        my @parts = split '::', $class;
        return lc( pop @parts );
    },
);

has receiver_email => (
    isa => sub {
        Email::Valid->address( $_[0] ) || die "Must be a valid e-mail address";
    },
    is => 'ro',
);

has currency => (
    isa => sub {
        my $curr = uc( $_[0] );
        my @codes = Locale::Currency::all_currency_codes();
        List::Util::first { $curr eq uc($_) } @codes
          || die "Must be a valid currency code";
    },
    coerce => sub { uc $_[0] },
    is => 'ro',
);

has checkout_url => (
    is => 'ro',
);

has checkout_form_http_method => (
    is => 'ro',
    default => sub { 'post' },
);

has checkout_form_submit_name => (
    is => 'ro',
    default => sub { 'submit' },
);

has checkout_form_submit_value => (
    is => 'ro',
    default => sub { '' },
);

has form_encoding => (
    is      => 'ro',
    # TODO: use Encode::find_encoding()
    default => sub { 'UTF-8' },
);

# TODO: submit image

sub new_cart {
    my ( $self, $info ) = @_;

    my @items =
      map { ref $_ eq 'Business::CPI::Item' ? $_ : Business::CPI::Item->new($_) }
      @{ delete $info->{items} || [] };

    my $buyer = Business::CPI::Buyer->new( delete $info->{buyer} );

    return Business::CPI::Cart->new(
        _gateway => $self,
        _items   => \@items,
        buyer    => $buyer,
        %$info,
    );
}

sub get_hidden_inputs { () }

sub get_form {
    my ($self, $info) = @_;

    my @hidden_inputs = $self->get_hidden_inputs($info);

    my $form = HTML::Element->new(
        'form',
        action => $self->checkout_url,
        method => $self->checkout_form_http_method,
    );

    while (@hidden_inputs) {
        $form->push_content(
            HTML::Element->new(
                'input',
                type  => 'hidden',
                value => pop @hidden_inputs,
                name  => pop @hidden_inputs
            )
        );
    }

    my @value = ();
    if (my $value = $self->checkout_form_submit_value) {
        @value = (value => $value);
    }

    $form->push_content(
        HTML::Element->new(
            'input',
            type  => 'submit',
            name  => $self->checkout_form_submit_name,
            @value
        )
    );

    return $form;
}

sub get_notification_details {}

sub query_transactions {}

sub get_transaction_details {}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Business::CPI::Gateway::Base - Father of all gateways

=head1 VERSION

version 0.3

=head1 ATTRIBUTES

=head2 name

Name of the gateway (e.g. paypal).

=head2 receiver_email

E-mail of the business owner.

=head2 currency

Currency code, such as BRL, EUR, USD, etc.

=head2 notification_url

The url for the gateway to postback, notifying payment changes.

=head2 return_url

The url for the customer to return to, after they finished the payment.

=head2 checkout_url

The url the application will post the form to. Defined by the gateway.

=head2 checkout_form_http_method

Defaults to post.

=head2 checkout_form_submit_name

Defaults to submit.

=head2 checkout_form_submit_value

Defaults to ''.

=head2 form_encoding

Defaults to UTF-8.

=head1 METHODS

=head2 new_cart

Creates a new L<Business::CPI::Cart> connected to this gateway.

=head2 get_form

Get the form to checkout. Use the method in L<Business::CPI::Cart>, don't use
this method directly.

=head2 get_notification_details

Get the payment notification (such as PayPal's IPN), and return a hashref with
the details.

=head2 query_transactions

Search past transactions.

=head2 get_transaction_details

Get more details about a given transaction.

=head2 get_hidden_inputs

This method is called when building the checkout form. It will return a hashref
with the field names and field values for the form. This way the gateway will
implement only this method, while the rest of the form will be built by this
class.

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
