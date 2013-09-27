package KoStickies::Web;

use strict;
use warnings;
use utf8;

use Kossy;
use DBI;
use Teng;
use Teng::Schema::Loader;

use Config::Simple;

filter 'set_title' => sub {
    my $app = shift;
    sub {
        my ($self, $c)  = @_;
        $c->stash->{site_name} = __PACKAGE__;
        $app->($self,$c);
    }
};

get '/' => [qw/set_title/] => sub {
    my ($self, $c)  = @_;

    my @stickies = get_all();

    $c->render('index.tx', {
        stickies => [map { $_->body } @stickies]
    });
};

post '/post' => sub {
    my ($self, $c)  = @_;

    my $result = $c->req->validator([
        'body' => {
            rule => [
                ['NOT_NULL', 'Empty Body']
            ]
        }
    ]);

    add_sticky($result->valid('body'));

    $c->redirect('/');
};

sub dbh {
    my $config = Config::Simple->new('Config');
    my $dsn = $config->param('dsn');
    my $db_user = $config->param('db_user');
    my $db_password = $config->param('db_password');

    my $dbh = DBI->connect($dsn, $db_user, $db_password, {
        mysql_enable_utf8 => 1,
    });

    die $DBI::errstr unless defined $dbh;

    return $dbh;
}

sub teng {
    my $dbh = shift;
    $dbh = $dbh || dbh();

    Teng::Schema::Loader->load(
        'dbh' => $dbh,
        'namespace' => 'KoStickies::DB'
    );
}

sub add_sticky {
    my ($body, $dbh) = @_;

    unless(!defined $body) {
        teng($dbh)->insert('stickies' => {
            'body' => $body,
            'created_at' => 'NOW()'
        });
    }
}

sub get_all {
    my ($dbh) = @_;
    my @rows = teng($dbh)->search('stickies');
}

1;
