--查看审批签字权限
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

--查看系统所有有效并且拥有level的用户
SELECT u.username,u.firstname,l.name FROM dbo.T_SJJP_USER u
LEFT JOIN dbo.T_SJJP_LEVEL l ON u.level=l.id
WHERE enabled=1 AND level IS NOT NULL ORDER BY l.name

--查看系统所有有效并且拥有level并且拥有审批金额的用户
SELECT distinct us.username,us.firstname,le.name,sp.downpay_limit_expense,us.level
 FROM dbo.T_SJJP_SIGNOFF_PERMISSION sp
LEFT JOIN dbo.T_SJJP_LEVEL le ON le.id=sp.level
LEFT JOIN dbo.T_SJJP_USER us ON le.id=us.level
WHERE enabled=1 AND us.level IS NOT NULL ORDER BY le.name

--查看系统所有有效但没有level的用户
SELECT * FROM T_SJJP_USER WHERE level IS NULL AND enabled=1

-- 根据wwid查看用户签字金额与level
SELECT distinct us.firstname,le.name,sp.*
 FROM dbo.T_SJJP_SIGNOFF_PERMISSION sp
LEFT JOIN dbo.T_SJJP_LEVEL le ON le.id=sp.level
LEFT JOIN dbo.T_SJJP_USER us ON us.level = sp.level
WHERE us.username='92430303'


SELECT * FROM T_SJJP_SIGNOFF_PERMISSION

--根据code查看单据属于哪一支流程
select distinct pd.* from T_SJJP_PROCESS_SLIP_RELATION srt 
LEFT JOIN JBPM_TASKINSTANCE ti ON srt.processInstanceId=ti.PROCINST_
LEFT JOIN JBPM_TASK task ON ti.TASK_=task.ID_
LEFT JOIN JBPM_PROCESSDEFINITION pd ON task.PROCESSDEFINITION_=pd.ID_
WHERE srt.slipCode='10117032711803' 

--根据流程名称查看所有属于该流程的单据
select distinct srt.* from T_SJJP_PROCESS_SLIP_RELATION srt 
LEFT JOIN JBPM_TASKINSTANCE ti ON srt.processInstanceId=ti.PROCINST_
LEFT JOIN JBPM_TASK task ON ti.TASK_=task.ID_
LEFT JOIN JBPM_PROCESSDEFINITION pd ON task.PROCESSDEFINITION_=pd.ID_
WHERE pd.NAME_='sjjp_ap_purchase_requistion'

--根据单据号查看单据属于哪个流程
SELECT distinct pr.applicant '申请人',dept.name '部门',pd.NAME_ '流程名称',prl.gr_amount '金额',pr.status '状态',pr.* 
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

--根据wwid找到用户所有的角色
SELECT a.lastname,a.userId,c.roleId,c.rolename,c.roleDescription 
FROM dbo.T_SJJP_USER a 
LEFT JOIN dbo.T_SJJP_USERROLE b ON b.userId = a.userId
LEFT JOIN dbo.T_SJJP_ROLE c ON b.roleId = c.roleId 
WHERE a.username='106991473'

--根据角色名查询用户
SELECT * FROM dbo.T_SJJP_USER 
WHERE userId IN(SELECT userId FROM dbo.T_SJJP_USERROLE 
WHERE roleId IN(SELECT roleId FROM dbo.T_SJJP_ROLE 
WHERE rolename = 'general manager'))

-- 角色名 用户 level等级
SELECT user_.firstname,user_.level,role.rolename
FROM dbo.T_SJJP_USERROLE ur,dbo.T_SJJP_ROLE role,dbo.T_SJJP_USER user_
WHERE ur.userId=user_.userId AND role.roleId=ur.roleId AND role.rolename='MD'  ORDER BY user_.level
AND role.rolename IN ('Chief Executive Officer','general manager','CFO')

--根据单据code查看单据下一审批人
select ti.* from T_SJJP_PROCESS_SLIP_RELATION srt 
LEFT JOIN JBPM_TASKINSTANCE ti ON srt.processInstanceId=ti.PROCINST_
WHERE srt.slipCode='10118101912108' 
89403873

