package SMSAPI::Controller::User;
use Mojo::Base "Mojolicious::Controller";

sub index {
    my $c = shift;

    # Validate input request or return an error document
    my $self = $c->openapi->valid_input or openapi->error;

    my $users = $c->model->list_users();

    my $data = {
      body => {
        users => $users 
      }
    };

    # Render back the same data as you received using the "openapi" handler
    $self->render(openapi => $data);
}

1;
