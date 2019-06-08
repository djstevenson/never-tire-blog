package NeverTire::Schema::ResultSet::Comment;
use Moose;
use MooseX::NonMoose;
extends 'DBIx::Class::ResultSet';

# POD docs at end of this source file

use Carp qw/ croak /;

use DateTime;

sub where_approved {
    my $self = shift;

    return $self->search({
        approved_at => { '!=' => undef }
    });
}

sub id_order {
    my $self = shift;

    return $self->search(undef, {
        order_by => { -asc => 'id' }
    });
}

__PACKAGE__->meta->make_immutable;
1;

=pod

=head1 NAME

NeverTire::Schema::ResultSet::Comment : ResultSet subclass for song comments

=head1 SYNOPSIS

    my $rs = $schema->resultset('Comment');
    $rs->select_approved-> ...;

=head1 DESCRIPTION

ResultSet methods for Comments

=head1 METHODS

=over

=item where_approved

Adds a clause to the resultset so that only
approved comments are selected.

=item id_order

Order by id ascending.

=back

=head1 AUTHOR

David Stevenson david@ytfc.com

=cut

