DROP DATABASE IF EXISTS friends_database;
CREATE DATABASE IF NOT EXISTS friends_database;
use friends_database;

drop table if exists friends_app;

create table friends_app(
friendId int(11) not null auto_increment,
first_name varchar(50),
last_name varchar(50),
primary key (friendId)
) Engine=InnoDB auto_increment = 1;

insert into friends_app (friendId, first_name, last_name) values (0, 'Ray', 'Jay');