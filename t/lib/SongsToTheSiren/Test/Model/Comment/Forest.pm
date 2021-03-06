package SongsToTheSiren::Test::Model::Comment::Forest;
use utf8;
use Moose;
use namespace::autoclean;

# Tests for non-logged-in users, who should only see
# modded comments.

use utf8;

use Test::More;
use Test::Exception;
use Test::Deep qw/ cmp_deeply /;

use DateTime;

extends 'SongsToTheSiren::Test::Base';
with 'SongsToTheSiren::Test::Role';

has '+user_base' => (default => 'model_c1');

sub run {
	my $self = shift;
	
    my $admin = $self->create_admin_user;
    my $user  = $self->create_user;

	my $song_data = {
		summary_markdown => 'This is the summary',
		full_markdown    => 'This is the full article about the song',
		title            => 'The song title',
		artist           => 'The artist name',
		album            => 'Greatest hits',
		image            => 'http://example.com/image.jpg',
		country          => '🇨🇴',
		released_at      => 'Last week',
	};

	my $song = $admin->admin_create_song($song_data);

	my $first_root_comment;
	my $second_root_comment;
	subtest 'Test without any comments' => sub {
		my $forest = $song->get_comment_forest(undef);
		is(scalar @$forest, 0, 'No comments -> empty forest');
	};

	subtest 'Add one "root" comment as admin, don\'t approve it' => sub {
		$first_root_comment = $self->_create_comment($admin, $song, undef, 'BBCode1');

		my $forest = $song->get_comment_forest(undef);
		is(scalar @$forest, 0, 'Only unapproved comments -> empty forest');
	};

	subtest 'Approve the single comment' => sub {
		$admin->approve_comment($first_root_comment);
		ok($first_root_comment->approved_at, "Comment is NOW approved");

		my $forest = $song->get_comment_forest(undef);
		is(scalar @$forest, 1, 'Forest now has one root comment');
		is($forest->[0]->comment->id, $first_root_comment->id, 'Root comment is right id')
	};

	subtest 'Add approved comment to other song' => sub {
		my $song2 = $admin->admin_create_song($song_data);
		my $other_song_comment = $self->_create_comment($admin, $song2, undef, 'BBCode2');
		$admin->approve_comment($other_song_comment);

		my $forest = $song->get_comment_forest(undef);
		is(scalar @$forest, 1, 'Forest still has one root comment');
		is($forest->[0]->comment->id, $first_root_comment->id, 'Root comment is still right id');
	};

	subtest 'Add second approved root comment to first song' => sub {
		$second_root_comment = $self->_create_comment($admin, $song, undef, 'BBCode3');
		$admin->approve_comment($second_root_comment);

		my $forest = $song->get_comment_forest(undef);
		is(scalar @$forest, 2, 'Forest now has two root comments');
		is($forest->[0]->comment->id, $second_root_comment->id, 'First root comment is newest id');
		is($forest->[1]->comment->id, $first_root_comment->id, 'Second root comment is oldest id');
	};

	subtest 'Add replies to newest comment' => sub {
		# We already have a 'root' comment. Add two replies to it.
		# Then a reply to the first reply, and a reply to that.
		# Then a new reply to the root.

		# The root is song id 3 (cos 1 was the first root comment,
		# and 2 was the comment on the other song):
		#
		# So, we want to see the following IDs (I'm not hardcoding
		# IDs, but it's easier illustrated with these numbers);
		#
		# We also vary up which user makes the comments.
		#
		# 3 (root node 1)
		# +- 8
		# +- 5
		# +- 4
		#    +- 6
		#       +- 7
		#
		# 1 (root node 0)

		my $comment4 = $self->_create_comment($user,  $song, $second_root_comment, 'BBCode4');
		$admin->approve_comment($comment4);
		my $comment5 = $self->_create_comment($admin, $song, $second_root_comment, 'BBCode5');
		$admin->approve_comment($comment5);
		my $comment6 = $self->_create_comment($user,  $song, $comment4,            'BBCode6');
		$admin->approve_comment($comment6);
		my $comment7 = $self->_create_comment($user,  $song, $comment6,            'BBCode7');
		$admin->approve_comment($comment7);
		my $comment8 = $self->_create_comment($admin, $song, $second_root_comment, 'BBCode8');
		$admin->approve_comment($comment8);

		my $forest = $song->get_comment_forest(undef);
		is(scalar @$forest, 2, 'Forest still has two root comments');
		is($forest->[0]->comment->id, $second_root_comment->id, 'First root comment is 2nd root id');
		is($forest->[1]->comment->id, $first_root_comment->id,  'Second root comment is 1st root id');

		$self->_compare_children(
			$forest->[1],
			[],
			'Comment1 has no children',
		);

		$self->_compare_children(
			$forest->[0],
			[ $comment8, $comment5, $comment4 ],
			'Comment3 has children 8, 5, 4',
		);
		
		$self->_compare_children(
			$forest->[0]->children->[0],
			[],
			'Comment8 has no children',
		);
		
		$self->_compare_children(
			$forest->[0]->children->[1],
			[],
			'Comment5 has no children',
		);

		$self->_compare_children(
			$forest->[0]->children->[2],
			[ $comment6 ],
			'Comment4 has one child, 6',
		);

		$self->_compare_children(
			$forest->[0]->children->[2]->children->[0],
			[ $comment7 ],
			'Comment6 has one child, 7',
		);

		$self->_compare_children(
			$forest->[0]->children->[2]->children->[0]->children->[0],
			[],
			'Comment7 has no children',
		);

	};

	subtest 'Cannot reply to unapproved comment' => sub {
		my $comment9 = $user->new_song_comment($song, undef, {comment_bbcode => 'BBCode9'});
		throws_ok {
			my $comment10 = $user->new_song_comment($song, $comment9, {comment_bbcode => 'BBCode10'});

		} qr/Cannot reply to unapproved article/, 'Cannot reply to unapproved article';
	};

    done_testing;
}

# Too many args, but then it's a private method so &shrug; 
sub _create_comment {
	my ($self, $user, $song, $parent, $bbcode) = @_;

	my $comment;

	if ( defined $parent ) {
		$comment = $user->new_song_comment($song, $parent, {comment_bbcode => $bbcode});
		is($comment->parent_id, $parent->id, "Comment has correct parent");
	}
	else {
		$comment = $user->new_song_comment($song, undef, {comment_bbcode => $bbcode});
		ok(!$comment->parent_id, "Comment has no parent");
	}

	# Assumes the simplest of BBcode, string with no BBcode in it..
	my $expected_bbcode = "<p>$bbcode</p>";
	is($comment->comment_html, $expected_bbcode, "Comment has html");

	return $comment;
}

sub _compare_children {
	my ($self, $node, $expected_replies, $desc) = @_;

	my $actual_reply_ids = [
		map { $_->comment->id } @{ $node->children }
	];

	my $expected_reply_ids = [
		map { $_->id } @$expected_replies
	];

	cmp_deeply($actual_reply_ids, $expected_reply_ids, $desc);
}

__PACKAGE__->meta->make_immutable;
1;
