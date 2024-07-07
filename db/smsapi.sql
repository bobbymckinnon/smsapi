-- 1 up
PRAGMA foreign_keys = ON;

create table customers (
  id integer primary key autoincrement,
  x_api_key text not null unique,
  name text not null,
  balance integer not null,
  message_cost integer not null
);

create table messages (
  id integer primary key autoincrement,
  title text,
  purchased integer not null default 0,
  customer_id integer not null,
  foreign key(customer_id) references customers(id)
);

insert into customers values(1, 'b18a2778-63e9-4dff-b41d-cd080af5fd1a', 'Customer 1', 1000, 100);
insert into customers values(2, '47e35aef-dac4-47fd-a7ef-f9d1c2c5cbd5', 'Customer 2', 1000, 100);
insert into customers values(3, '4982e28c-225a-4dd6-a177-886c5754879d', 'Customer 3', 1000, 100);
insert into customers values(4, 'b2135a8f-1763-40d0-820d-1f05b3005827', 'Customer 4', 1000, 100);
insert into customers values(5, 'bde8b726-77da-42df-a715-fe53375d969e', 'Customer 5', 1000, 100);

-- 1 down

PRAGMA foreign_keys = OFF;
drop table if exists customers;
drop table if exists messages;
