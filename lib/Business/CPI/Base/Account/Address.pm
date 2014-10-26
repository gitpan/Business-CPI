package Business::CPI::Base::Account::Address;
# ABSTRACT: General implementation of Account::Address role
use utf8;
use Moo;
with 'Business::CPI::Role::Account::Address';

our $VERSION = '0.909'; # TRIAL VERSION

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Business::CPI::Base::Account::Address - General implementation of Account::Address role

=head1 VERSION

version 0.909

=head1 DESCRIPTION

This is the most generic implementation of the
L<Business::CPI::Role::Account::Address> role. If your driver needs something
more specific, it can create a new class which uses
L<< Account::Address | Business::CPI::Role::Account::Address >>.

=head1 SEE ALSO

L<Business::CPI::Role::Account::Address>

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
