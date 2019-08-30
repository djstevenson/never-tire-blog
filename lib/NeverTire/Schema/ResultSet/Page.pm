package NeverTire::Schema::ResultSet::Page;
use Moose;
use MooseX::NonMoose;
extends 'DBIx::Class::ResultSet';

# POD docs at end of this source file

use Carp qw/ croak /;

use DateTime;

sub find_by_name {
    my ($self, $name) = @_;

    return $self->search({ name => $name} )->single;
}

sub by_name {
    my ($self, $order) = @_;

    $order //= '-asc';

    return $self->search(undef, {
        order_by => { $order => 'name' }
    });
}

__PACKAGE__->meta->make_immutable;
1;

=pod

=head1 NAME

NeverTire::Schema::ResultSet::Page : ResultSet subclass for pages

=head1 SYNOPSIS

    my $rs = $schema->resultset('Page');
    $rs->search({})->by_name;

=head1 DESCRIPTION

ResultSet methods for pages

=head1 METHODS

=over

=item find_by_name($name)

Returns the unique result object with the specified name,
or undef if not found.

=item by_name($optional_direction)

Sorts the resultset by name in ascending alpha order. 
Pass '-desc' as the arg if you want the reverse

    $page_rs->by_name;           # Sort asc
    $page_rs->by_name('-desc');  # Sort desc

=back

=head1 AUTHOR

David Stevenson david@ytfc.com

=cut
