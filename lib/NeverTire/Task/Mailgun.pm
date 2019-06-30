package NeverTire::Task::Mailgun;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Template;
use Mojo::Home;
use Mojo::UserAgent;
use Mojo::URL;

# Includes ideas from Mojolicious::Plugin::Mailgun
# https://metacpan.org/pod/Mojolicious::Plugin::Mailgun
# 
# and from the docs for Minion
# https://mojolicious.org/perldoc/Minion


has base_url => sub { Mojo::URL->new('https://api.eu.mailgun.net/v3/'); };
has ua       => sub { Mojo::UserAgent->new; };
has home     => sub { Mojo::Home->new; };
has domain   => undef;
has api_key  => undef;
has from     => undef;

sub register {
    my ($self, $app, $conf) = @_;

    # Set config from $ENV, passed conf, or from app config files
    # in that order.
    $self->domain ( $self->_conf('domain',  $app, $conf) );
    $self->api_key( $self->_conf('api_key', $app, $conf) );
    $self->from   ( $self->_conf('from',    $app, $conf) );

    $self->home->detect;

    # Create a minion task to send an email
    $app->minion->add_task(mailgun => sub {
        my ($job, $email_id) = @_;

        my $app = $job->app;
        my $schema = $app->schema;
        my $email_rs = $schema->resultset('Email');
        my $email = $email_rs->find($email_id);

        return unless $email;

        my $template = $email->template_name;
        my $data     = $email->data;

        my $mt = Mojo::Template->new;
        my $subject = $mt->vars(1)->render_file($self->_file(subject => $template), $data);
        my $body    = $mt->vars(1)->render_file($self->_file(body    => $template), $data);
        
        my $url = $self->base_url->clone;
        $url->path->merge($self->domain . '/messages');
        $url->userinfo('api:' . $self->api_key);

        $self->ua->post_p($url, form => {
            to      => $email->email_to,
            from    => $email->email_from,
            subject => $subject,
            text    => $body,
        })->catch( sub {
            my $err = shift;
            warn "Mailgun connection error: $err";
        })->wait;

        $email->update({sent_at => \'NOW()'});

        # TODO Handle response
    });
}


# Doc this. If $key is 'api_key', it looks in these places in order:
#  * $ENV{NEVER_TIRE_MAILGUN_API_KEY}
#  * $conf->{api_key}
#  * $app->conf->{mailgun}->{api_key}

sub _conf {
    my ($self, $key, $app, $conf) = @_;

    my $env_name = 'NEVER_TIRE_MAILGUN_' . uc($key);
    return $ENV{$env_name} if exists $ENV{$env_name};

    return $conf->{$key} if exists $conf->{$key};

    return $app->config->{mailgun}->{$key} if exists $app->config->{mailgun}->{$key};

    die "Not found mailgun config for '$key'";
}

# Doc this, locates a template file

sub _file {
    my ($self, $type, $template) = @_;

    return $self->home->child(
        'templates',
        'email',
        $template,
        "${type}.text.ep"
    );

}

1;
__END__

# TODO pod docs
