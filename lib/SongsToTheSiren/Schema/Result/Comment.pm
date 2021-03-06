package SongsToTheSiren::Schema::Result::Comment;
use utf8;
use Moose;
use namespace::autoclean;

extends 'SongsToTheSiren::Schema::Base::Result';

# TODO POD

use DateTime;

__PACKAGE__->load_components('InflateColumn::DateTime');

__PACKAGE__->table('comments');

__PACKAGE__->add_columns(
    id        => {data_type => 'INTEGER', is_auto_increment => 1 },
    song_id   => {data_type => 'INTEGER'},
    author_id => {data_type => 'INTEGER'},

    parent_id => {data_type => 'INTEGER'},

    comment_bbcode => {data_type => 'TEXT'},
    comment_html   => {data_type => 'TEXT'},

    created_at  => {data_type => 'DATETIME'},
    approved_at => {data_type => 'DATETIME'},
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(author => 'SongsToTheSiren::Schema::Result::User', {'foreign.id' => 'self.author_id'});

__PACKAGE__->belongs_to(parent => 'SongsToTheSiren::Schema::Result::Comment', {'foreign.id' => 'self.parent_id'});
__PACKAGE__->has_many(replies => 'SongsToTheSiren::Schema::Result::Comment', {'foreign.parent_id' => 'self.id'});

__PACKAGE__->belongs_to(song => 'SongsToTheSiren::Schema::Result::Song', {'foreign.id' => 'self.song_id'});

__PACKAGE__->has_many(edits => 'SongsToTheSiren::Schema::Result::CommentEdit', {'foreign.comment_id' => 'self.id'});

# Newest first
sub edits_by_date {
    return shift->edits->search(undef, {order_by => {-desc => 'id'}});
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