-- SAP采购  is_brand为1时代表单据为SAP否则不是
SELECT pr.create_time,pr.code,pr.creator,pr.applicant,dept.name '部门',
CASE pr.status 
WHEN 15 THEN '审批通过'
WHEN 10 THEN '审批中'
WHEN 5 THEN '已保存'
WHEN 18 THEN 'PR已创建' 
WHEN 20 THEN 'PO 已创建'
WHEN 25 THEN 'PO已读取'
WHEN 30 THEN 'PO 已释放'
WHEN 35 THEN '询价失败'
WHEN 40 THEN '流程成功结束'
ELSE NULL END '状态'
,prl.product_name,
pr.totalAmount,
prl.pr_amount,prl.pr_unitprice,prl.pr_qty
FROM dbo.T_SJJP_PURCHASE_REQUISITION pr,
dbo.T_SJJP_PURCHASE_REQUISITION_LINE prl,
dbo.T_SJJP_USER u,
T_SJJP_DEPARTMENT dept
WHERE pr.id=prl.pr_id AND pr.applicant=u.username AND u.depart_id=dept.id AND is_brand=1 
 ORDER BY create_time DESC
 
 --品牌提示物申领
SELECT so.CREATE_TIME,so.CODE,so.CREATOR,so.APPLICANT,dept.name '部门',
CASE so.STATUS 
WHEN 5 THEN '已保存'
WHEN 10 THEN '审批中'
WHEN 15 THEN '审批通过'
WHEN 20 THEN 'SAP已返回确认数量'
WHEN 45 THEN '已取消'
WHEN 50 THEN '打回修改'
ELSE NULL END '状态',
product.PR_CODE '物料CODE',
product.PR_NAME '物料名称',
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

-- 单据状态表
SELECT * FROM dbo.T_BI_CHOOSE_OPTION

--------------------------------查询用户需要审批的单据--
select distinct 
ti.ACTORID_,
ti.ID_ 
, pi.start_ as 流程开始时间
,ti.create_ as 任务分配时间
,t.name_ as 任务类别,ti.name_ as 任务名称
,ti.description_ as 任务描述
, pd.name_ as 流程名
,relation.slipCode as 单据号
,relation.slipType as 单据类型
,vi.STRINGVALUE_ as 单据创建者WWWID
, case 
	when tp.POOLEDACTOR_ is not null then 1 
	ELSE 0 
  END 
,relation.slipId as 单据ID 
,tuser.firstname as 创建者中文名 
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



--请帮忙导出2018年E-WF系统中所有的申请数据，以最细粒度的维度导出，报告中最好包括审批人WWID，部门，流程名称，金额及状态，
SELECT distinct pr.code '单据号',pr.create_time '单据创建时间',pr.applicant '申请人',dept.name '部门',
CASE pd.NAME_ 
WHEN 'sjjp_ap_ariba_purchase_requistion' THEN 'Ariba采购审批流程' 
WHEN 'sjjp_ap_purchase_requistion' THEN 'SAP采购审批流程' 
ELSE pd.NAME_ END '流程',
CASE expense.description 
WHEN expense.description THEN expense.cnname 
ELSE NULL END '费用类型',
pr.totalAmount '金额',
CASE pr.status 
WHEN 15 THEN '审批通过'
WHEN 10 THEN '审批中'
WHEN 5 THEN '已保存'
WHEN 18 THEN 'PR已创建' 
WHEN 20 THEN 'PO 已创建'
WHEN 25 THEN 'PO已读取'
WHEN 30 THEN 'PO 已释放'
WHEN 35 THEN '询价失败'
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
WHEN 99 THEN 'Ariba 打回'
ELSE NULL END '状态'
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


SELECT distinct pr.code '单据号',pr.create_time '单据创建时间',pr.applicant '申请人',dept.name '部门',
case pd.NAME_ WHEN 'sjjp_ap_payment_requistion_for_salary_by_cost_center' THEN '薪资福利流程' 
WHEN 'sjjp_ap_payment_requistion' THEN '普通付款流程' ELSE pd.NAME_ end '流程',
CASE expense.description WHEN 'Consumer Promotion' THEN 'CP专家劳务费'
WHEN 'Departmental Expense' THEN '日常付款' 
WHEN 'Tax,Bank Transfer' THEN '银行托收' 
WHEN 'Salary, Employee Benefit' THEN '薪资福利' 
WHEN 'Inter-company' THEN '内部关联公司' 
WHEN 'CME' THEN 'CME专家劳务费' ELSE NULL  END '费用类型'
,pr.totalAmount '金额',
case pr.status 
WHEN 15 THEN '审批通过'
WHEN 10 THEN '审批中'
WHEN 5 tHEN '已保存'
WHEN 18 tHEN 'PR已创建' 
WHEN 20 THEN 'PO 已创建'
WHEN 25 tHEN 'PO已读取'
WHEN 30 tHEN 'PO 已释放'
WHEN 35 THEN '询价失败'
WHEN 40 THEN 'process'
ELSE NULL END '状态'
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


