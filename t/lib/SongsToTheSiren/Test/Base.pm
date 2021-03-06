package SongsToTheSiren::Test::Base;
use utf8;
use Moose;
use namespace::autoclean;

use SongsToTheSiren::Test::Database;

use Test::Mojo;

has test_app => (
    is          => 'ro',
    isa         => 'Test::Mojo',
    lazy        => 1,
    init_arg    => undef,
    default     => sub {
        my $self = shift;

        my $opts = { db_name => $self->database->db_name };
        return Test::Mojo->new(SongsToTheSiren => $opts)
    },
);

has app => (
    is          => 'ro',
    isa         => 'SongsToTheSiren',
    lazy        => 1,
    init_arg    => undef,
    default     => sub {
        my $self = shift;

        return $self->test_app->app;
    },
);

has schema => (
    is          => 'ro',
    isa         => 'SongsToTheSiren::Schema',
    lazy        => 1,
    init_arg    => undef,
    default     => sub {
        return shift->app->schema;
    },
);

has database => (
    is          => 'ro',
    isa         => 'SongsToTheSiren::Test::Database',
    lazy        => 1,
    init_arg    => undef,
    builder     => '_build_database',
);

sub create_country {
    my ($self, $name) = @_;

    my $schema = $self->schema;
    my $country_rs = $schema->resultset('Country');
    return $country_rs->create({
        name          => $name,
        emoji         => "$name$name",
    });
}

# Low-level create, bypassses registration
sub create_user {
    my ($self, $user_data) = @_;

    $user_data //= $self->get_user_data;

    my $schema = $self->schema;
    my $user_rs = $schema->resultset('User');
    return $user_rs->create_user({
        name          => $user_data->{name},
        email         => lc($user_data->{email}),
        password      => $user_data->{password},
        admin         => 0,
    });
}

# Low-level create, bypassses registration
sub create_admin_user {
    my ($self, $user_data) = @_;

    $user_data //= $self->get_user_data;

    my $schema = $self->schema;
    my $user_rs = $schema->resultset('User');
    return $user_rs->create_user({
        name          => $user_data->{name},
        email         => lc($user_data->{email}),
        password      => $user_data->{password},
        admin         => 1,
    });
}

has user_base => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

sub _build_database {
    my $self = shift;

    return SongsToTheSiren::Test::Database->new(
        test_name => $self->user_base,
    );
}

has __user_id => (
    is          => 'rw',
    isa         => 'Int',
    default     => 0,
);

sub get_user_data {
    my $self = shift;

    my $user_base = $self->user_base;

    my $user_id = $self->__user_id + 1;
    $self->__user_id($user_id);

    my $format = $user_base . '%03d';
    my $name = ucfirst(sprintf($format, $user_id));
    $name =~ s/_/ /g;

    my $email = ucfirst(sprintf($format . '@example.com', $user_id));
    my $password = sprintf('PW ' . $format, $user_id);

    # e.g. name='Model user 001'
    #      email='model_user_001@example.com'
    #      password='PW model_user_001';
    return {
        name => $name,
        email => $email,
        password => $password,
    };
}

sub DEMOLISH {
    my $self = shift;

    $self->schema->storage->disconnect;
}

__PACKAGE__->meta->make_immutable;
1;
