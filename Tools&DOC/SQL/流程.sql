select * from t_sjjp_user where username='92012686'

select * from t_sjjp_user where userId='2291'
select * from t_sjjp_user where userId='317'
select * from t_sjjp_user where userId='2668'
select * from t_sjjp_user where userId='2664'
select a.userId,a.firstname,a.level,c.roleId,c.rolename,c.roleDescription from t_sjjp_user a left join T_SJJP_USERROLE b on a.userId=b.userId
left join T_SJJP_ROLE c on b.roleId = c.roleId where a.userId='2664'

select * from t_sjjp_user where firstname='½��'
select * from T_SJJP_USERROLE where userId='2633'
select a.userId,a.firstname,a.level,c.roleId,c.rolename,c.roleDescription from t_sjjp_user a left join T_SJJP_USERROLE b on a.userId=b.userId
left join T_SJJP_ROLE c on b.roleId = c.roleId where a.userId='2633'

select * from T_SJJP_USERROLE sur left join T_SJJP_USER su on sur.userId=su.userId where roleId=4

select * from JBPM_PROCESSINSTANCE

select * from JBPM_PROCESSDEFINITION



select * from T_SJJP_PURCHASE_REQUISITION where code='10118070312498'


select * from t_sjjp_user where firstname='admin'
select a.userId,a.firstname,a.level,c.roleId,c.rolename,c.roleDescription from t_sjjp_user a left join T_SJJP_USERROLE b on a.userId=b.userId
left join T_SJJP_ROLE c on b.roleId = c.roleId where a.userId='575'


select distinct top 50 ti.ID_ , 
pi.start_ as ���̿�ʼʱ��,
ti.create_ as �������ʱ��,
t.name_ as �������,
ti.name_ as ��������,
ti.description_ as ��������,
 pd.name_ as ������,
 relation.slipCode as ���ݺ�,
 relation.slipType as ��������,
 vi.STRINGVALUE_ as ���ݴ�����WWWID, 
 case when tp.POOLEDACTOR_ is not null 
 then 1 	
 ELSE 0   
 END ,
 relation.slipId as ����ID ,
 tuser.firstname as ������������ ,
 (case when relation.slipType = 30 then 1 else 0 end) as �Ƿ���Payment���� 
  from JBPM_TASKINSTANCE as ti 
  left join JBPM_PROCESSINSTANCE as pi on ti.procinst_=pi.ID_ 
  left join JBPM_PROCESSDEFINITION as pd on pd.ID_=pi.PROCESSDEFINITION_ 
  left join JBPM_TASK as t on t.ID_=ti.TASK_ 
  left join T_SJJP_PROCESS_SLIP_RELATION as relation on relation.PROCESSINSTANCEID=pi.ID_ 
  left join JBPM_VARIABLEINSTANCE as vi on vi.PROCESSINSTANCE_=pi.ID_ 
  left join JBPM_TASKACTORPOOL as tp on ti.ID_=tp.taskinstance_ 
  left join T_SJJP_USER as tuser on vi.STRINGVALUE_=tuser.username 
  where ti.ACTORID_='702176801' and ti.isOpen_=1 and ti.isSuspended_=0 and vi.NAME_='approvalresult' and pd.NAME_ not in('sjjp_ap_ariba_purchase_requistion', 'sjjp_fa_purchase_requisition') 
  order by (case when relation.slipType = 30 then 1 else 0 end) asc, ti.create_ asc,pi.start_ asc


  select * from JBPM_TASKINSTANCE
  select * from JBPM_VARIABLEINSTANCE
  select * from JBPM_PROCESSDEFINITION where NAME_ = 'sjjp_fa_purchase_requisition'

  select permission0_.action as action44_, permission0_.discriminator as discrimi2_44_, permission0_.recipient as recipient44_, permission0_.target as target44_ 
  from V_SJJP_PERMISSION permission0_ where permission0_.target=?

  select * from t_sjjp_user where firstname like '%asgar%'
  select a.userId,a.firstname,a.level,c.roleId,c.rolename,c.roleDescription from t_sjjp_user a left join T_SJJP_USERROLE b on a.userId=b.userId
