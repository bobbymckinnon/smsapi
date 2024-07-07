package SMSAPI;
use Mojo::Base 'Mojolicious', -signatures;

use Mojo::File;
use Mojo::SQLite;
use SMSAPI::Model::SMSAPI;

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

    # Load the "openapi.json" specification from the public directory
    $self->plugin(
        OpenAPI => {
            spec => $self->static->file("openapi.json")->path
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

        return SMSAPI::Model::SMSAPI->new(
            sqlite => $c->app->sqlite,
        );
    });

    $self->helper(customer => sub {
        my ($c, $x_api_key) = @_;

        my $model = $c->model;
        my $customer = $model->get_customer($x_api_key);
        
        return unless $customer;
            
        return $customer;
    });
}

1;
