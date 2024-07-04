package SMSAPI;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup ($self) {

    my $self = shift;

    # Load the "api.yaml" specification from the public directory
    $self->plugin(
        OpenAPI => {
            spec => $self->static->file("api.json")->path
        }
    );

    $self->plugin(
        SwaggerUI => {
            route => $self->routes()->any('api-cc'),
            url => "/api/v1",
            title => "SMS API"
        }
    );

}

1;
