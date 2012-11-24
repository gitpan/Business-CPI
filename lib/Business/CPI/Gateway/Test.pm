package Business::CPI::Gateway::Test;
# ABSTRACT: Fake gateway

use Moo;

extends 'Business::CPI::Gateway::Base';

sub get_hidden_inputs {
    my ( $self, $info ) = @_;

    my @hidden_inputs = (
        receiver_email => $self->receiver_email,
        currency       => $self->currency,
        encoding       => $self->form_encoding,
        payment_id     => $info->{payment_id},
        buyer_name     => $info->{buyer}->name,
        buyer_email    => $info->{buyer}->email,
    );

    my $i = 1;

    foreach my $item (@{ $info->{items} }) {
        push @hidden_inputs,
          (
            "item${i}_id"    => $item->id,
            "item${i}_desc"  => $item->description,
            "item${i}_price" => $item->price,
            "item${i}_qty"   => $item->quantity,
          );
        $i++;
    }

    return @hidden_inputs;
}

# TODO
# use SQLite?
# sub get_notification_details {}
# sub query_transactions {}
# sub get_transaction_details {}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Business::CPI::Gateway::Test - Fake gateway

=head1 VERSION

version 0.1

=head1 DESCRIPTION

Used only for testing. See the t/ directory in this distribution.

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
