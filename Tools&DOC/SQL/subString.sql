select * from test

select id,substring(CODE,charindex('_',CODE)+1,len(CODE)-charindex('_',CODE)) from test;
select reverse(substring(reverse(code),charindex('_',reverse(code))+1 ,1000)) from test 

select reverse(substring(reverse(a.B),charindex('_',reverse(a.B))+1 ,500)) C from 
( select id,substring(CODE,charindex('_',CODE)+1,len(CODE)-charindex('_',CODE))B from test )A


