package SongsToTheSiren::Form::Link::Edit;
use utf8;
use Moose;
use namespace::autoclean;

use SongsToTheSiren::Form::Moose;
extends 'SongsToTheSiren::Form::Base';
with 'SongsToTheSiren::Form::Role';

has '+id' => (default => 'edit-link');

has song => (
    is        => 'ro',
    isa       => 'SongsToTheSiren::Schema::Result::Song',
    required  => 1,
);

has link => (
    is        => 'ro',
    isa       => 'SongsToTheSiren::Schema::Result::Link',
    predicate => 'is_update',
);


has_field embed_identifier => (
    type           => 'Input::Text',
    autofocus      => 1,
    filters        => [qw/ TrimEdges /],
    autocomplete   => 'off',
    spellcheck     => 'false',
    autocapitalize => 'off',
);

has_field embed_url => (
    type    => 'Input::Text',
    filters => [qw/ TrimEdges /],
);

has_field embed_class => (
    type       => 'Select',
    selections => sub {
        my ($field, $form) = @_;

        my $app   = $form->c->app;
        my $roles = $app->config->{link_roles};

        return [map { {value => $_, text => $_} } @{ $roles }];
    },
);

has_field embed_description => (
    type         => 'Input::Text',
    filters      => [qw/ TrimEdges /],
    autocomplete => 'off',
);


has_field list_priority => (
    type         => 'Input::Text',
    filters      => [qw/ TrimEdges /],
    validators   => [qw/ ValidInteger /],
    autocomplete => 'off',
    inputmode    => 'numeric',
);

has_field list_url => (
    type    => 'Input::Text',
    filters => [qw/ TrimEdges /]
);

has_field list_css => (
    type       => 'Select',
    selections => sub {
        my ($field, $form) = @_;

        my $app   = $form->c->app;
        my $css   = $app->config->{link_css};

        return [map { {value => $_, text => $_} } @{ $css }];
    },
);

has_field list_description => (
    type         => 'Input::Text',
    filters      => [qw/ TrimEdges /],
    autocomplete => 'off',
);

has_button submit => ();
has_button cancel => (style => 'light', skip_validation => 1);

# Identifier must not already exist for this song. However,
# if we're not changing it in this edit, then it'll already exist
# in this link. So the check is "does it exist in this song for
# any other link". Obvs skip this for create, where we always need
# dupe detection
after extra_validation => sub {
    my $self = shift;

    my $fail;

    my $links       = $self->song->links;
    my $identifiers = $links->embedded_links->by_identifier;

    my $identifier_field = $self->find_field('embed_identifier');
    my $identifier_value = lc $identifier_field->value;

    $fail = 'Identifier already used for this song'
        if exists $identifiers->{$identifier_value}
        && (!$self->is_update || $identifiers->{$identifier_value}->id != $self->link->id);

    # Set the error on 'identifier' if we don't already have one
    $identifier_field->error($fail) if $fail && !$identifier_field->has_error;
};

override posted => sub {
    my $self = shift;

    my $update_button = $self->find_button('submit');
    if ($update_button->clicked) {

        my $user = $self->c->stash->{auth_user};

        # Whitelist what we extract from the submitted form
        my $fields = $self->form_hash(
            qw/ embed_identifier embed_class embed_url embed_description list_priority list_url list_description list_css /
        );

        # Create or update?
        if ($self->is_update) {

            # Update
            $self->link->update($fields);
            $self->song->render_markdown;
            $self->action('updated');
        }
        else {
            # Create
            $self->song->add_link($fields);
            $self->song->render_markdown;
        }
    }

    return 1;
};

# Prepopulate GET form from the song object
sub BUILD {
    my $self = shift;

    if ($self->is_update) {
        $self->data_object($self->link);
    }

    return;
}

__PACKAGE__->meta->make_immutable;
1;
