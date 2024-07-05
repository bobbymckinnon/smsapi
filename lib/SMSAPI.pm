package SMSAPI;
use Mojo::Base 'Mojolicious', -signatures;

use Mojo::File;
use Mojo::SQLite;
use LinkEmbedder;
use SMSAPI::Model::Message;

has sqlite => sub {
    my $app = shift;

    # determine the storage location
    my $file = $app->config->{database} || 'db/smsapi.db';
    unless ($file =~ /^:/) {
        $file = Mojo::File->new($file);
        unless ($file->is_abs) {
            $file = $app->home->child("$file");
        }
    }

    my $sqlite = Mojo::SQLite->new
        ->from_filename("$file")
        ->auto_migrate(1);

    # attach migrations file
    $sqlite->migrations->from_file(
        $app->home->child('db/smsapi.sql')
    )->name('smsapi');

    return $sqlite;
};


# This method will run once at server start
sub startup ($self) {

    my $self = shift;

    # Load configuration from config file
    my $config = $self->plugin('JSONConfig');

    # Load the "api.yaml" specification from the public directory
    $self->plugin(
        OpenAPI => {
            spec => $self->static->file("api.json")->path
        }
    );

    $self->plugin(
        SwaggerUI => {
            route => $self->routes()->any('api'),
            url => "/api/v1",
            title => "SMS API"
        }
    );

    $self->helper(model => sub {
        my $c = shift;

        return SMSAPI::Model::Message->new(
            sqlite => $c->app->sqlite,
        );
    });

    $self->helper(user => sub {
        my ($c, $name) = @_;
        print STDERR "-----1---{$name}\n";

        $name ||= $c->stash->{name} || $c->session->{name};

        return {} unless $name;
        $name = 'dan';
        print STDERR "-----2---{$name}\n";

        my $model = $c->model;
        my $user = $model->user($name);
        unless ($user) {
            $model->add_user($name);
            $user = $model->user($name);
        }

        return $user;
    });

    my $r = $self->routes;

    $r->get('/messages')->to('Message#show_add')->name('');
}

1;
