--�鿴����ǩ��Ȩ��
SELECT  distinct le.id,CASE sp.downpay_limit_expense 
WHEN 10000 THEN 'Lv1'
WHEN 50000 THEN 'Lv2'
WHEN 100000 THEN 'Lv2.5'
WHEN 500000 THEN 'Lv3'
WHEN 1000000 THEN 'Lv4'
WHEN 3000000 THEN 'Lv4.5'
WHEN 50000000 THEN 'Lv5'
ELSE NULL END
,le.name,sp.downpay_limit_expense FROM dbo.T_SJJP_SIGNOFF_PERMISSION sp
LEFT JOIN dbo.T_SJJP_LEVEL le ON le.id=sp.level
ORDER BY sp.downpay_limit_expense

--�鿴ϵͳ������Ч����ӵ��level���û�
SELECT u.username,u.firstname,l.name FROM dbo.T_SJJP_USER u
LEFT JOIN dbo.T_SJJP_LEVEL l ON u.level=l.id
WHERE enabled=1 AND level IS NOT NULL ORDER BY l.name

--�鿴ϵͳ������Ч����ӵ��level����ӵ�����������û�
SELECT distinct us.username,us.firstname,le.name,sp.downpay_limit_expense,us.level
 FROM dbo.T_SJJP_SIGNOFF_PERMISSION sp
LEFT JOIN dbo.T_SJJP_LEVEL le ON le.id=sp.level
LEFT JOIN dbo.T_SJJP_USER us ON le.id=us.level
WHERE enabled=1 AND us.level IS NOT NULL ORDER BY le.name

--�鿴ϵͳ������Ч��û��level���û�
SELECT * FROM T_SJJP_USER WHERE level IS NULL AND enabled=1

-- ����wwid�鿴�û�ǩ�ֽ����level
SELECT distinct us.firstname,le.name,sp.*
 FROM dbo.T_SJJP_SIGNOFF_PERMISSION sp
LEFT JOIN dbo.T_SJJP_LEVEL le ON le.id=sp.level
LEFT JOIN dbo.T_SJJP_USER us ON us.level = sp.level
WHERE us.username='92430303'


SELECT * FROM T_SJJP_SIGNOFF_PERMISSION

--����code�鿴����������һ֧����
select distinct pd.* from T_SJJP_PROCESS_SLIP_RELATION srt 
LEFT JOIN JBPM_TASKINSTANCE ti ON srt.processInstanceId=ti.PROCINST_
LEFT JOIN JBPM_TASK task ON ti.TASK_=task.ID_
LEFT JOIN JBPM_PROCESSDEFINITION pd ON task.PROCESSDEFINITION_=pd.ID_
WHERE srt.slipCode='10117032711803' 

--�����������Ʋ鿴�������ڸ����̵ĵ���
select distinct srt.* from T_SJJP_PROCESS_SLIP_RELATION srt 
LEFT JOIN JBPM_TASKINSTANCE ti ON srt.processInstanceId=ti.PROCINST_
LEFT JOIN JBPM_TASK task ON ti.TASK_=task.ID_
LEFT JOIN JBPM_PROCESSDEFINITION pd ON task.PROCESSDEFINITION_=pd.ID_
WHERE pd.NAME_='sjjp_ap_purchase_requistion'

--���ݵ��ݺŲ鿴���������ĸ�����
SELECT distinct pr.applicant '������',dept.name '����',pd.NAME_ '��������',prl.gr_amount '���',pr.status '״̬',pr.* 
FROM dbo.T_SJJP_PURCHASE_REQUISITION pr 
LEFT JOIN T_SJJP_PURCHASE_REQUISITION_LINE prl ON prl.pr_id = pr.id
LEFT JOIN T_SJJP_PROCESS_SLIP_RELATION psr ON psr.slipCode=pr.code
LEFT JOIN JBPM_TASKINSTANCE taski ON psr.processInstanceId=taski.PROCINST_
LEFT JOIN JBPM_TASK task ON taski.TASK_=task.ID_
LEFT JOIN JBPM_PROCESSDEFINITION pd ON task.PROCESSDEFINITION_=pd.ID_
LEFT JOIN dbo.T_SJJP_USER suser ON pr.applicant=suser.username
LEFT JOIN dbo.T_SJJP_DEPARTMENT dept ON suser.depart_id=dept.id
LEFT JOIN dbo.T_AP_BI_EXPENSE_TYPE expense ON pr.expense_type=expense.id
where pr.is_template=0 AND pr.code='10118080712755'
ORDER BY pr.create_time DESC