--不包含薪资福利

SELECT distinct pr.code '单据号',pr.create_time '单据创建时间',pr.applicant '单据申请人账号',suser.firstname'姓名',role.roleDescription '单据申请人角色',dept.name '单据申请人部门',
task.NAME_ '流程当前节点',case pd.NAME_ WHEN 'sjjp_ap_payment_requistion_for_salary_by_cost_center' THEN '薪资福利流程' 
WHEN 'sjjp_ap_payment_requistion' THEN '普通付款流程' ELSE NULL end '流程',
CASE expense.description WHEN 'Consumer Promotion' THEN 'CP专家劳务费'
WHEN 'Departmental Expense' THEN '日常付款' 
WHEN 'Tax,Bank Transfer' THEN '银行托收' 
WHEN 'Salary, Employee Benefit' THEN '薪资福利' 
WHEN 'Inter-company' THEN '内部关联公司' 
WHEN 'CME' THEN 'CME专家劳务费' ELSE NULL  END '费用类型'
,pr.totalAmount '金额',
case pr.status 
WHEN 15 THEN '审批通过'
WHEN 10 THEN '审批中'
WHEN 5 tHEN '已保存'
WHEN 18 tHEN 'PR已创建' 
WHEN 20 THEN 'PO 已创建'
WHEN 25 tHEN 'PO已读取'
WHEN 30 tHEN 'PO 已释放'
WHEN 35 THEN '询价失败'
WHEN 40 THEN 'process'
ELSE NULL END '状态'
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

--发货申请-品牌提示物申领
SELECT distinct pr.code '单据号',pr.create_time '单据创建时间',pr.applicant '申请人',dept.name '部门',
case pd.NAME_ WHEN 'sjjp_sample_order_br' THEN '品牌提示物发货流程' 
WHEN 'sjjp_sample_order_fg' THEN '样品申请发货单流程'
WHEN 'sjjp_sample_order_free_goods' THEN 'FreeGoods发货申请单流程'
 ELSE pd.NAME_ end '流程',
CASE expense.description WHEN expense.description THEN expense.cnname ELSE expense.description  END '费用类型'
,pr.TOTAL_AMOUNT '金额',
case pr.status 
WHEN 15 THEN '审批通过'
WHEN 10 THEN '审批中'
WHEN 5 tHEN '已保存'
WHEN 20 THEN 'SAP已返回确认数量'
WHEN 45 tHEN '已取消'
WHEN 50 tHEN '打回修改'
ELSE NULL END '状态'
FROM dbo.T_SJJP_SAMPLE_ORDER pr --发货
LEFT JOIN dbo.T_SJJP_SAMPLE_ORDER_LINE prl ON prl.SO_ID = pr.ID --发货行
LEFT JOIN (SELECT MAX(processInstanceId) prid,slipCode FROM  T_SJJP_PROCESS_SLIP_RELATION GROUP BY slipCode)psr ON psr.slipCode=pr.code
LEFT JOIN JBPM_TASKINSTANCE taski ON psr.prid=taski.PROCINST_ --任务实例
LEFT JOIN JBPM_TASK task ON taski.TASK_=task.ID_ --流程任务表
LEFT JOIN JBPM_PROCESSDEFINITION pd ON task.PROCESSDEFINITION_=pd.ID_ --流程模板
LEFT JOIN dbo.T_SJJP_USER suser ON pr.applicant=suser.username --用户
LEFT JOIN dbo.T_SJJP_DEPARTMENT dept ON suser.depart_id=dept.id  --部门表
LEFT JOIN dbo.T_AP_BI_EXPENSE_TYPE expense  ON pr.EXP_TYP_ID=expense.id --费用类型
where pr.IS_TEMPLATE=0 --AND pr.create_time between '2018-01-01' and '2018-12-31'
--AND pr.CODE='3011805150915'
ORDER BY pr.create_time DESC



SELECT * FROM dbo.T_SJJP_PURCHASE_REQUISITION WHERE STATUS = 26
































