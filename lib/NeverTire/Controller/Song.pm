package NeverTire::Controller::Song;
use Mojo::Base 'Mojolicious::Controller';

# $r  = routes
# $rl = routes for which you need to be logged-in

sub add_routes {
    my ($c, $r, $rl) = @_;

    my $ul = $rl->any('/song')->to(controller => 'song');

    # These are admin functions, need to be logged in for all of them.
    $ul->route('/list')->name('list_songs')->via('GET')->to(action => 'list');
    $ul->route('/create')->name('create_song')->via('GET', 'POST')->to(action => 'create');

    # Admin routes that capture a song id
    my $song_action = $ul->under('/:song_id')->to(action => 'capture');

    # TODO Later, add POST cos we'll want a confirmation form
    #      and possibly allowing a future pub date
    $song_action->route('/show')->name('show_song')->via('GET')->to(action => 'show');
    $song_action->route('/hide')->name('hide_song')->via('GET')->to(action => 'hide');
}

sub create {
    my $c = shift;

    my $form = $c->form('Song::Create');
    if (my $song = $form->process) {
        $c->flash(msg => 'Song created');
        # TODO Probably redirect to song view really?
        $c->redirect_to('list_songs');
    }
    else {
        $c->stash(form => $form);
    }
}

sub list {
    my $c = shift;

    # TODO Pagination
    my $table = $c->table('Song::List');

    $c->stash(table => $table);
}

sub capture {
    my $c = shift;

    my $song_id = $c->stash->{song_id};
    if (my $song = $c->schema->resultset('Song')->find($song_id)) {
        $c->stash(song => $song);
        return 1;
    }
    else {
        $c->reply->not_found;
        return undef;
    }
}

sub show {
    my $c = shift;

    $c->stash->{song}->show;

    $c->redirect_to('list_songs');
}

sub hide {
    my $c = shift;

    $c->stash->{song}->hide;

    $c->redirect_to('list_songs');
}



1;