left join T_SJJP_ROLE c on b.roleId = c.roleId where a.userId='2623'

sample order finshing goods ����Lv3������ɫ

select * from T_SJJP_ROLE where rolename='SO-BR Validator-2'

select * from T_SJJP_USERROLE where roleId=47

select * from t_sjjp_user where userId=2365

-- ����ʵ��
select * from JBPM_PROCESSINSTANCE where ID_=86020
select * from JBPM_PROCESSDEFINITION

select * from T_SJJP_AUDIT_HISTORY where processId='86020'

select * from T_SJJP_PROCESS_SLIP_RELATION  where processInstanceId=86020
select * from T_SJJP_SAMPLE_ORDER_PLAN
select * from T_SJJP_ROLE where rolename='FA Specialist'


select * from T_SJJP_PAYMENT_REQUEST where code= '20117062615258'



select * from T_SJJP_REBATE_INFO where code='251807040287'
--����������̳�����
--���ȸ��ݵ��ݺŲ��ҵ���ǰ���ݵ�processinstanid
select * from T_SJJP_PROCESS_SLIP_RELATION  where slipCode='251807040287'

--Ȼ��鿴���ݵ�ǰ�����ˣ�end_��null�ǵ�ǰ�����ˣ�NAME_���̵�ǰ�ڵ�  ACTORID_����ִ���ˣ�
select * from JBPM_TASKINSTANCE where PROCINST_=86032
--Ϊʲôend_Ϊ�յ��ǵ�ǰ�����ˣ���Ϊ��û���������
select * from T_SJJP_PROCESS_SLIP_RELATION  where slipCode='20116072812595'
select * from JBPM_TASKINSTANCE where PROCINST_=62453



select * from t_sjjp_user where firstname='½��'
select * from t_sjjp_user where username='152808680'
select * from [dbo].[T_SJJP_PURCHASE_REQUISITION_LINE] wehre
--�ɹ�����
select * from [dbo].[T_SJJP_PURCHASE_REQUISITION] where code='10118071212526'
select * from [dbo].[T_SJJP_PURCHASE_REQUISITION_LINE] where pr_id=18901
--���ݵ���ȡprocessInstanceId
select * from T_SJJP_PROCESS_SLIP_RELATION where slipCode='10118071112525 '
--PROCINST_��ӦT_SJJP_PROCESS_SLIP_RELATION���processInstanceId  �鿴������һ��������
select * from JBPM_TASKINSTANCE where PROCINST_=86053

select * from T_SJJP_USER where username='152018064'
update T_SJJP_USER set passwordHash='tW4LTqSWIoO+52JSXC1JDw==' where username='152018064'
--���ݽ�ɫ��ѯ�û�
select u.username,u.firstname,u.lastname,role.roleDescription from T_SJJP_ROLE role left join T_SJJP_USERROLE userrole on role.roleId=userrole.roleId
left join T_SJJP_USER u on u.userId=userrole.userId where role.rolename ='general manager' and role.enabled=1
--�����û�id��ѯ��ɫ��Ϣ
select a.userId,a.firstname,a.level,c.roleId,c.rolename,c.roleDescription from t_sjjp_user a left join T_SJJP_USERROLE b on a.userId=b.userId
left join T_SJJP_ROLE c on b.roleId = c.roleId where a.userId='2291'
--�����û�����ѯ��ɫ��Ϣ
select a.userId,a.firstname,a.level,c.roleId,c.rolename,c.roleDescription from t_sjjp_user a left join T_SJJP_USERROLE b on a.userId=b.userId
left join T_SJJP_ROLE c on b.roleId = c.roleId where a.username = '92011969'

--��ѯ���µĲɹ���
select * from T_SJJP_PURCHASE_REQUISITION order by create_time desc

select * from JBPM_PROCESSDEFINITION where id_=136
select * from JBPM_PROCESSINSTANCE

select * from T_SJJP_PURCHASE_REQUISITION_LINE

--������ʷ
select * from T_SJJP_AUDIT_HISTORY




select permission0_.action , permission0_.discriminator , 
permission0_.recipient , permission0_.target from V_SJJP_PERMISSION permission0_
 where permission0_.target=?

 select * from V_SJJP_PERMISSION