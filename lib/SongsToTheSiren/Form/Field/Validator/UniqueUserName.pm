package SongsToTheSiren::Form::Field::Validator::UniqueUserName;
use utf8;
use Moose;
use namespace::autoclean;

extends 'SongsToTheSiren::Form::Field::Validator::Base';
with 'SongsToTheSiren::Form::Field::Validator::Role';

sub validate {
    my ($self, $value) = @_;

    my $users_rs = $self->schema->resultset('User');
    my $found    = $users_rs->find_by_name($value);

    return 'Name already in use' if $found;
    return undef;
}


__PACKAGE__->meta->make_immutable;
1;
