package NeverTire::Form::Song::Edit;
use Moose;
use namespace::autoclean;


# TODO Loadsa dupe code with Song::Create form, can we put most of this in a base class or something?

use NeverTire::Form::Moose;
extends 'NeverTire::Form::Base';
with 'NeverTire::Form::Role';

has '+id' => (default => 'edit-song');

has song => (
    is          => 'ro',
    isa         => 'NeverTire::Schema::Result::Song',
    required    => 1,
);

has_field title => (
    type        => 'Input::Text',
    autofocus   => 1,
    filters     => [qw/ TrimEdges /],
    validators  => [qw/ Required  /],
);

has_field artist => (
    type        => 'Input::Text',
    filters     => [qw/ TrimEdges /],
    validators  => [qw/ Required  /],
);

has_field album => (
    type        => 'Input::Text',
    filters     => [qw/ TrimEdges /],
    validators  => [qw/ Required  /],
);

has_field image => (
    type        => 'Input::Text',
    filters     => [qw/ TrimEdges /],
    validators  => [qw/ Required  /],
);

# TODO Dupe code with create function. Sort this out.
has_field country_id => (
    type        => 'Select',
    label       => 'Country',
    selections  => sub {
        my ($field, $form) = @_;

        return $form->c->schema
            ->resultset('Country')
            ->as_select_options;
    },
);

has_field released_at => (
    label       => 'Date Released',
    type        => 'Input::Text',
    filters     => [qw/ TrimEdges /],
    validators  => [qw/ Required  /],
);


has_field summary_markdown => (
    label       => 'Summary',
    type        => 'Input::TextArea',
    filters     => [qw/ TrimEdges /],
    validators  => [qw/ Required  /],
    data        => {
        'markdown-preview' => 'markdown-preview-summary',
    },
);

has_field summary_preview => (
    type        => 'Html',
    options     => {
        html => q{<div id="markdown-preview-summary" class="markdown summary markdown-preview"></div>},
    },
);

has_field full_markdown => (
    label       => 'Full Description',
    type        => 'Input::TextArea',
    filters     => [qw/ TrimEdges /],
    validators  => [qw/ Required  /],
    data        => {
        'markdown-preview' => 'markdown-preview-full',
    },
);

has_field full_preview => (
    type        => 'Html',
    options     => {
        html => q{<div id="markdown-preview-full" class="markdown full markdown-preview"></div>},
    },
);

has_button update_song => ();
has_button cancel => (style => 'light', skip_validation => 1);

override posted => sub {
	my $self = shift;

    my $update_button = $self->find_button('update_song');
    if ( $update_button->clicked ) {
        my $user = $self->c->stash->{auth_user};

        # Whitelist what we extract from the submitted form
        my $fields = $self->form_hash(qw/ title album artist image country_id released_at summary_markdown full_markdown /);
        $user->admin_edit_song($self->song, $fields);
        $self->action('updated');
    }

    return 1;
};

# Prepopulate GET form from the song object
sub BUILD {
    my $self = shift;

 	$self->data_object($self->song);
}

__PACKAGE__->meta->make_immutable;
1;