--����wwid�ҵ��û����еĽ�ɫ
SELECT a.lastname,a.userId,c.roleId,c.rolename,c.roleDescription 
FROM dbo.T_SJJP_USER a 
LEFT JOIN dbo.T_SJJP_USERROLE b ON b.userId = a.userId
LEFT JOIN dbo.T_SJJP_ROLE c ON b.roleId = c.roleId 
WHERE a.username='106991473'

--���ݽ�ɫ����ѯ�û�
SELECT * FROM dbo.T_SJJP_USER 
WHERE userId IN(SELECT userId FROM dbo.T_SJJP_USERROLE 
WHERE roleId IN(SELECT roleId FROM dbo.T_SJJP_ROLE 
WHERE rolename = 'general manager'))

-- ��ɫ�� �û� level�ȼ�
SELECT user_.firstname,user_.level,role.rolename
FROM dbo.T_SJJP_USERROLE ur,dbo.T_SJJP_ROLE role,dbo.T_SJJP_USER user_
WHERE ur.userId=user_.userId AND role.roleId=ur.roleId AND role.rolename='MD'  ORDER BY user_.level
AND role.rolename IN ('Chief Executive Officer','general manager','CFO')

--���ݵ���code�鿴������һ������
select ti.* from T_SJJP_PROCESS_SLIP_RELATION srt 
LEFT JOIN JBPM_TASKINSTANCE ti ON srt.processInstanceId=ti.PROCINST_
WHERE srt.slipCode='10118101912108' 
89403873

-- SAP�ɹ�  is_brandΪ1ʱ������ΪSAP������
SELECT pr.create_time,pr.code,pr.creator,pr.applicant,dept.name '����',
CASE pr.status 
WHEN 15 THEN '����ͨ��'
WHEN 10 THEN '������'
WHEN 5 THEN '�ѱ���'
WHEN 18 THEN 'PR�Ѵ���' 
WHEN 20 THEN 'PO �Ѵ���'
WHEN 25 THEN 'PO�Ѷ�ȡ'
WHEN 30 THEN 'PO ���ͷ�'
WHEN 35 THEN 'ѯ��ʧ��'
WHEN 40 THEN '���̳ɹ�����'
ELSE NULL END '״̬'
,prl.product_name,
pr.totalAmount,
prl.pr_amount,prl.pr_unitprice,prl.pr_qty
FROM dbo.T_SJJP_PURCHASE_REQUISITION pr,
dbo.T_SJJP_PURCHASE_REQUISITION_LINE prl,
dbo.T_SJJP_USER u,
T_SJJP_DEPARTMENT dept
WHERE pr.id=prl.pr_id AND pr.applicant=u.username AND u.depart_id=dept.id AND is_brand=1 
 ORDER BY create_time DESC
 
 --Ʒ����ʾ������
SELECT so.CREATE_TIME,so.CODE,so.CREATOR,so.APPLICANT,dept.name '����',
CASE so.STATUS 
WHEN 5 THEN '�ѱ���'
WHEN 10 THEN '������'
WHEN 15 THEN '����ͨ��'
WHEN 20 THEN 'SAP�ѷ���ȷ������'
WHEN 45 THEN '��ȡ��'
WHEN 50 THEN '����޸�'
ELSE NULL END '״̬',
product.PR_CODE '����CODE',
product.PR_NAME '��������',
soLine.PIECE_QTY,
soLine.PR_UNIT_PRICE,soLine.AMOUNT,so.TOTAL_AMOUNT,so.TOTAL_AMOUNT_TAX
FROM dbo.T_SJJP_SAMPLE_ORDER so,
dbo.T_SJJP_SAMPLE_ORDER_LINE soLine,
dbo.T_SJJP_USER u,
T_SJJP_DEPARTMENT dept,
T_AP_BI_PRODUCT product
WHERE soLine.SO_ID=so.ID AND so.IS_TEMPLATE=0 AND so.APPLICANT=u.username AND u.depart_id=dept.id
AND soLine.PRODUCT_ID=product.ID
order by so.CREATE_TIME DESC

-- ����״̬��
SELECT * FROM dbo.T_BI_CHOOSE_OPTION

