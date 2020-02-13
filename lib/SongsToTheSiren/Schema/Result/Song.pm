package SongsToTheSiren::Schema::Result::Song;
use Moose;
use namespace::autoclean;

extends 'SongsToTheSiren::Schema::Base::Result';

# TODO POD

use SongsToTheSiren::Model::Comment::Forest qw/ make_forest /;

use DateTime;
use Text::Markdown qw/ markdown /;

__PACKAGE__->load_components('InflateColumn::DateTime');

__PACKAGE__->table('songs');

__PACKAGE__->add_columns(
    id               => {data_type => 'INTEGER'},
    artist           => {data_type => 'TEXT'},
    title            => {data_type => 'TEXT'},
    album            => {data_type => 'TEXT'},
    image            => {data_type => 'TEXT'},
    country_id       => {data_type => 'INTEGER'},

    summary_markdown => {data_type => 'TEXT'},
    summary_html     => {data_type => 'TEXT'},
    full_markdown    => {data_type => 'TEXT'},
    full_html        => {data_type => 'TEXT'},

    author_id        => {data_type => 'INTEGER'},

    created_at       => {data_type => 'DATETIME'},
    updated_at       => {data_type => 'DATETIME'},
    published_at     => {data_type => 'DATETIME'},

    # TEXT so it can be free-format, e.g. "summer 1991"
    released_at      => {data_type => 'TEXT'},
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( author    => 'SongsToTheSiren::Schema::Result::User',     { 'foreign.id' => 'self.author_id'  }, { join_type	=> 'LEFT' } );
__PACKAGE__->belongs_to( country   => 'SongsToTheSiren::Schema::Result::Country',  { 'foreign.id' => 'self.country_id' }, { join_type	=> 'LEFT' } );

__PACKAGE__->has_many  ( song_tags => 'SongsToTheSiren::Schema::Result::SongTag',  { 'foreign.song_id' => 'self.id'    });
__PACKAGE__->has_many  ( comments  => 'SongsToTheSiren::Schema::Result::Comment',  { 'foreign.song_id' => 'self.id'    });
__PACKAGE__->has_many  ( links     => 'SongsToTheSiren::Schema::Result::Link',     { 'foreign.song_id' => 'self.id'    });

__PACKAGE__->many_to_many( tags => song_tags => 'tags');

sub approved_comments {
    my $self = shift;

    return $self->comments->search({ approved_at => { '!=' => undef }});
}

sub show {
    my $self = shift;
    $self->update({ published_at => \'NOW()' });
    $self->discard_changes;
}

sub hide {
    shift->update({ published_at => undef });
}

sub add_tag {
    my ($self, $tag_name) = @_;

    my $rs = $self->result_source->schema->resultset('Tag');
    my $tag = $rs->find_or_create({ name => $tag_name });

    $rs = $self->result_source->schema->resultset('SongTag');
    return $rs->find_or_create({
        tag_id  => $tag->id,
        song_id => $self->id,
    });
}

sub delete_tag {
    my ($self, $tag) = @_;

    $self->song_tags->search({
        tag_id => $tag->id
    })->delete;

    # Remove if no-longer associated with any songs
    $tag->delete if $tag->songs->count == 0;
}

# TODO DOCUMENT THIS
# Returns reference to ordered array of
# SongsToTheSiren::Model::Comment::Node
#
# Unmoderated comments are included IFF $admin is
# true.
sub get_comment_forest {
    my ($self, $user) = @_;

    return make_forest($self, $user);
}

sub add_link {
    my ($self, $values) = @_;

    return $self->links->create({
        identifier  => $values->{identifier},
        class       => $values->{class},
        url         => $values->{url},
        description => $values->{description},
        priority    => $values->{priority},
        extras      => $values->{extras},
    });
}

sub render_markdown {
    my $self = shift;

    my $processor = SongsToTheSiren::Markdown->new( song => $self );
    $self->update({
        full_html    => $processor->markdown($self->full_markdown),
        summary_html => $processor->markdown($self->summary_markdown),
    });
}

# returns {
#    newer => $next_newer_song,
#    older => $next_older_song,
# }
# Either song can be undef (no older/newer song).

sub get_navigation {
    my $self = shift;

    return {
        newer => $self->newer,
        older => $self->older,
    };
}

sub newer {
    my $self = shift;

    return $self
        ->result_source
        ->resultset
        ->newer($self)
        ->where_published
        ->single;
}

sub older {
    my $self = shift;

    return $self
        ->result_source
        ->resultset
        ->older($self)
        ->where_published
        ->single;
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;