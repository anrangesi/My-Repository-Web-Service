create proc checkView
@viewTest varchar(20),
@checkInfo varchar(20) output
as
declare @view1 varchar(255)
if exists(select s.id from sysobjects s where name=@viewTest)
begin
 set @checkinfo='该视图已存在！'
end
else
begin
 select @view1='create view '+ @viewTest +' as select * from student'
 exec (@view1)
 set @checkinfo='视图创建完成！'
end

declare @checkInfo varchar(20)
exec checkView 'viewTest',@checkInfo output
print @checkInfo


--drop proc checkView 
--drop view viewTest

select * from sysobjects where name='viewTest'