--------------------------------��ѯ�û���Ҫ�����ĵ���--
select distinct 
ti.ACTORID_,
ti.ID_ 
, pi.start_ as ���̿�ʼʱ��
,ti.create_ as �������ʱ��
,t.name_ as �������,ti.name_ as ��������
,ti.description_ as ��������
, pd.name_ as ������
,relation.slipCode as ���ݺ�
,relation.slipType as ��������
,vi.STRINGVALUE_ as ���ݴ�����WWWID
, case 
	when tp.POOLEDACTOR_ is not null then 1 
	ELSE 0 
  END 
,relation.slipId as ����ID 
,tuser.firstname as ������������ 
from JBPM_TASKINSTANCE as ti 
left join JBPM_PROCESSINSTANCE as pi on ti.procinst_=pi.ID_ 
left join JBPM_PROCESSDEFINITION as pd on pd.ID_=pi.PROCESSDEFINITION_ 
left join JBPM_TASK as t on t.ID_=ti.TASK_ 
left join T_SJJP_PROCESS_SLIP_RELATION as relation on relation.PROCESSINSTANCEID=pi.ID_ 
left join JBPM_VARIABLEINSTANCE as vi on vi.PROCESSINSTANCE_=pi.ID_ 
left join JBPM_TASKACTORPOOL as tp on ti.ID_=tp.taskinstance_ 
left join T_SJJP_USER as tuser on vi.STRINGVALUE_=tuser.username 
where ti.ACTORID_='105000277' and 
ti.isOpen_=1 and ti.isSuspended_=0 and vi.NAME_='applicant'
and pd.NAME_ not in('sjjp_poa_rebate_payment_approval','sjjp_poa_exhibition_requistion') 
order by pi.start_ DESC



--���æ����2018��E-WFϵͳ�����е��������ݣ�����ϸ���ȵ�ά�ȵ�������������ð���������WWID�����ţ��������ƣ���״̬��
SELECT distinct pr.code '���ݺ�',pr.create_time '���ݴ���ʱ��',pr.applicant '������',dept.name '����',
CASE pd.NAME_ 
WHEN 'sjjp_ap_ariba_purchase_requistion' THEN 'Ariba�ɹ���������' 
WHEN 'sjjp_ap_purchase_requistion' THEN 'SAP�ɹ���������' 
ELSE pd.NAME_ END '����',
CASE expense.description 
WHEN expense.description THEN expense.cnname 
ELSE NULL END '��������',
pr.totalAmount '���',
CASE pr.status 
WHEN 15 THEN '����ͨ��'
WHEN 10 THEN '������'
WHEN 5 THEN '�ѱ���'
WHEN 18 THEN 'PR�Ѵ���' 
WHEN 20 THEN 'PO �Ѵ���'
WHEN 25 THEN 'PO�Ѷ�ȡ'
WHEN 30 THEN 'PO ���ͷ�'
WHEN 35 THEN 'ѯ��ʧ��'
WHEN 40 THEN 'process'
WHEN 16 THEN 'Composing'
WHEN 17 THEN 'Submitted'
WHEN 19 THEN 'Denied'
WHEN 21 THEN 'Ordering'
WHEN 26 THEN 'Ordered'
WHEN 44 THEN 'Cancelling'
WHEN 46 THEN 'Cancelled'
WHEN 55 THEN 'Receiving'
WHEN 60 THEN 'Received'
WHEN 99 THEN 'Ariba ���'
ELSE NULL END '״̬'
FROM dbo.T_SJJP_PURCHASE_REQUISITION pr 
LEFT JOIN dbo.T_SJJP_PURCHASE_REQUISITION_LINE prl ON prl.pr_id = pr.id
LEFT JOIN (SELECT MAX(processInstanceId) prid,slipCode FROM  T_SJJP_PROCESS_SLIP_RELATION GROUP BY slipCode)psr ON psr.slipCode=pr.code
LEFT JOIN JBPM_TASKINSTANCE taski ON psr.prid=taski.PROCINST_
LEFT JOIN JBPM_TASK task ON taski.TASK_=task.ID_
LEFT JOIN JBPM_PROCESSDEFINITION pd ON task.PROCESSDEFINITION_=pd.ID_
LEFT JOIN dbo.T_SJJP_USER suser ON pr.applicant=suser.username
LEFT JOIN dbo.T_SJJP_DEPARTMENT dept ON suser.depart_id=dept.id
LEFT JOIN dbo.T_AP_BI_EXPENSE_TYPE expense  ON pr.expense_type=expense.id
where pr.is_template=0 AND pr.create_time between '2018-01-01' and '2018-12-31'
ORDER BY pr.create_time DESC


