package SongsToTheSiren::Controller::Song;
use utf8;
use Mojo::Base 'Mojolicious::Controller';

use SongsToTheSiren::Controller::Song::Comment;

sub add_routes {
    my ($c, $r) = @_;

    ## no critic (ValuesAndExpressions::ProhibitLongChainsOfMethodCalls)
    my $u = $r->any('/song')->to(controller => 'song');
    my $a = $u->require_admin;

    # Routes that capture a song id
    my $song_action_u = $u->under('/:song_id')->to(action => 'capture');

    $song_action_u->get('/view')->name('view_song')->to(action => 'view');

    SongsToTheSiren::Controller::Song::Comment->new->add_routes($song_action_u);
    ## use critic
    
    return;
}

sub capture {
    my $c = shift;

    # Fetch the full song data, returning 404
    # if it doesn't exist.
    # Check that it's published, unless
    # we're admin, in which case we don't care

    my $song_id = $c->stash->{song_id};
    my $rs      = $c->schema->resultset('Song');
    my $admin   = exists $c->stash->{admin_user};
    if (my $song = $rs->full_song_data($song_id, $admin)) {
        $c->stash(song => $song);
    }
    else {
        $c->reply->not_found;
        return undef;
    }

    return 1;
}


sub view {
    my $c = shift;

    my $song = $c->stash->{song};
    my $user = $c->stash->{auth_user};

    $c->stash(
        embed_links => $song->links->embedded_links->by_identifier,
        list_links  => scalar $song->links->in_list->by_priority,
        forest      => $song->get_comment_forest($user),
        navigation  => $song->get_navigation,
    );

    return;
}

1;
