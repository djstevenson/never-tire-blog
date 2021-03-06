package SongsToTheSiren::Controller::Admin::Song;
use utf8;
use Mojo::Base 'Mojolicious::Controller';

use SongsToTheSiren::Controller::Admin::Song::Comment;
use SongsToTheSiren::Controller::Admin::Song::Link;
use SongsToTheSiren::Controller::Admin::Song::Tag;

sub add_routes {
    my ($c, $r) = @_;

    ## no critic (ValuesAndExpressions::ProhibitLongChainsOfMethodCalls)

    # $r already has 'require_admin' check applied

    my $a = $r->any('song')->to(controller => 'admin-song');

    # Routes that do not capture a song id
    $a->get('/list')->name('admin_list_songs')->to(action => 'list');
    $a->any(['GET', 'POST'] => '/create')->name('admin_create_song')->to(action => 'create');

    # # Routes that capture a song id
    my $song_a = $a->under('/:song_id')->to(action => 'capture');

    $song_a->get('/publish')->name('admin_publish_song')->to(action => 'publish');
    $song_a->get('/unpublish')->name('admin_unpublish_song')->to(action => 'unpublish');
    $song_a->any(['GET', 'POST'] => '/edit')->name('admin_edit_song')->to(action => 'edit');

    # Method=DELETE?
    $song_a->any(['GET', 'POST'] => '/delete')->name('admin_delete_song')->to(action => 'do_delete');

    SongsToTheSiren::Controller::Admin::Song::Comment->new->add_routes($song_a);
    SongsToTheSiren::Controller::Admin::Song::Link->new->add_routes($song_a);
    SongsToTheSiren::Controller::Admin::Song::Tag->new->add_routes($song_a);
    ## use critic
    
    return;
}

sub create {
    my $c = shift;

    my $form = $c->form('Song::Edit');
    if ($form->process) {
        $c->flash(msg => 'Song created') if $form->action eq 'created';

        $c->redirect_to('admin_list_songs');
    }
    else {
        $c->stash(form => $form);
    }

    return;
}

sub list {
    my $c = shift;

    my $table = $c->table('Song::List');

    $c->stash(table => $table);

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

sub publish {
    my $c = shift;

    $c->stash->{song}->show;

    $c->redirect_to('admin_list_songs');

    return;
}

sub unpublish {
    my $c = shift;

    $c->stash->{song}->hide;

    $c->redirect_to('admin_list_songs');

    return;
}

sub edit {
    my $c = shift;

    my $song = $c->stash->{song};
    my $form = $c->form('Song::Edit', song => $song);

    if ($form->process) {
        $c->flash(msg => 'Song updated') if $form->action eq 'updated';

        $c->redirect_to('admin_list_songs');
    }
    else {
        $c->stash(form => $form);
    }

    return;
}

sub do_delete {
    my $c = shift;

    my $form = $c->form('Song::Delete', song => $c->stash->{song});
    if ($form->process) {
        $c->flash(msg => 'Song deleted') if $form->action eq 'deleted';
        $c->redirect_to('admin_list_songs');
    }
    else {
        $c->stash(form => $form);
    }

    return;
}


1;
