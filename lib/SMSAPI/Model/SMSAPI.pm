package SMSAPI::Model::SMSAPI;
use Mojo::Base -base;

use Carp ();

has sqlite => sub { Carp::croak 'sqlite is required' };

sub create_customer {
  my ($self, $name, $balance, $message_cost) = @_;
          
  return $self
    ->sqlite
    ->db
    ->insert(
      'customers',
      {
        name => $name,
        balance => $balance,
        message_cost => $message_cost
      },
    )->last_insert_id;
}

sub get_customer {
  my ($self, $x_api_key) = @_;

  my $sql = <<'  SQL';
    select
      customer.id,
      customer.name,
      customer.balance,
      customer.message_cost
    from customers customer
    where customer.x_api_key=?
  SQL
  return $self
    ->sqlite
    ->db
    ->query($sql, $x_api_key)
    ->expand(json => 'customer')
    ->hash;
}

sub customer {
  my ($self, $name) = @_;
  my $sql = <<'  SQL';
    select
      customer.id,
      customer.name,
      customer.balance
      (
        select
          json_group_array(message)
        from (
          select json_object(
            'id',        items.id,
            'title',     items.title,
            'url',       items.url,
            'purchased', items.purchased
          ) as message
          from messages
          where messages.customer_id=customer.id
        )
      ) as messages
    from customers customer
    where customer.x_api_key=?
  SQL
  return $self
    ->sqlite
    ->db
    ->query($sql, $name)
    ->expand(json => 'messages')
    ->hash;
}

sub list_user_names {
  my $self = shift;
  return $self
    ->sqlite
    ->db
    ->select(
      'customers' => ['name'],
      undef,
      {-asc => 'name'},
    )
    ->arrays
    ->map(sub{ $_->[0] });
}

sub list_customers {
  my $self = shift;
  my $sql = <<'  SQL';
    select
      customer.id,
      customer.name,
      customer.balance,
      customer.message_cost
    from customers customer
  SQL
  return $self
    ->sqlite
    ->db
    ->query($sql)
    ->expand(json => 'customers')
    ->hashes;
}

sub add_item {
  my ($self, $user, $item) = @_;
  $item->{user_id} = $user->{id};
  return $self
    ->sqlite
    ->db
    ->insert('messages' => $item)
    ->last_insert_id;
}

sub update_item {
  my ($self, $item, $purchased) = @_;
  return $self
    ->sqlite
    ->db
    ->update(
      'messages',
      {purchased => $purchased},
      {id => $item->{id}},
    )->rows;
}

sub remove_item {
  my ($self, $item) = @_;
  return $self
    ->sqlite
    ->db
    ->delete(
      'messages',
      {id => $item->{id}},
    )->rows;
}

1;
