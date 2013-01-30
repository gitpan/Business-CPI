package Business::CPI::Gateway::Base;
# ABSTRACT: Father of all gateways
use Moo;
use Locale::Currency ();
use Email::Valid ();
use Business::CPI::EmptyLogger;
use Class::Load qw/load_first_existing_class/;
use HTML::Element;
use Data::Dumper;

our $VERSION = '0.903'; # VERSION

has receiver_email => (
    isa => sub {
        die "Must be a valid e-mail address"
            unless Email::Valid->address( $_[0] );
    },
    is => 'ro',
);

has currency => (
    isa => sub {
        my $curr = uc($_[0]);

        for (Locale::Currency::all_currency_codes()) {
            return 1 if $curr eq uc($_);
        }

        die "Must be a valid currency code";
    },
    coerce => sub { uc $_[0] },
    is => 'ro',
);

has log => (
    is => 'ro',
    default => sub { Business::CPI::EmptyLogger->new },
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

    if ($self->log->is_debug) {
        $self->log->debug("Building a cart with: " . Dumper($info));
    }

    my @items =
      map { ref $_ eq 'Business::CPI::Item' ? $_ : Business::CPI::Item->new($_) }
      @{ delete $info->{items} || [] };

    my $gateway_name = (split /::/, ref $self)[-1];
    my $buyer_class  = Class::Load::load_first_existing_class(
        "Business::CPI::Buyer::$gateway_name",
        "Business::CPI::Buyer"
    );
    my $cart_class  = Class::Load::load_first_existing_class(
        "Business::CPI::Cart::$gateway_name",
        "Business::CPI::Cart"
    );

    $self->log->debug(
        "Loaded buyer class $buyer_class and cart class $cart_class."
    );

    my $buyer = $buyer_class->new( delete $info->{buyer} );

    $self->log->info("Built cart for buyer " . $buyer->email);

    return $cart_class->new(
        _gateway => $self,
        _items   => \@items,
        buyer    => $buyer,
        %$info,
    );
}

sub get_hidden_inputs { () }

sub get_form {
    my ($self, $info) = @_;

    $self->log->info("Get form for payment " . $info->{payment_id});

    my @hidden_inputs = $self->get_hidden_inputs($info);

    if ($self->log->is_debug) {
        $self->log->debug("Building form with inputs: " . Dumper(\@hidden_inputs));
        $self->log->debug("form action => " . $self->checkout_url);
        $self->log->debug("form method => " . $self->checkout_form_http_method);
    }

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

sub notify {}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Business::CPI::Gateway::Base - Father of all gateways

=head1 VERSION

version 0.903

=head1 ATTRIBUTES

=head2 receiver_email

E-mail of the business owner.

=head2 currency

Currency code, such as BRL, EUR, USD, etc.

=head2 log

Provide a logger to the gateway. It's the user's responsibility to configure
the logger. By default, nothing is logged.

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

=head2 notify

This is supposed to be called when the gateway sends a notification about a
payment status change to the application. Receives the request as a parameter
(in a CGI-compatible format), and returns data about the payment. The format is
still under discussion, and is soon to be documented.

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
