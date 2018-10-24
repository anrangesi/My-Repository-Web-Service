--根据流程名称查看所有属于该流程的单据
select distinct srt.* from T_SJJP_PROCESS_SLIP_RELATION srt 
LEFT JOIN JBPM_TASKINSTANCE ti ON srt.processInstanceId=ti.PROCINST_
LEFT JOIN JBPM_TASK task ON ti.TASK_=task.ID_
LEFT JOIN JBPM_PROCESSDEFINITION pd ON task.PROCESSDEFINITION_=pd.ID_
WHERE pd.NAME_='sjjp_ap_ariba_purchase_requistion'

--根据单据code查看单据下一审批人
select ti.* from T_SJJP_PROCESS_SLIP_RELATION srt 
LEFT JOIN JBPM_TASKINSTANCE ti ON srt.processInstanceId=ti.PROCINST_
WHERE srt.slipCode='10117032711803' 

SELECT * FROM dbo.T_SJJP_PURCHASE_REQUISITION WHERE code IN('10118062712649','10118062712650')
SELECT * FROM dbo.T_SJJP_PURCHASE_REQUISITION_LINE WHERE pr_id=19111
SELECT * FROM dbo.T_SJJP_USER WHERE username = '151200252'
SELECT * FROM dbo.T_SJJP_USER WHERE username = '151200054'
SELECT * FROM dbo.T_SJJP_USER WHERE username IN('106002091','106001522','106001502','92002209')
SELECT * FROM dbo.T_SJJP_USER WHERE userId=184
SELECT * FROM dbo.T_SJJP_USER WHERE userId=29

UPDATE T_SJJP_USER SET enabled=1 WHERE username='92430303'

SELECT distinct us.username,us.firstname,le.name,sp.downpay_limit_expense
 FROM dbo.T_SJJP_SIGNOFF_PERMISSION sp
LEFT JOIN dbo.T_SJJP_LEVEL le ON le.id=sp.level
LEFT JOIN dbo.T_SJJP_USER us ON le.id=us.level
WHERE enabled=1 AND us.level IS NOT NULL AND us.level=3
ORDER BY us.username

SELECT * FROM dbo.T_SJJP_USER WHERE enabled=1 AND level=3

SELECT u1.userId,u1.username,u1.reportTo_userId,u1.firstname,u1.level,u1.enabled FROM dbo.T_SJJP_USER u1
INNER JOIN 
dbo.T_SJJP_USER u2 ON u2.reportTo_userId=u1.userId
 WHERE u2.enabled=1 AND u2.level=3

 SELECT * FROM dbo.T_SJJP_USER u1
INNER JOIN 
dbo.T_SJJP_USER u2 ON u2.reportTo_userId=u1.userId
 WHERE u2.enabled=1 AND u2.level=3


 SELECT u1.userId,u1.username,u1.reportTo_userId,u1.firstname,u1.level,u1.enabled 
 FROM dbo.T_SJJP_USER u1 WHERE u1.userId=1511

 SELECT * FROM dbo.T_SJJP_USER WHERE reportTo_userId=575 AND enabled=1 


  SELECT su.* FROM dbo.T_SJJP_COST_CENTER cc
  LEFT JOIN dbo.T_SJJP_USER su ON cc.depart_head=su.username
  WHERE su.level IS NOT NULL 
  ORDER BY su.level

  SELECT * FROM dbo.T_SJJP_LEVEL WHERE 

    SELECT DISTINCT * FROM T_SJJP_COST_CENTER WHERE depart_head2 IS NOT NULL 

	SELECT userId,username,reportTo_userId,firstname,level,enabled 
	FROM dbo.T_SJJP_USER WHERE username in('152813018','89406061','89412944','92008028')

	SELECT userId,username,reportTo_userId,firstname,level,enabled 
	FROM dbo.T_SJJP_USER WHERE userId =1

	SELECT*FROM t_sjjp_user WHERE firstname LIKE '%mat%'
	SELECT * FROM dbo.T_SJJP_ROLE WHERE rolename LIKE '%mat%'



