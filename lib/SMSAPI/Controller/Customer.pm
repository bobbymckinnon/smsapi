package SMSAPI::Controller::Customer;
use Mojo::Base "Mojolicious::Controller";

sub index {
    my $c = shift;

    # Validate input request or return an error document
    my $self = $c->openapi->valid_input or openapi->error;
    
    # Get our auth key from the headers
    my $x_api_key = $self->req->headers->header("X-API-KEY");
    unless ($x_api_key) {
        $self->render(openapi => "API key is missing or invalid", status => 401);

        return;
    }

    # Get the customer from the db
    my $customer = $self->customer($x_api_key);
    unless ($customer) {
        $self->render(openapi => "API key is missing or invalid", status => 401);

        return;
    }   
 
    # Data for response
    my $data = {
      body => {
        customer => $customer 
      }
    };

    # Data response
    $self->render(openapi => $data);

}

sub list {
    my $c = shift;

   # Validate input request or return an error document
    my $self = $c->openapi->valid_input or openapi->error;
    
    # Get our auth key from the headers
    my $x_api_key = $self->req->headers->header("X-API-KEY");
    unless ($x_api_key) {
        $self->render(openapi => "API key is missing or invalid", status => 401);

        return;
    }

    # Get the customer from the db
    my $customer = $self->customer($x_api_key);
    unless ($customer) {
        $self->render(openapi => "API key is missing or invalid", status => 401);

        return;
    }   
 
    # Get customer list from db
    my $customers = $self->model->list_customers();

    # Data for response
    my $data = {
      body => {
        customer => $customers 
      }
    };

    # Data response
    $self->render(openapi => $data);
}

1;
