package Business::CPI::Base::Receiver;
# ABSTRACT: General implementation of Receiver role
use utf8;
use Moo;

with 'Business::CPI::Role::Receiver';

our $VERSION = '0.914'; # VERSION

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Business::CPI::Base::Receiver - General implementation of Receiver role

=head1 VERSION

version 0.914

=head1 DESCRIPTION

This is the most generic implementation of the L<Business::CPI::Role::Receiver>
role. If your driver needs something more specific, it can create a new class
which uses L<< Receiver | Business::CPI::Role::Receiver >>.

=head1 SEE ALSO

L<Business::CPI::Role::Receiver>

=for Pod::Coverage BUILDARGS

=head1 AUTHOR

André Walker <andre@andrewalker.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by André Walker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