SELECT is_active,ariba_status,* FROM dbo.T_SJJP_PURCHASE_REQUISITION WHERE code IN('10118062712649','10118062712650')
SELECT * FROM dbo.T_ARIBA_IMPORT_REQ_STATUS WHERE SOURCESYSTEMDOCUMENTID IN( '10118062712649','10118062712650')
SELECT * FROM OPENQUERY(ariba_ewf,'select * from arbancdb.v_import_req_status where sourcesystemid=''SJJP-eWF''
and sourcesystemdocumentid in (''10118062712649'',''10118062712650'')')


SELECT * FROM T_SJJP_ARIBA_RECEIVE_SHIPTO

 SELECT 1 FROM T_SJJP_ARIBA_RECEIVE_SHIPTO  AS shipTo 
 WHERE t_ariba.SHPTO_ADDR_CD COLLATE Chinese_PRC_CI_AS= shipTo.SHPTO_ADDR_CD

 SELECT * FROM SP_ARIBA_SYNC_PO_CLOSED


 select distinct so "
			+ "from com.erry.sjjp.entity.slip.SampleOrder as so, "
			+ "com.erry.sjjp.entity.slip.SampleOrderLine as soLine "
			+ "where soLine.sampleOrder.id=so.id " + " and so.isTemplate=0 

SELECT so.APPLICANT '申请人',so.CREATOR '创建人',so.CODE '单据号',so.CREATE_TIME '创建时间',soLine.*
FROM dbo.T_SJJP_SAMPLE_ORDER so,dbo.T_SJJP_SAMPLE_ORDER_LINE soLine
WHERE soLine.SO_ID=so.ID AND so.IS_TEMPLATE=0 
order by so.CREATE_TIME DESC

SELECT so.*
FROM dbo.T_SJJP_SAMPLE_ORDER so,dbo.T_SJJP_SAMPLE_ORDER_LINE soLine
WHERE soLine.SO_ID=so.ID AND so.IS_TEMPLATE=0 
order by so.CREATE_TIME DESC

SELECT CASE so.APPLICANT 
WHEN so.APPLICANT THEN u.firstname ELSE null END '申请人',
CASE so.CREATOR 
WHEN so.CREATOR THEN u.firstname ELSE null  END '创建人',
so.* 
FROM dbo.T_SJJP_SAMPLE_ORDER so,dbo.T_SJJP_USER u WHERE so.IS_TEMPLATE=0 AND so.EXP_TYP_ID=1 order by so.CREATE_TIME DESC



SELECT * FROM dbo.T_SJJP_PURCHASE_REQUISITION_LINE

Consumer Promotion

SELECT * FROM dbo.T_AP_BI_EXPENSE_TYPE


select*FROM T_AP_BI_PRODUCT

--根据流程名称查看所有属于该流程的单据
select 
CASE pr.creator WHEN pr.creator THEN u.firstname ELSE u.firstname END 'creator',
 pr.* from T_SJJP_PROCESS_SLIP_RELATION srt 
LEFT JOIN JBPM_TASKINSTANCE ti ON srt.processInstanceId=ti.PROCINST_
LEFT JOIN JBPM_TASK task ON ti.TASK_=task.ID_
LEFT JOIN JBPM_PROCESSDEFINITION pd ON task.PROCESSDEFINITION_=pd.ID_
LEFT JOIN dbo.T_SJJP_PURCHASE_REQUISITION pr ON srt.slipCode=pr.code
LEFT JOIN dbo.T_SJJP_PURCHASE_REQUISITION_LINE prl ON pr.id=prl.pr_id
LEFT JOIN dbo.T_SJJP_USER u ON u.username=pr.creator
WHERE pd.NAME_='sjjp_ap_purchase_requistion'  ORDER BY pr.create_time DESC


select  pr.totalAmount,
 prl.* from T_SJJP_PROCESS_SLIP_RELATION srt 
LEFT JOIN JBPM_TASKINSTANCE ti ON srt.processInstanceId=ti.PROCINST_
LEFT JOIN JBPM_TASK task ON ti.TASK_=task.ID_
LEFT JOIN JBPM_PROCESSDEFINITION pd ON task.PROCESSDEFINITION_=pd.ID_
LEFT JOIN dbo.T_SJJP_PURCHASE_REQUISITION pr ON srt.slipCode=pr.code
LEFT JOIN dbo.T_SJJP_PURCHASE_REQUISITION_LINE prl ON pr.id=prl.pr_id
LEFT JOIN dbo.T_SJJP_USER u ON u.username=pr.creator
WHERE pd.NAME_='sjjp_ap_purchase_requistion'  ORDER BY pr.create_time DESC

SELECT MAX(is_brand) FROM T_SJJP_PURCHASE_REQUISITION WHERE code='10118090612818'
SELECT * FROM dbo.T_SJJP_PURCHASE_REQUISITION_LINE

SELECT * FROM [dbo].[T_AP_BI_PRODUCT]

-- SAP采购
SELECT pr.code,pr.creator,pr.applicant,dept.name '部门',
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

SELECT * FROM dbo.T_SJJP_SAMPLE_ORDER_LINE


SELECT * FROM dbo.T_SJJP_SHIPPING_ADDRESS


select prLine.* from dbo.T_SJJP_PURCHASE_REQUISITION_LINE prLine ,dbo.T_SJJP_PURCHASE_REQUISITION pr
WHERE pr.id=prLine.pr_id AND pr.is_brand = 1 and prLine.gr_closed = 1 AND pr.code='10117032711803'


--149：
SELECT * FROM dbo.T_ARIBA_IMPORT_REQ_STATUS WHERE SOURCESYSTEMDOCUMENTID IN( '10117032711803')
--Ariba：
select * from openquery(ariba_ewf,
'select * from arbancdb.v_import_req_status 
where sourcesystemid=''SJJP-eWF''
and sourcesystemdocumentid in (''10117032711803'')
 ')


 SELECT * FROM dbo.T_SJJP_USER WHERE username IN('106002414','702184431')
 --532814

SELECT pr.is_active,pr.VERSION,pr.* FROM 
dbo.T_SJJP_PURCHASE_REQUISITION pr WHERE pr.is_template=0
AND pr.code like'10117032711803%'
ORDER BY pr.create_time desc
 
 SELECT pr.* FROM T_SJJP_PURCHASE_REQUISITION pr WHERE pr.code ='10117032711803'
SELECT * FROM dbo.T_SJJP_PURCHASE_REQUISITION_LINE WHERE pr_id=17838 

 SELECT pr.* FROM T_SJJP_PURCHASE_REQUISITION pr WHERE pr.code ='10117032711803' AND is
SELECT * FROM dbo.T_SJJP_PURCHASE_REQUISITION_LINE WHERE pr_id=17838 AND

SELECT * FROM dbo.T_BI_CHOOSE_OPTION WHERE NAME='PR状态' AND CNVALUE='Ordered(Ariba)'

 SELECT pr.* FROM T_SJJP_PURCHASE_REQUISITION pr WHERE pr.status=5
 SELECT * FROM dbo.T_SJJP_PURCHASE_REQUISITION_LINE WHERE ariba_po_status=1
  SELECT pr.* FROM T_SJJP_PURCHASE_REQUISITION pr WHERE pr.id='14124'
SELECT * FROM dbo.T_AP_BI_EXPENSE_TYPE WHERE id=9
SELECT * FROM T_SJJP_EXP_CATEGORY 

SELECT * FROM dbo.T_SJJP_INTERNAL_ORDER WHERE id=2180



SELECT pr.* FROM T_SJJP_PURCHASE_REQUISITION pr
 WHERE pr.code ='10117032711803' AND pr.is_template=0 
 AND (pr.creator IN ('702184431') OR pr.applicant IN ('106002414')) 

 SELECT pr.* FROM T_SJJP_PURCHASE_REQUISITION pr
 WHERE pr.code ='10117032711803' AND pr.is_template=0 AND (pr.creator IN ('702184431') OR pr.applicant IN ('106002414'))

SELECT * FROM dbo.T_SJJP_PR_LINE_FA_INFO fa WHERE fa.PR_LINE_ID=17838

SELECT * FROM dbo.T_SJJP_USER WHERE lastname like'%matrix%'



SELECT * FROM dbo.T_SJJP_PURCHASE_REQUISITION WHERE status=26
SELECT * FROM dbo.T_SJJP_ROLE WHERE rolename LIKE '%matrix%'