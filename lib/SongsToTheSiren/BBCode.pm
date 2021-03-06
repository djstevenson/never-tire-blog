package SongsToTheSiren::BBCode;
use utf8;
use Moose;
use namespace::autoclean;
use Parse::BBCode;

# Encapsulates BBCode rendering.

has renderer => (is => 'ro', isa => 'Parse::BBCode', lazy => 1, builder => '_build_renderer',);

use Readonly;
Readonly my $MAX_DETECT_LINK => 45;

sub render {
    my ($self, $raw_bbcode) = @_;

    my $rendered = $self->renderer->render($raw_bbcode);

    # We will try to detect URLs and make them links IF the
    # text has no explicit BBCode links in it.
    if ($raw_bbcode !~ /\[(?:url|img|email)/ix) {
        $rendered = $self->_gruber_links($rendered);
    }

    # Dbl line break to end/start para
    # Then wrap the result in para tags
    $rendered =~ s{<br\s/><br\s/>}{</p><p>}gx;
    return '<p>' . $rendered . '</p>';
}

sub _build_renderer {
    my $self = shift;

    my %defaults = Parse::BBCode::HTML->defaults;
    delete $defaults{size};
    delete $defaults{color};
    delete $defaults{html};
    delete $defaults{noparse};
    delete $defaults{table};

    return Parse::BBCode->new({
        close_open_tags => 1,
        tags            => {
            %defaults,
            q{} => sub {
                my $e = $_[2];
                $e =~ s/>/&gt;/g;
                $e =~ s/</&lt;/g;
                $e =~ s/\r?\n|\r/<br \/>/g;
                $e;
            },
            's'     => q(<s>%s</s>),
            'sub'   => q(<sub>%s</sub>),
            'sup'   => q(<sup>%s</sup>),
            'code'  => q(<pre>%s</pre>),
            'quote' => q(<blockquote>%s</blockquote>),
        }
    });
}

sub _gruber_links {
    my ($self, $text) = @_;

    # Credit to John Gruber for URL matcher:
    # http://daringfireball.net/2009/11/liberal_regex_for_matching_urls
    # http://daringfireball.net/2010/07/improved_regex_for_matching_urls
    ## no critic (RegularExpressions::ProhibitComplexRegexes)
    $text =~ s{
        (?xi)
        \b
        (                           # Capture 1: entire matched URL
        (?:
        [a-z][\w-]+:                # URL protocol and colon
        (?:
        /{1,3}                        # 1-3 slashes
        |                             #   or
        [a-z0-9%]                     # Single letter or digit or '%'
        # (Trying not to match e.g. "URI::Escape")
        )
        |                           #   or
        www\d{0,3}[.]               # "www.", "www1.", "www2." … "www999."
        |                           #   or
        [a-z0-9.\-]+[.][a-z]{2,4}/  # looks like domain name followed by a slash
        )
        (?:                           # One or more:
        [^\s()<>]+                      # Run of non-space, non-()<>
        |                               #   or
        \(([^\s()<>]+|(\([^\s()<>]+\)))*\)  # balanced parens, up to 2 levels
        )+
        (?:                           # End with:
        \(([^\s()<>]+|(\([^\s()<>]+\)))*\)  # balanced parens, up to 2 levels
        |                                   #   or
        [^\s`!()\[\]{};:'".,<>?«»“”‘’]        # not a space or one of these punct chars
        )
        )                          #</capture_1>
    }{__form_link($1)}gex;

    # Some bodging/unbodging some link types that this code mangles
    $text =~ s{http://http://}{http://}gx;
    $text =~ s{http://https://}{https://}gx;
    ## use critic

    return $text;
}

sub __form_link {
    my ($s) = @_;

    my $max       = $MAX_DETECT_LINK;
    my $show_link = length($s) > $max ? substr($s, 0, $max) . '...' : $s;

    return qq(<a href="http://$1">$show_link</a>);
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=encoding utf8

=head1 NAME

SongsToTheSiren::BBCode : Encapsulates a renderer for BBCode

=head1 SYNOPSIS

    my $renderer = SongsToTheSiren::BBCode->new;

    my $html = $renderer->render($bbcode_txt);

=head1 DESCRIPTION

Sets up a renderer and calls it.

=head1 CONSTRUCTOR ARGS

None

=head1 METHODS

=over

=item render($bbcode_txt)

Configures a renderer, if we don't already have one, and
calls it to convert BBCode text to HTML.

=back

=head1 AUTHOR

David Stevenson david@ytfc.com
