create proc checkView
@viewTest varchar(20),
@checkInfo varchar(20) output
as
declare @view1 varchar(255)
if exists(select s.id from sysobjects s where name=@viewTest)
begin
 set @checkinfo='����ͼ�Ѵ��ڣ�'
end
else
begin
 select @view1='create view '+ @viewTest +' as select * from student'
 exec (@view1)
 set @checkinfo='��ͼ������ɣ�'
end

declare @checkInfo varchar(20)
exec checkView 'viewTest',@checkInfo output
print @checkInfo


--drop proc checkView 
--drop view viewTest

select * from sysobjects where name='viewTest'