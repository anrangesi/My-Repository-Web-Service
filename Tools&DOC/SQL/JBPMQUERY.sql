--一个流程定义文件对应一条记录，可记录多个流程定义文件，可记录一个流程定义文件的对个版本。
select * from jbpm_processdefinition
delete from jbpm_processdefinition where name_ ='helloworld'
select * from [dbo].[JBPM_MODULEDEFINITION]
--记录 ActionHandler 的对象实例（以名称为标识）
select * from jbpm_action
-- 	记录了 ActionHandler 全类名，以便于用反射方式来加载
select * from jbpm_delegation
-- 	它的 transition 引用了 Jbpm_transition 表的 id ，再看其它字段，估计此表是表示流程转向事件的一个实例，或者是一个各表之间的联接表。
select * from jbpm_event
--流程结点
select * from jbpm_node
-- 	流程的转向定义
select * from jbpm_transition
--流程中携带的变量。 ACCESS 字段是这些变量的读写权限
select * from jbpm_variableaccess








