create table user_t(
id int not null primary key,
user_name varchar(40) not null,
password varchar(255) not null,
age int not null
)

insert into user_t values('1', '����', '345', '24')
insert into user_t values('2', '��˼', '567', '19')

select * from user_t