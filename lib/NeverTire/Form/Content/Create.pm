package NeverTire::Form::Content::Create;
use Moose;
use namespace::autoclean;

use NeverTire::Form::Moose;
extends 'NeverTire::Form::Base';
with 'NeverTire::Form::Role';

has '+id' => (default => 'new-content');

has_field name => (
    type        => 'Input::Text',
    autofocus   => 1,
    filters     => [qw/ TrimEdges /],
    validators  => [qw/ Required UniqueContentName /],
);

has_field title => (
    type        => 'Input::Text',
    filters     => [qw/ TrimEdges /],
    validators  => [qw/ Required  /],
);

has_field markdown => (
    label       => 'Summary',
    type        => 'Input::TextArea',
    filters     => [qw/ TrimEdges /],
    validators  => [qw/ Required  /],
);

has_field preview => (
    type        => 'Html',
    options     => {
        html => q{<div id="markdown-content-preview" class="markdown markdown-preview">Preview here</div>},
    },
);

has_button create_content => ();

override posted => sub {
	my $self = shift;

	my $user = $self->c->stash->{auth_user};

    # Whitelist what we extract from the submitted form
	my $fields = $self->form_hash(qw/ name title markdown /);
	return $user->admin_create_content($fields);
};

__PACKAGE__->meta->make_immutable;
1;