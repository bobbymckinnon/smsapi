package SMSAPI::Controller::Message;
use Mojo::Base "Mojolicious::Controller";
use Amazon::SQS::Simple;
use Mojo::JSON qw(decode_json);
use JSON;

sub create {
    my $c = shift;

   # Validate input request or return an error document
    my $self = $c->openapi->valid_input or openapi->error;

    my $json = $self->req->body;
    my $message_hash = decode_json($json);

    # Get the customer from the db
    my $customer = $self->customer();
    unless ($customer) {
        $self->render(openapi => "API key is missing or invalid", status => 401);

        return;
    } 

    if ($self->can_send($customer)) {
        my %new_message = (
            'message_body'     => $message_hash->{message_body},
            'customer_id'      => $customer->{id},
            'telephone_number' => $message_hash->{telephone_number}
        );

        my $new_message_id = $self->model->create_message(\%new_message);
        my $message = $self->model->get_message($customer->{id}, $new_message_id);    

        # Data for response
        my $data = {
            message => $message
        };

        # Data response
        $self->render(openapi => $data);

        return;
    }

    $self->render(openapi => "Balance is too low", status => 401);
}

sub list {
    my $c = shift;

   # Validate input request or return an error document
    my $self = $c->openapi->valid_input or openapi->error;

    # Get the customer from the db
    my $customer = $self->customer();
    unless ($customer) {
        $self->render(openapi => "API key is missing or invalid", status => 401);

        return;
    }   
 
    # Get messages list from db
    my $messages = $self->model->list_messages();

    # Data for response
    my $data = {
      body => {
        messages => $messages 
      }
    };

    # Data response
    $self->render(openapi => $data);
}

sub index {
    my $c = shift;

    # Validate input request or return an error document
    my $self = $c->openapi->valid_input or openapi->error;

    # Get the customer from the db
    my $customer = $self->customer();
    unless ($customer) {
        $self->render(openapi => "API key is missing or invalid", status => 401);

        return;
    }  

    my $message = $self->model->get_message($customer->{id}, $self->param('id') );

    my $data = {
        message => $message
    };

    #send_msg($c, \%item);

    $self->render(openapi => $data);
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
