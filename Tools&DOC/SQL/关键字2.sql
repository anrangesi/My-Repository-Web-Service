select distinct * from course
select all * from course
select stuNo from course union all select id from student

select * from course c outer apply (select * from student s where c.stuNo=s.stuNo) as e


 SELECT *
 FROM dbo.course a
   OUTER APPLY ( SELECT *
      FROM  dbo.student b
      WHERE  b.stuNo = a.stuNo
      ) AS c 