package SongsToTheSiren::Schema::Role::User::Auth;
use utf8;
use Moose::Role;

# TODO Add pod

use Carp;
use DateTime;
use DateTime::Duration;
use SongsToTheSiren::Util::Password 'new_password_hash',
    'check_password_hash' => {-as => 'util_check_password_hash'},
    'random_user_key';

# This exists just to keep Result::User down to a more manageable size.
# It extracts the methods relating to authentication, key management, etc

# Returns boolean, meaning 'key is valid for this user/purpose'
# Calling controller probably wants to return a 404 Not Found
# if this returns
sub check_key {
    my ($self, $purpose, $user_user_key) = @_;

    croak 'Missing registration key' unless $user_user_key;

    my $user_key_rs = $self->result_source->schema->resultset('UserKey');
    my $key_obj     = $user_key_rs->find_key($self, $purpose);

    return unless $key_obj;

    return unless util_check_password_hash($user_user_key, $key_obj->key_hash);

    if ($key_obj->expires_at->compare(DateTime->now) < 0) {
        $key_obj->delete;
        return;
    }

    return 1;
}

sub find_key {
    my ($self, $purpose) = @_;

    my $user_key_rs = $self->result_source->schema->resultset('UserKey');
    return $user_key_rs->find({user_id => $self->id, purpose => $purpose});
}

sub delete_key {
    my ($self, $purpose) = @_;

    my $k = $self->find_key($purpose);
    $k->delete if $k;

    return;
}

sub update_password {
    my ($self, $password) = @_;

    $self->update({password_hash => new_password_hash($password),});

    # Delete key to prevent re-use
    $self->delete_key('password_reset');

    return;
}

sub generate_new_user_key {
    my ($self, $purpose, $duration) = @_;

    # TODO Sort out exports from SongsToTheSiren::Util::Password
    my $key = random_user_key();

    my $user_key_rs = $self->result_source->schema->resultset('UserKey');
    $user_key_rs->create_key({user_id => $self->id, key => $key, purpose => $purpose, duration => $duration,});

    # Yes, returns the plain text key, not the hash. This is what
    # we need to embed in (say) registration emails
    return $key;
}

sub confirm_registration {
    my ($self, $user_key) = @_;

    return unless $self->check_key('registration', $user_key);

    # Do nothing if already confirmed
    if (!$self->confirmed_at) {
        $self->update({confirmed_at => DateTime->now});
    }

    $self->delete_key('registration');

    return 1;
}

sub decline_registration {
    my ($self, $user_key) = @_;

    return unless $self->check_key('registration', $user_key);

    # Don't care if already confirmed or not, zap it.
    # This will cascade to key deletion
    $self->delete;

    return 1;
}


no Moose::Role;
1;