SELECT distinct pr.code '���ݺ�',pr.create_time '���ݴ���ʱ��',pr.applicant '������',dept.name '����',
case pd.NAME_ WHEN 'sjjp_ap_payment_requistion_for_salary_by_cost_center' THEN 'н�ʸ�������' 
WHEN 'sjjp_ap_payment_requistion' THEN '��ͨ��������' ELSE pd.NAME_ end '����',
CASE expense.description WHEN 'Consumer Promotion' THEN 'CPר�������'
WHEN 'Departmental Expense' THEN '�ճ�����' 
WHEN 'Tax,Bank Transfer' THEN '��������' 
WHEN 'Salary, Employee Benefit' THEN 'н�ʸ���' 
WHEN 'Inter-company' THEN '�ڲ�������˾' 
WHEN 'CME' THEN 'CMEר�������' ELSE NULL  END '��������'
,pr.totalAmount '���',
case pr.status 
WHEN 15 THEN '����ͨ��'
WHEN 10 THEN '������'
WHEN 5 tHEN '�ѱ���'
WHEN 18 tHEN 'PR�Ѵ���' 
WHEN 20 THEN 'PO �Ѵ���'
WHEN 25 tHEN 'PO�Ѷ�ȡ'
WHEN 30 tHEN 'PO ���ͷ�'
WHEN 35 THEN 'ѯ��ʧ��'
WHEN 40 THEN 'process'
ELSE NULL END '״̬'
FROM dbo.T_SJJP_PAYMENT_REQUEST pr 
LEFT JOIN T_SJJP_PAYMENT_REQUEST_LINE prl ON prl.pr_id = pr.id
LEFT JOIN (SELECT MAX(processInstanceId) prid,slipCode FROM  T_SJJP_PROCESS_SLIP_RELATION GROUP BY slipCode)psr ON psr.slipCode=pr.code
LEFT JOIN JBPM_TASKINSTANCE taski ON psr.prid=taski.PROCINST_
LEFT JOIN JBPM_TASK task ON taski.TASK_=task.ID_
LEFT JOIN JBPM_PROCESSDEFINITION pd ON task.PROCESSDEFINITION_=pd.ID_
LEFT JOIN dbo.T_SJJP_USER suser ON pr.applicant=suser.username
LEFT JOIN dbo.T_SJJP_DEPARTMENT dept ON suser.depart_id=dept.id
LEFT JOIN dbo.T_AP_BI_EXPENSE_TYPE expense  ON pr.expense_type=expense.id
where pr.isTemplate=0 AND pr.create_time between '2018-01-01' and '2018-12-31'
--AND expense.description NOT IN('Salary, Employee Benefit')
--AND suser.cost_center NOT IN('4749','6014')
--AND expense.description ='Salary, Employee Benefit'
ORDER BY pr.create_time DESC


--������н�ʸ���

