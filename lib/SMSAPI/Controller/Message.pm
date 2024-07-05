package SMSAPI::Controller::Message;
use Mojo::Base "Mojolicious::Controller";

sub index {
    my $c = shift;

    print STDERR "-----3---{$c->openapi->valid_input}\n";

    # Validate input request or return an error document
    my $self = $c->openapi->valid_input or openapi->error;

    $c->session->{name} = "sss";

    my %item = (
      title => "test",
      url => "test",
      purchased => 0,
    );

    $c->model->add_item($c->user, \%item);
    my $data = {
      body => {
        item => \%item
        }
      };
    # Render back the same data as you received using the "openapi" handler
    $self->render(openapi => $data);
}

1;
