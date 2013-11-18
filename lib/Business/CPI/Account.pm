package Business::CPI::Account;
# ABSTRACT: Manage accounts in the gateway
use Moo;
use utf8;
use DateTime;
use Email::Valid;
use Scalar::Util qw/blessed/;
use Class::Load ();

our $VERSION = '0.904'; # VERSION

has _gateway => ( is => 'rw' );

has id => ( is => 'rw' );

# TODO: create "name"
has first_name => ( is => 'rw' );
has last_name => ( is => 'rw' );

has phone => ( is => 'rw' );

# TODO: Validate this? URI.pm seems to accept anything
has return_url => ( is => 'rw' );

has email => (
    is => 'rw',
    isa => sub {
        die "Must be a valid e-mail address"
            unless Email::Valid->address( $_[0] );
    }
);

has birthday => (
    is => 'rw',
    isa => sub {
        die "Must be a DateTime object"
            unless blessed $_[0] && $_[0]->isa('DateTime');
    }
);

has address => ( is => 'rw' );

has business => ( is => 'rw' );

around address => sub {
    my $orig = shift;
    my $self = shift;

    if (my $new_address = shift) {
        return $self->$orig( $self->_inflate_address($new_address) );
    }

    return $self->$orig();
};

around business => sub {
    my $orig = shift;
    my $self = shift;

    if (my $new_business = shift) {
        return $self->$orig( $self->_inflate_business($new_business) );
    }

    return $self->$orig();
};

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my $args  = $class->$orig(@_);

    if (exists $args->{business}) {
        $args->{business} = $class->_inflate_business($args->{business}, $args->{_gateway});
    }

    if (exists $args->{address}) {
        $args->{address} = $class->_inflate_address($args->{address}, $args->{_gateway});
    }

    return $args;
};

sub _inflate_comp {
    my ($self, $which, $comp, $gateway) = @_;

    my $default_class = "Business::CPI::Account::$which";

    if (!$gateway && ref $self) {
        $gateway = $self->_gateway;
    }
    elsif ( !$gateway ) {
        Class::Load::load_class($default_class);
        return $default_class->new($comp);
    }

    my $gateway_name = (split /::/, ref $gateway)[-1];
    my $comp_class = Class::Load::load_first_existing_class(
        "${default_class}::${gateway_name}",
        "${default_class}"
    );

    $comp->{_gateway} = $gateway;

    return $comp_class->new($comp);
}

sub _inflate_address {
    my $self = shift;
    return $self->_inflate_comp("Address", @_);
}

sub _inflate_business {
    my $self = shift;
    return $self->_inflate_comp("Business", @_);
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Business::CPI::Account - Manage accounts in the gateway

=head1 VERSION

version 0.904

=head1 SYNOPSIS

    # build the gateway object
    my $cpi = Business::CPI->new( gateway => 'Whatever', ... );

    # get data of the account about to be created
    # instead of Reseller, it could be a client, or data from a form, etc
    my $row = $db->resultset('Reseller')->find(5324);

    # create the object in the gateway
    $cpi->create_account({
        id         => $row->id,
        first_name => $row->name,
        last_name  => $row->surname,
        email      => $row->email,
        birthday   => $row->birthday,
        phone      => $row->phone,
        return_url => $myapp->root_url . '/gateway_account_created',
    });

    # hardcoded data
    $cpi->create_account({
        id         => 43125,
        first_name => 'John',
        last_name  => 'Smith',
        email      => 'john@smith.com',
        birthday   => DateTime->now->subtract(years => 25),
        phone      => '11 00001111',
        address    => {
            street     => 'Av. Paulista',
            number     => '123',
            complement => '7º andar',
            district   => 'Bairro X',
            city       => 'São Paulo',
            state      => 'SP',
            country    => 'br',
        },
        business => {
            corporate_name => 'MyCompany Ltd.',
            trading_name   => 'MyCompany',
            phone          => '11 11110000',
            address        => {
                street     => 'Alameda Santos',
                number     => '321',
                complement => '3º andar',
                district   => 'Bairro Y',
                city       => 'São Paulo',
                state      => 'SP',
                country    => 'br',
            },
        },
        return_url => 'http://mrsmith.com',
    });

=head1 DESCRIPTION

This class is used internally by the gateway to build objects representing a
person's account in the gateway. In general, the end-user shouldn't have to
instantiate this directly, but use the helper methods in the gateway main
class. See the L</SYNOPSIS> for an example, and be sure to check the gateway
driver documentation for specific details and examples.

=head1 ATTRIBUTES

=head2 id

The id of the person who owns this account (or will own it, if it's being
created) in the database of the application using L<Business::CPI>. This is
irrelevant for the gateway, but they store it for an easy way for the
application to associate the gateway accounts to the application records.

=head2 first_name

Individual's first name.

=head2 last_name

Individual's last name.

=head2 email

E-mail address of the individual.

=head2 phone

Phone number of the individual.

=head2 birthday

The date the person was born. Must be a DateTime object.

=head2 address

See L<Business::CPI::Account::Address>. You should provide a
HashRef with the attributes, according to the
L<< Address | Business::CPI::Account::Address >>
class, and it will be inflated for you.

=head2 business

See L<Business::CPI::Account::Business>. You should provide a
HashRef with the attributes, according to the
L<< Business | Business::CPI::Account::Business >>
class, and it will be inflated for you.

=head2 return_url

The URL the user will be redirected when the account is created.

=head1 METHODS

=head2 BUILDARGS

Used to inflate C<address> and C<business> keys in the constructor.

=head1 SPONSORED BY

Estante Virtual - L<http://www.estantevirtual.com.br>

=head1 SEE ALSO

L<Business::CPI>, L<Business::CPI::Account::Address>,
L<Business::CPI::Account::Business>, L<Business::CPI::Buyer>

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
