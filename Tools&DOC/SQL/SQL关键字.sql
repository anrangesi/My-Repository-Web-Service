select * from Student
select * from course

select * from student s where not exists(select * from course c where c.stuNo=s.stuNo)
select * from student s where stuName not in(select stuName from course c where c.stuNo=s.stuNo)

select * from student s where stuNo in(select * from course c)-- where c.stuNo=s.stuNo


--between ÓÃ·¨
select * from T_SJJP_PURCHASE_REQUISITION where create_time between '2016-12-31'and GETDATE()

select * from T_SJJP_PURCHASE_REQUISITION where create_time in('2010-08-09','2010-08-04')
select * from T_SJJP_PURCHASE_REQUISITION where code in('PR-20100804-00087','PR-20100809-00088')

--and  not exists(select * from T_SJJP_PURCHASE_REQUISITION pr where pr.create_time<='2016-12-31')