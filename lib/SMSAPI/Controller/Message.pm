package SMSAPI::Controller::Message;
use Mojo::Base "Mojolicious::Controller";
use Amazon::SQS::Simple;

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

    #send_msg($c, \%item);

    # Render back the same data as you received using the "openapi" handler
    $self->render(openapi => $data, status => 401);
}

sub send_msg {
    my ($self, $item) = @_;
    my $access_key = "AKIAXDXM26OBZRESMDNN"; # Your AWS Access Key ID
    my $secret_key = "uLC9/4iB9f3VM6JRmtobT9IJAGIVF26yF1ZvsYFQ"; # Your AWS Secret Key

    print STDERR "-----4---{$access_key}\n";

    # Create an SQS object
  
    my $sqs = new Amazon::SQS::Simple(
        $access_key, 
        $secret_key
    );

    # Create a new queue
    my $q = $sqs->CreateQueue("smsapi");

    # Send a message
    my $response = $q->SendMessage('Hello world');
         
}

1;