SELECT distinct pr.code '���ݺ�',pr.create_time '���ݴ���ʱ��',pr.applicant '�����������˺�',suser.firstname'����',role.roleDescription '���������˽�ɫ',dept.name '���������˲���',
task.NAME_ '���̵�ǰ�ڵ�',case pd.NAME_ WHEN 'sjjp_ap_payment_requistion_for_salary_by_cost_center' THEN 'н�ʸ�������' 
WHEN 'sjjp_ap_payment_requistion' THEN '��ͨ��������' ELSE NULL end '����',
CASE expense.description WHEN 'Consumer Promotion' THEN 'CPר�������'
WHEN 'Departmental Expense' THEN '�ճ�����' 
WHEN 'Tax,Bank Transfer' THEN '��������' 
WHEN 'Salary, Employee Benefit' THEN 'н�ʸ���' 
WHEN 'Inter-company' THEN '�ڲ�������˾' 
WHEN 'CME' THEN 'CMEר�������' ELSE NULL  END '��������'
,pr.totalAmount '���',
case pr.status 
WHEN 15 THEN '����ͨ��'
WHEN 10 THEN '������'
WHEN 5 tHEN '�ѱ���'
WHEN 18 tHEN 'PR�Ѵ���' 
WHEN 20 THEN 'PO �Ѵ���'
WHEN 25 tHEN 'PO�Ѷ�ȡ'
WHEN 30 tHEN 'PO ���ͷ�'
WHEN 35 THEN 'ѯ��ʧ��'
WHEN 40 THEN 'process'
ELSE NULL END '״̬'
FROM dbo.T_SJJP_PAYMENT_REQUEST pr 
LEFT JOIN T_SJJP_PAYMENT_REQUEST_LINE prl ON prl.pr_id = pr.id
LEFT JOIN (SELECT MAX(processInstanceId) prid,slipCode FROM  T_SJJP_PROCESS_SLIP_RELATION GROUP BY slipCode)psr ON psr.slipCode=pr.code
LEFT JOIN JBPM_TASKINSTANCE taski ON psr.prid=taski.PROCINST_
LEFT JOIN JBPM_TASK task ON taski.TASK_=task.ID_
LEFT JOIN JBPM_PROCESSDEFINITION pd ON task.PROCESSDEFINITION_=pd.ID_
LEFT JOIN dbo.T_SJJP_USER suser ON pr.applicant=suser.username
LEFT JOIN dbo.T_SJJP_USERROLE ur ON ur.userId=suser.userId
LEFT JOIN dbo.T_SJJP_ROLE role ON role.roleId = ur.roleId
LEFT JOIN dbo.T_SJJP_DEPARTMENT dept ON suser.depart_id=dept.id
LEFT JOIN dbo.T_AP_BI_EXPENSE_TYPE expense  ON pr.expense_type=expense.id
where pr.isTemplate=0 AND pr.create_time between '2018-01-01' and '2018-12-31'
--AND suser.cost_center NOT IN('4749','6014')
AND expense.description NOT IN('Salary, Employee Benefit')
AND pr.code='20118032116030'
ORDER BY pr.create_time DESC

--��������-Ʒ����ʾ������
SELECT distinct pr.code '���ݺ�',pr.create_time '���ݴ���ʱ��',pr.applicant '������',dept.name '����',
case pd.NAME_ WHEN 'sjjp_sample_order_br' THEN 'Ʒ����ʾ�﷢������' 
WHEN 'sjjp_sample_order_fg' THEN '��Ʒ���뷢��������'
WHEN 'sjjp_sample_order_free_goods' THEN 'FreeGoods�������뵥����'
 ELSE pd.NAME_ end '����',
CASE expense.description WHEN expense.description THEN expense.cnname ELSE expense.description  END '��������'
,pr.TOTAL_AMOUNT '���',
case pr.status 
WHEN 15 THEN '����ͨ��'
WHEN 10 THEN '������'
WHEN 5 tHEN '�ѱ���'
WHEN 20 THEN 'SAP�ѷ���ȷ������'
WHEN 45 tHEN '��ȡ��'
WHEN 50 tHEN '����޸�'
ELSE NULL END '״̬'
FROM dbo.T_SJJP_SAMPLE_ORDER pr --����
LEFT JOIN dbo.T_SJJP_SAMPLE_ORDER_LINE prl ON prl.SO_ID = pr.ID --������
LEFT JOIN (SELECT MAX(processInstanceId) prid,slipCode FROM  T_SJJP_PROCESS_SLIP_RELATION GROUP BY slipCode)psr ON psr.slipCode=pr.code
LEFT JOIN JBPM_TASKINSTANCE taski ON psr.prid=taski.PROCINST_ --����ʵ��
LEFT JOIN JBPM_TASK task ON taski.TASK_=task.ID_ --���������
LEFT JOIN JBPM_PROCESSDEFINITION pd ON task.PROCESSDEFINITION_=pd.ID_ --����ģ��
LEFT JOIN dbo.T_SJJP_USER suser ON pr.applicant=suser.username --�û�
LEFT JOIN dbo.T_SJJP_DEPARTMENT dept ON suser.depart_id=dept.id  --���ű�
LEFT JOIN dbo.T_AP_BI_EXPENSE_TYPE expense  ON pr.EXP_TYP_ID=expense.id --��������
where pr.IS_TEMPLATE=0 --AND pr.create_time between '2018-01-01' and '2018-12-31'
--AND pr.CODE='3011805150915'
ORDER BY pr.create_time DESC



SELECT * FROM dbo.T_SJJP_PURCHASE_REQUISITION WHERE STATUS = 26
































