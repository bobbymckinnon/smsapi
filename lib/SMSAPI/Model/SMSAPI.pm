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
      cast(customer.balance as float) as balance,
      cast(customer.message_cost as float) /100 as message_cost
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

sub list_customers {
  my $self = shift;
  my $sql = <<'  SQL';
    select
      customer.id,
      customer.name,
      cast(customer.balance as float) as balance,
      cast(customer.message_cost as float) /100 as message_cost
    from customers customer
  SQL
  return $self
    ->sqlite
    ->db
    ->query($sql)
    ->expand(json => 'customers')
    ->hashes;
}

sub create_message {
  my ($self, $message) = @_;

  return $self
    ->sqlite
    ->db
    ->insert('messages' => $message)
    ->last_insert_id;
}

sub list_messages {
  my $self = shift;
  my $sql = <<'  SQL';
    select
      message.id,
      message.status,
      message.message_body,
      message.telephone_number
    from messages message
  SQL
  return $self
    ->sqlite
    ->db
    ->query($sql)
    ->expand(json => 'messages')
    ->hashes;
}

sub get_message {
  my ($self, $customer_id, $message_id) = @_;
  my $sql = <<'  SQL';
    select
      customer.id as customer_id,
      customer.name as customer_name,
      cast(customer.balance as float) as customer_balance,
      cast(customer.message_cost as float) /100 as customer_message_cost,
      message.message_body,
      message.status as message_status,
      message.telephone_number
      from customers customer
      left join messages message on message.customer_id = customer.id
      where message.id=?
  SQL
  return $self
    ->sqlite
    ->db
    ->query($sql, $message_id)
    ->expand(json => 'messages')
    ->hash;
}

sub update_message {
  my ($self, $message, $status) = @_;
  return $self
    ->sqlite
    ->db
    ->update(
      'messages',
      {status => $status},
      {id => $message->{id}},
    )->rows;
}

sub update_customer_balance {
  my ($self, $customer) = @_;

  return $self
    ->sqlite
    ->db
    ->update(
      'customers',
      {balance => ($customer->{balance} - $customer->{message_cost})},
      {id => $customer->{id}},
    )->rows;
}

sub delete_message {
  my ($self, $message) = @_;
  return $self
    ->sqlite
    ->db
    ->delete(
      'messages',
      {id => $message->{id}},
    )->rows;
}

1;
