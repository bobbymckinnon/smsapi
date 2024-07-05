package SMSAPI;
use Mojo::Base 'Mojolicious', -signatures;
use Mojo::Pg;
use Data::Dumper qw(Dumper);

# This method will run once at server start
sub startup ($self) {

    my $self = shift;

    # Load configuration from config file
    my $config = $self->plugin('JSONConfig');

    #my $pg = Mojo::Pg->new("postgresql://$config->{db_user}:$config->{db_pass}\@/$config->{db_db}/smsapi");
    my $pg = Mojo::Pg->new("postgresql://admin:nDQiMsGqZn.6QHXozshz-WXN\@/nsurio-hc-dev.proxy-cdhrswuj4g6s.eu-central-1.rds.amazonaws.com/nsurio-hc-dev-directus");
    
    print STDERR Dumper($pg);

    my $db = $pg->db;

    $self->helper( db =>
        sub {
            print STDERR Dumper($db);
            return $db;
        }
    );

    # Load the "api.yaml" specification from the public directory
    $self->plugin(
        OpenAPI => {
            spec => $self->static->file("api.json")->path
        }
    );

    $self->plugin(
        SwaggerUI => {
            route => $self->routes()->any('api-api'),
            url => "/api/v1",
            title => "SMS API"
        }
    );
}

1;
