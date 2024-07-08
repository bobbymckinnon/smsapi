package SMSAPI;
use JSON;
use Mojo::Base 'Mojolicious', -signatures;
use Mojo::File;
use Mojo::SQLite;
use SMSAPI::Model::SMSAPI;
use Amazon::SQS::Simple;

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

        my $x_api_key = $c->req->headers->header("X-API-KEY");

        my $model = $c->model;
        my $customer = $model->get_customer($x_api_key);
        
        return unless $customer;
            
        return $customer;
    });

    $self->helper(can_send => sub {
        my ($c, $customer) = @_;

        if ($customer->{balance} >= $customer->{message_cost}) {
            my $model = $c->model;
            $model->update_customer_balance($customer);

            return 1;
        }

        return;
    });

    $self->helper(queue_message => sub {
        my ($c, $message) = @_;

        my $access_key = $ENV{ACCESS_KEY_ID}; #"AKIAXDXM26OBZRESMDNN"; # Your AWS Access Key ID
        my $secret_key = $ENV{SECRET_ACCESS_KEY};#"uLC9/4iB9f3VM6JRmtobT9IJAGIVF26yF1ZvsYFQ"; # Your AWS Secret Key
        
        print STDERR "-----1---{$access_key}\n";

        # Create an SQS object
        my $sqs = new Amazon::SQS::Simple(
            $access_key, 
            $secret_key
        );

        my $mm = encode_json($message);
        my $q = $sqs->CreateQueue("smsapi");
        my $response = $q->SendMessage($message);

        if ($response) {
            return 1;
        }

        return;
    });
}

1;
