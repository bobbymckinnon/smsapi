package SMSAPI::Controller::Message;
use Mojo::Base "Mojolicious::Controller";

sub index {
    my $c = shift;
    # Validate input request or return an error document
    my $self = $c->openapi->valid_input or return;
    my %item = (
      title => "test",
      url => "test",
      purchased => 0,
    );

    $c->model->add_item($c->user, \%item);
    # Render back the same data as you received using the "openapi" handler
    $self->render(openapi => $$c->req->json);
}

1;
