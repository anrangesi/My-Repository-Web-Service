USE [jnjhoco_test_2]
GO

/****** Object:  StoredProcedure [dbo].[SYNC_MAIN_MAINDATA_PLATFORM_CUSTOMER]    Script Date: 04/11/2018 11:55:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER PROCEDURE [dbo].[SYNC_MAIN_MAINDATA_PLATFORM_CUSTOMER]
@returnParam NVARCHAR(50) OUTPUT,
@uuid NVARCHAR(200)  --作为本次更新的标识
AS
--声明变量
DECLARE 
		@ErrorMsg NVARCHAR(500),--记录错误信息
		@versionNum INT,--记录版本号
		@ischeckValid INT,--记录检验是否有问题
		@Version_Id NUMERIC(18,0),--记录版本ID
		@index INT,--循环的索引
		@budget_year INT,--预算年
		@len INT,--循环结束的位置
		@version_type INT;--在日志中记录的类型,客户主数据同步type 为2 
--设置初始值						
 SET @ischeckValid = 0;--0表示check没有问题
 SET @ErrorMsg = '';
 SET @index=0;
 SET @version_type = 2;
 SET @budget_year = YEAR(GETDATE());
 
 SELECT @versionNum = ISNULL((SELECT MAX(VERSION_NUM) 
 FROM T_MD_SYNC_SENDEMAIL_HISTORY WHERE VERSION_TYPE = @version_type),0)+1;
  

BEGIN 

---------------------------------------------------------
--先记录版本历史 写入日志
---------------------------------------------------------
INSERT INTO T_MD_SYNC_SENDEMAIL_HISTORY(VERSION_NUM,BEGIN_DATE,VERSION_TYPE,IS_NEED_EMAIL_FLAG) 
VALUES(@versionNum,GETDATE(),@version_type,0) SELECT @Version_Id = IDENT_CURRENT('T_MD_SYNC_SENDEMAIL_HISTORY');


-----------------------------------------------------
--同步BI 平台的ChooseOption 
-----------------------------------------------------

--INSERT INTO dbo.T_BI_CHOOSE_OPTION( CKEY ,PACKAGE_NAME ,CODE ,NAME ,IS_AVAILABLE , SORT_NO , CNVALUE ,ENVALUE )
--SELECT SORT_NO,'DEFAULT',OPTION_CODE,OPTION_NAME,1,SORT_NO,TP_Value,BI_Value FROM V_BI_CHOOSE_OPTION_SYNC

--Account
--SELECT *  FROM [LNK_DF].[JJCC_Staging_Test].[dbo].[View_BI_choose_option_to_TP] tmp 
--LEFT JOIN dbo.T_BI_CUSTOMER_ACCOUNT account  ON tmp.BI_Value = account. CODE
--WHERE tmp.code = 'AccountGroupID' AND tmp.BI_Value IS NOT NULL AND  tmp.BI_Value <> '' AND account.ID IS NULL


-------------------------------------------------
--打开try catch块  捕捉插入 临时表 数据时的异常
--第一步.插入数据到临时表中
-------------------------------------------------
---------------------------------------------------------
--插入客户数据到临时表
---------------------------------------------------------
----------------需要进行Update 的客户数据
SELECT @len =(SELECT COUNT(1) FROM [LNK_DF].[JJCC_Staging_Test].[dbo].[View_Store_Master_TO_TP] cus_VIEW 
					--LEFT  JOIN t_bi_customer cus ON cus_VIEW.CODE = cus.CODE 
					WHERE EXISTS(SELECT CODE FROM T_BI_CUSTOMER WHERE  cus_VIEW.CODE = CODE  AND (SYNC_DATE IS NULL OR cus_VIEW.SYNC_DATE <> SYNC_DATE  )));
WHILE  @index <@len
BEGIN   --开启循环
BEGIN TRAN  -- 开启事务
BEGIN TRY   --开启try catch
INSERT INTO T_IMP_BI_MAIN_CUSTOMER_SYNC(
		BU,CDCP_STATUS,CODE,INVOICE_CODE,MODIFY_DATE,
		NAME,OPEN_DATE,PAYER_CODE,SJJ_CODE,SRC,[STATUS],STORE_TYPE,SUPPLY_TYPE,
		CUS_ACCOUNT_ID,CUS_ACCOUNT_GROUP_ID,EXT_KSR_MGR,EXT_RSM,EXT_KSR,EXT_ASM_AKM,
		EXT_BRR_MGR,EXT_XTR,CUS_CHANNEL_ID,COMPANY_ID,REPSALES_ID,SAP_CUSTOMER_ID,
		SOLDTO_ID,[VERSION],DESTINATION,IS_DISTRIBUTOR,IS_ZC,BRAND_TYPE,NKA_NAME,FLAG_DEL,
		BIZ_STATUS,IS_ZC_SUPPLY,PAYMENT_VENDOR_ID,PAYLINK_CODE,BU1,
		EMAIL,UUID,VERSION_ID,errorCheck,Operate,bu2
)
SELECT  [BU] ,[CDCP_STATUS],[CODE],[INVOICE_CODE],[MODIFY_DATE],[NAME]
		,[OPEN_DATE],[PAYER_CODE],[SJJ_CODE] ,[SRC],[STATUS],[STORE_TYPE],[SUPPLY_TYPE]
		,[CUS_ACCOUNT_ID],[CUS_ACCOUNT_GROUP_ID],[EXT_KSR_MGR],[EXT_RSM],null,[EXT_ASM_AKM]--[EXT_KSR]
		,[EXT_BRR_MGR],[EXT_XTR],[CUS_CHANNEL_ID],'HOCO',[REPSALES_ID],[SAP_CUSTOMER_ID]
		,[SOLDTO_ID],CONVERT(NUMERIC(19,0),CASE WHEN [VERSION] ='' or [VERSION] IS  NULL  THEN '0' ELSE  [VERSION] END),[DESTINATION],CONVERT(TINYINT,[IS_DISTRIBUTOR]),CONVERT(TINYINT,[IS_ZC]),[BRAND_TYPE],[NKA_NAME],CONVERT(TINYINT,[FLAG_DEL])
		,null,CONVERT(TINYINT,[IS_ZC_SUPPLY]),[PAYMENT_VENDOR_ID],[PAYLINK_CODE],[BU1]
		,CASE WHEN [EMAIL] = '待维护' THEN NULL ELSE [EMAIL] END,@uuid,@Version_Id,1,2,
		case
		when TMP.BU='KA' AND TMP.NKA_NAME in(select KA_NAME from T_CUS_ACCOUNT_LIST  where YEAR = @budget_year 参数Year
					and IS_VALID = 1) AND TMP.SUPPLY_TYPE = 'Direct'  THEN 'KA' 
		when (  
				(TMP.BU='KA'
					and
					(
					TMP.NKA_NAME not in(select KA_NAME from T_CUS_ACCOUNT_LIST where YEAR = @budget_year and IS_VALID = 1)
					or TMP.NKA_NAME is null
										)
				)
				or
				(TMP.BU='KA'
					and
					TMP.SUPPLY_TYPE = 'Indirect'
				)
			)or TMP.BU='GT' OR TMP.BU = 'DT'  then 'GT'
		when TMP.BU='GT-COS'  then 'COS'
		when TMP.BU='GTBNM' or TMP.BU='BNMKA-ELSKER' or TMP.BU='BNMKA' or TMP.BU='BNMGT' then 'BNM'
		when TMP.BU='E-COM' or TMP.BU='ECOMGT' or TMP.BU='ECOMKA' then 'ECOM'
		when TMP.BU='WS' then 'WS'
		when TMP.BU='GTN' then null
		END AS BU2
		FROM(
			SELECT cus_VIEW.*,ROW_NUMBER() OVER (ORDER BY cus_VIEW.CODE) AS rownum 
			FROM [LNK_DF].[JJCC_Staging_Test].[dbo].[View_Store_Master_TO_TP]  cus_VIEW 
			--LEFT  JOIN t_bi_customer cus ON cus_VIEW.CODE = cus.CODE 
			--根据同步时间做判断
			WHERE EXISTS(SELECT CODE FROM T_BI_CUSTOMER WHERE  cus_VIEW.CODE = CODE  AND (SYNC_DATE IS NULL OR cus_VIEW.SYNC_DATE <> SYNC_DATE  ))
		) TMP
WHERE  tmp.rownum between @index+1 and @index+10000;
SET  @index= @index+10000;
COMMIT  TRAN --事务提交
END TRY

BEGIN CATCH 
	--获取异常日志
	ROLLBACK TRAN
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		   END_DATE = GETDATE(),PROC_NAME = ERROR_PROCEDURE(),
		   ERROR_MSG = '存储过程运行异常,插入临时表数据失败:'+ERROR_MESSAGE() WHERE id = @Version_Id;
	RETURN -1;
END CATCH
END  ;

---------------------------需要进行Insert 的客户数据
SET  @index= 0;
SELECT @len =(SELECT count(1) FROM [LNK_DF].[JJCC_Staging_Test].[dbo].[View_Store_Master_TO_TP]  cus_VIEW
			--LEFT  JOIN t_bi_customer cus ON cus_VIEW.CODE = cus.CODE 
			WHERE cus_VIEW.CODE IS NOT NULL and cus_VIEW.CODE <>'#N/A' and cus_VIEW.CODE <>'0' and cus_VIEW.CODE <> ''  
				   AND NOT EXISTS (SELECT CODE FROM dbo.T_BI_CUSTOMER WHERE cus_VIEW.CODE = CODE));
WHILE  @index <@len
BEGIN   --开启循环
BEGIN TRAN  -- 开启事务
BEGIN TRY   --开启try catch
INSERT INTO T_IMP_BI_MAIN_CUSTOMER_SYNC(
		BU,CDCP_STATUS,CODE,INVOICE_CODE,MODIFY_DATE,
		NAME,OPEN_DATE,PAYER_CODE,SJJ_CODE,SRC,[STATUS],STORE_TYPE,SUPPLY_TYPE,
		CUS_ACCOUNT_ID,CUS_ACCOUNT_GROUP_ID,EXT_KSR_MGR,EXT_RSM,EXT_KSR,EXT_ASM_AKM,
		EXT_BRR_MGR,EXT_XTR,CUS_CHANNEL_ID,COMPANY_ID,REPSALES_ID,SAP_CUSTOMER_ID,
		SOLDTO_ID,[VERSION],DESTINATION,IS_DISTRIBUTOR,IS_ZC,BRAND_TYPE,NKA_NAME,FLAG_DEL,
		BIZ_STATUS,IS_ZC_SUPPLY,PAYMENT_VENDOR_ID,PAYLINK_CODE,BU1,
		EMAIL,UUID,VERSION_ID,errorCheck,Operate,BU2
)
SELECT  [BU] ,[CDCP_STATUS],[CODE],[INVOICE_CODE],[MODIFY_DATE],[NAME]
		,[OPEN_DATE],[PAYER_CODE],[SJJ_CODE] ,[SRC],[STATUS],[STORE_TYPE],[SUPPLY_TYPE]
		,[CUS_ACCOUNT_ID],[CUS_ACCOUNT_GROUP_ID],[EXT_KSR_MGR],[EXT_RSM],null,[EXT_ASM_AKM]--[EXT_KSR]
		,[EXT_BRR_MGR],[EXT_XTR],[CUS_CHANNEL_ID],'HOCO',[REPSALES_ID],[SAP_CUSTOMER_ID]
		,[SOLDTO_ID],CONVERT(NUMERIC(19,0),CASE WHEN [VERSION] ='' or [VERSION] IS  NULL  THEN '0' ELSE  [VERSION] END),[DESTINATION],CONVERT(TINYINT,[IS_DISTRIBUTOR]),CONVERT(TINYINT,[IS_ZC]),[BRAND_TYPE],[NKA_NAME],CONVERT(TINYINT,[FLAG_DEL])
		,null,CONVERT(TINYINT,[IS_ZC_SUPPLY]),[PAYMENT_VENDOR_ID],[PAYLINK_CODE],[BU1]
		,CASE WHEN [EMAIL] = '待维护' THEN NULL ELSE [EMAIL] END,@uuid,@Version_Id,1,1,
		case
		when TMP.BU='KA' AND TMP.NKA_NAME in(select KA_NAME from T_CUS_ACCOUNT_LIST  where YEAR = @budget_year --参数Year
					and IS_VALID = 1) AND TMP.SUPPLY_TYPE = 'Direct'  THEN 'KA' 
		when (  
				(TMP.BU='KA'
					and
					(
					TMP.NKA_NAME not in(select KA_NAME from T_CUS_ACCOUNT_LIST where YEAR = @budget_year and IS_VALID = 1)
					or TMP.NKA_NAME is null
					)
				)
				or
				(TMP.BU='KA'
					and
					TMP.SUPPLY_TYPE = 'Indirect'
				)
			)or TMP.BU='GT' OR TMP.BU = 'DT'  then 'GT'
		when TMP.BU='GT-COS'  then 'COS'
		when TMP.BU='GTBNM' or TMP.BU='BNMKA-ELSKER' or TMP.BU='BNMKA' or TMP.BU='BNMGT' then 'BNM'
		when TMP.BU='E-COM' or TMP.BU='ECOMGT' or TMP.BU='ECOMKA' then 'ECOM'
		when TMP.BU='WS' then 'WS'
		when TMP.BU='GTN' then null
		END AS BU2

		FROM(
			SELECT cus_VIEW.*,ROW_NUMBER() OVER (ORDER BY cus_VIEW.CODE) AS rownum 
			FROM [LNK_DF].[JJCC_Staging_Test].[dbo].[View_Store_Master_TO_TP]  cus_VIEW 
			--LEFT  JOIN t_bi_customer cus ON cus_VIEW.CODE = cus.CODE 
			--根据同步时间做判断
			WHERE cus_VIEW.CODE IS NOT NULL and cus_VIEW.CODE <>'#N/A' and cus_VIEW.CODE <>'0' and cus_VIEW.CODE <> ''  
				   AND NOT EXISTS (SELECT CODE FROM dbo.T_BI_CUSTOMER WHERE cus_VIEW.CODE = CODE)
		) TMP
WHERE  tmp.rownum between @index+1 and @index+10000;
SET  @index= @index+10000;
COMMIT  TRAN --事务提交
END TRY

BEGIN CATCH 
	--获取异常日志
	ROLLBACK TRAN
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		   END_DATE = GETDATE(),PROC_NAME = ERROR_PROCEDURE(),
		   ERROR_MSG = '存储过程运行异常,插入临时表数据失败:'+ERROR_MESSAGE() WHERE id = @Version_Id;
	RETURN -1;
END CATCH
END  ;

SET  @index= 0;

BEGIN TRAN
BEGIN TRY


------------------------------------------------------
--插入区域关系 到临时表
------------------------------------------------------
INSERT INTO T_IMP_BI_MAIN_HRC_SALEGEO_SYNC(cus_code,
CITY,
REGION,
DUG,
DU,
BUDGET_YEAR,
VALID,
UUID,
VERSION_ID)
SELECT 
	   CODE
	  ,City
      ,Region
      ,Area
	  ,'Na'
	  ,@budget_year
	  ,1
	  ,@uuid
	  ,@Version_Id 
FROM [LNK_DF].[JJCC_Staging_Test].[dbo].[View_Store_Master_TO_TP]
--根据同步时间做判断
WHERE   CODE IN (SELECT CODE  FROM T_IMP_BI_MAIN_CUSTOMER_SYNC WHERE UUID = @uuid);


---------------------------------------
--插入Ucode
---------------------------------------
insert into T_IMP_BI_MAIN_CUSTOMER_UCODE(CUS_CODE,UCODE,UUID,VERSION_ID)
SELECT [Store_Code]
      ,[Ucode]
	  ,@uuid
	  ,@Version_Id
FROM [LNK_DF].[JJCC_Staging_Test].[dbo].[View_Store_Ucode_Mapping]
WHERE Store_Code IN (SELECT CODE  FROM T_IMP_BI_MAIN_CUSTOMER_SYNC WHERE UUID = @uuid );


COMMIT TRAN
END TRY
BEGIN CATCH
	--获取异常日志
	ROLLBACK TRAN
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		   END_DATE = GETDATE(),PROC_NAME = ERROR_PROCEDURE(),
		   ERROR_MSG = '存储过程运行异常,插入临时表数据失败:'+ERROR_MESSAGE() WHERE id = @Version_Id;
	RETURN -1;
END CATCH

-------------------------提交插入结果
BEGIN TRAN
BEGIN TRY

--------------------------------------------
--第二步 校验数据
--客户数据检查
--处理区域关系数据,检查是否有新增的客户区域关系
--------------------------------------------

---------------------校验重复code 的数据
UPDATE 
tmp
SET tmp.errorCheck = 0,@ischeckValid = 1,tmp.errorMsg = (ISNULL(tmp.errorMsg,'')+'[ERROR:<客户信息中有重复的code.>]'+CHAR(10))
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
WHERE UUID = @uuid AND
EXISTS(
SELECT CODE FROM
T_IMP_BI_MAIN_CUSTOMER_SYNC
WHERE UUID = @uuid
AND CODE = tmp.CODE
GROUP BY CODE
HAVING COUNT(1)>1
);


-----------------2.1 校验有错误的客户数据-------------------------------------------------
---------2.1.1  去除客户中的 非空列  为null值的
update t set t.errorCheck = 0,@ischeckValid = 1,t.errorMsg = (ISNULL(t.errorMsg,'')+'[ERROR:<客户信息中不为null的列有null值.>]'+CHAR(10))
FROM  T_IMP_BI_MAIN_CUSTOMER_SYNC t
where
t.uuid = @uuid and ( 
t.NAME IS NULL OR t.NAME = '' OR 
t.NKA_NAME IS NULL OR t.NKA_NAME = '' OR 
t.SRC IS  NULL  OR
t.BU  IS  NULL   or  t.BU = '' OR 
t.IS_ZC_SUPPLY IS  NULL OR 
t.IS_ZC IS  NULL  OR 
t.STATUS IS  NULL OR 
t.CDCP_STATUS IS  NULL  OR 
t.SOLDTO_ID IS  NULL  OR  t.SOLDTO_ID  = '' OR 
t.INVOICE_CODE IS  NULL  OR t.INVOICE_CODE   = '' or
t.SUPPLY_TYPE IS  NULL OR t.SUPPLY_TYPE   = ''
);

--------2.1.2 校验Sap相关客户是否在系统中存在
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<Sap_Customer_id在SapCustomer中没有找到对应的客户!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp 
LEFT  JOIN  t_sap_customer cus on tmp.SAP_CUSTOMER_ID = cus.CODE and  cus.COCD = '7046'
WHERE tmp.UUID = @uuid AND SRC = 1 and cus.ID IS  NULL ;

--------2.1.3  校验cusChannel 信息
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<客户渠道(cus_channel_id)在系统中没有找到对应的渠道信息!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
left join t_bi_customer_channel channel on  tmp.cus_channel_id = channel.code
WHERE tmp.UUID = @uuid AND tmp.CUS_CHANNEL_ID IS NOT NULL AND tmp.CUS_CHANNEL_ID <> '' AND channel.ID IS  NULL ;
 
----------2.1.4 检验 AcountGroup信息   accountGroup 改成由Account带出
--update tmp 
--set  tmp.errorCheck = 0,@ischeckValid = 1,
--     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<客户Account组(cus_account_group_id)在系统中没有找到对应的AccountGroup信息!>]' )
--from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
--left join t_bi_customer_account_group accountgroup on  tmp.cus_account_group_id = accountgroup.code
--WHERE tmp.UUID = @uuid AND tmp.CUS_ACCOUNT_GROUP_ID IS NOT NULL AND tmp.CUS_ACCOUNT_GROUP_ID <> '' AND  accountgroup.ID IS  NULL ;

--------2.1.4 检验 Account信息
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<客户Account(cus_account_id)在系统中没有找到对应的Account信息!>]' +CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
left join t_bi_customer_account account on  tmp.CUS_ACCOUNT_ID = account.CODE
WHERE tmp.UUID = @uuid AND tmp.CUS_ACCOUNT_ID IS NOT NULL AND tmp.CUS_ACCOUNT_ID <> '' AND  account.ID IS NULL ;

--------2.1.5  校验客户负责人信息
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<客户负责人(repsales_id)信息不存在或者在系统中没有找到对应的用户!>]'+CHAR(10) )
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.SYSUSER  u ON  tmp.repsales_id = u.USERNAME
left join t_bi_user repsales ON  repsales.SYSUSERID = u.ID
WHERE tmp.UUID = @uuid AND repsales.ID IS  NULL ;

--------2.1.6   检查 sap soldTo Code
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<Sap Soldto(invoice_code)信息不存在或者在系统中没有找到对应的SapCustomer!>]'+CHAR(10) )
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp 
LEFT JOIN T_SAP_CUSTOMER CUS ON tmp.invoice_code = cus.code AND CUS.COCD = '7046'
LEFT JOIN  T_SAP_CUSTOMER_FUCTION FUNCT on FUNCT.CUSTOMER = CUS.ID AND FUNCT.FUNCT = 'AG'
WHERE tmp.UUID = @uuid AND (CUS.ID is NULL OR  FUNCT.ID IS NULL);


--------2.1.7  检查销售主管 EXT_BRR_MGR 信息 
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<销售主管(EXT_BRR_MGR)在系统中没有找到对应的用户!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.SYSUSER U_BRR ON U_BRR.USERNAME = tmp.EXT_BRR_MGR  
left join t_bi_User BRR on BRR.SYSUSERID = U_BRR.ID
WHERE tmp.UUID = @uuid AND tmp.EXT_BRR_MGR IS NOT NULL AND tmp.EXT_BRR_MGR <> '' AND BRR.ID IS  NULL ;

---------2.1.8   检查协调人信息 
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<协调人(EXT_XTR)在系统中没有找到对应的用户!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.SYSUSER U_XTR ON U_XTR.USERNAME = tmp.EXT_XTR 
left join t_bi_User XTR ON XTR.SYSUSERID = U_XTR.ID
WHERE tmp.UUID = @uuid AND tmp.EXT_XTR IS NOT NULL AND tmp.EXT_XTR <> '' AND XTR.ID IS  NULL ;

---------2.1.9 检查ASM/AKM 
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<AKM/ASM(EXT_ASM_AKM)在系统中没有找到对应的用户!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.SYSUSER U_ASM ON U_ASM.USERNAME = tmp.EXT_ASM_AKM
left join t_bi_User ASM on ASM.SYSUSERID = U_ASM.ID
WHERE tmp.UUID = @uuid AND tmp.EXT_ASM_AKM IS NOT NULL AND tmp.EXT_ASM_AKM <> '' AND ASM.ID IS  NULL ;

--------2.1.10  检查RSM
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<RSM(EXT_RSM)在系统中没有找到对应的用户!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.SYSUSER U_RSM ON U_RSM.USERNAME = tmp.EXT_RSM
left join t_bi_User RSM on RSM.SYSUSERID = U_RSM.ID
WHERE tmp.UUID = @uuid AND tmp.EXT_RSM IS NOT NULL AND tmp.EXT_RSM <> '' AND  RSM.ID IS  NULL ;

-------2.1.11 DESTINATION


-------2.1.12 付款用vendor 
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<SapVendor(PAYMENT_VENDOR_ID)在系统中没有找到对应的Vendor!>]'+CHAR(10))
FROM  T_IMP_BI_MAIN_CUSTOMER_SYNC tmp 
LEFT JOIN t_sap_vendor VENDOR ON TMP.PAYMENT_VENDOR_ID = VENDOR.CODE
WHERE tmp.UUID = @uuid AND tmp.PAYMENT_VENDOR_ID IS NOT NULL AND tmp.PAYMENT_VENDOR_ID <> '' AND VENDOR.ID is null;

-------2.1.13  检验 paylink
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<PayLink(PAYLINK_ID)在系统中没有找到对应的SapCutomer!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
left join t_sap_customer cus on tmp.PAYLINK_ID = cus.code and cus.cocd = '7046'
WHERE tmp.UUID = @uuid AND tmp.PAYLINK_ID IS NOT NULL AND tmp.PAYLINK_ID <> '' AND cus.ID is null;

-------2.1.14 品牌适用范围不能为空
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<品牌适用范围(BRAND_TYPE)为空,或者chooseOption中没有对应的值!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.T_BI_CHOOSE_OPTION brandOption ON  brandOption.CODE = 'CUS_BRAND_TYPE' AND brandOption.CNVALUE = tmp.BRAND_TYPE 
WHERE tmp.UUID = @uuid  AND brandOption.CKEY IS NULL;

-------2.1.15 email验证  BU为 GT 时不能为空
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<Email在BU为GT的时候不能为空!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
WHERE tmp.UUID = @uuid AND BU IN ( 'GT','DT') AND (EMAIL IS NULL OR EMAIL = '') ;


-------2.1.16 STORE_TYPE chooseOption不能为空
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<门店类型在chooseOption中没有对应的值!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.T_BI_CHOOSE_OPTION brandOption ON  brandOption.CODE = 'STORE_TYPE' AND brandOption.CNVALUE = tmp.STORE_TYPE
WHERE tmp.UUID = @uuid AND brandOption.CKEY IS NULL AND (tmp.STORE_TYPE IS NOT NULL OR tmp.STORE_TYPE <> '');

-------2.1.17 SUPPLY_TYPE chooseOption不能为空
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<供应类型在chooseOption中没有对应的值!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.T_BI_CHOOSE_OPTION brandOption ON  brandOption.CODE = 'SUPPLY_TYPE' AND brandOption.CNVALUE = tmp.SUPPLY_TYPE 
WHERE tmp.UUID = @uuid AND brandOption.CKEY IS NULL AND (tmp.SUPPLY_TYPE IS NOT NULL OR tmp.SUPPLY_TYPE <> '');

--------2.1.18  payer_code 必须是sapcustomer 并且  是payer
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<Sap Soldto(invoice_code)信息不存在或者在系统中没有找到对应的SapCustomer!>]' +CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp 
LEFT JOIN T_SAP_CUSTOMER sapCUS ON tmp.PAYER_CODE = sapCUS.code AND sapCUS.COCD = '7046'
LEFT  JOIN  T_SAP_CUSTOMER_FUCTION FUNCT on FUNCT.CUSTOMER1 = sapCUS.ID AND FUNCT.FUNCT = 'RG'
WHERE tmp.UUID = @uuid AND tmp.PAYER_CODE IS NOT NULL AND tmp.PAYER_CODE <> '' AND (sapCUS.ID is NULL OR  FUNCT.ID IS NULL);

---------------------------------------------------------
--2.2 check 有错误的客户区域关系,记录到错误中发送邮件
--1.region,dug,city 为null
--2. region,dug,city 在当前年没有定义
---------------------------------------------------------
UPDATE tmp SET tmp.VALID = 0,@ischeckValid = 1,tmp.ERROR_MSG = (ISNULL(tmp.ERROR_MSG,'')+
('[ERROR:{预算年为:'+CONVERT(NVARCHAR(50),tmp.BUDGET_YEAR)+'#'+
(CASE 
	WHEN city.city_id IS NULL
		THEN '[error:city->'+tmp.city+'在当前预算年没有定义!]' 
		ELSE '[city:'+city.city_code+']' end)
		+','+
(CASE 
	WHEN region.region_id IS NULL 
		THEN '[error:region->'+tmp.region+'在当前预算年没有定义!]' 
		ELSE '[region:'+region.code+']' END )
		+','+
(CASE 
	WHEN dug.ID IS NULL 
	THEN '[error:area->'+tmp.dug+'在当前预算年没有定义!]' 
	ELSE '[dug:'+dug.code +']' END))+'}]')+CHAR(10)
FROM 
T_IMP_BI_MAIN_HRC_SALEGEO_SYNC tmp
LEFT JOIN dbo.V_BI_REGION region ON region.CODE = tmp.REGION AND region.BUDGET_YEAR = tmp.BUDGET_YEAR
LEFT JOIN (
select distinct dug.code,dug.id from t_hrc_salesgeo sh 
left join t_bi_dug dug on sh.dug_id = dug.id
where sh.budget_year = @budget_year
) dug ON dug.CODE = tmp.DUG 
LEFT JOIN (
select geo.code city_code,max(city.id) city_id from t_hrc_salesgeo sh 
left join t_bi_city city on sh.city_id = city.id
left join t_bi_geo geo on city.city_id = geo.id 
where sh.budget_year = @budget_year
group by geo.code
) city ON city.city_code = tmp.city
WHERE tmp.UUID = @uuid  AND 
(region.region_id is null or dug.id is null or city.city_id is null);

---------------------------------------------------
--客户 - 区域关系  必须同时有效 即两者的检查全部通过
---------------------------------------------------
UPDATE cusTmp SET cusTmp.errorCheck = hrcTmp.VALID,cusTmp.errorMsg = (ISNULL(cusTmp.errorMsg,'') + '[ERROR:<客户对应区域关系有错误!>]'+CHAR(10))
FROM
T_IMP_BI_MAIN_CUSTOMER_SYNC cusTmp
LEFT JOIN T_IMP_BI_MAIN_HRC_SALEGEO_SYNC hrcTmp ON cusTmp.code = hrcTmp.cus_code AND hrcTmp.UUID = cusTmp.UUID
WHERE cusTmp.UUID = @uuid AND cusTmp.errorCheck = 1 and hrcTmp.VALID = 0;

--UPDATE hrcTmp SET hrcTmp.VALID = cusTmp.errorCheck , hrcTmp.ERROR_MSG = (ISNULL(hrcTmp.ERROR_MSG,'') + '[ERROR:<客户主数据有错误!')
--FROM
--T_IMP_BI_MAIN_CUSTOMER_SYNC cusTmp
--LEFT JOIN T_IMP_BI_MAIN_HRC_SALEGEO_SYNC hrcTmp ON cusTmp.code = hrcTmp.cus_code AND hrcTmp.UUID = cusTmp.UUID
--WHERE cusTmp.UUID = @uuid AND cusTmp.errorCheck = 0 and hrcTmp.VALID = 1;


--------------------------------------
--最后 检验客户的sold_to是否有效,只针对间供客户,因为直供客户的soldto是本身
--------------------------------------
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<直供客户(soldTo_id)不存在或者是在系统中没有找到对应的直供客户,或者是对应的直供客户信息有错误,无法新增!>]')+CHAR(10)
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
where tmp.soldTo_id is not null and (
	tmp.soldTo_id not in (select code from t_bi_customer) and 
	tmp.soldTo_id not in(
		SELECT tmp.CODE 
		FROM  T_IMP_BI_MAIN_CUSTOMER_SYNC tmp 
		LEFT join T_IMP_BI_MAIN_HRC_SALEGEO_SYNC hrc on tmp.uuid = hrc.uuid and tmp.code = hrc.cus_code 
		WHERE tmp.uuid = @uuid and tmp.errorCheck = 1 and hrc.VALID = 1 AND tmp.Operate = 1
	)
) AND tmp.UUID = @uuid AND tmp.SUPPLY_TYPE IN (SELECT cnvalue FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CKEY = 1);

IF @ischeckValid =1 BEGIN
	SET @ErrorMsg = '核对客户数据时失败,临时表为:T_IMP_BI_MAIN_HRC_SALEGEO_SYNC&&T_IMP_BI_MAIN_CUSTOMER_SYNC,对应UUID为:'+@uuid;
END
-----------------提交校验结果
COMMIT TRAN

END TRY

BEGIN CATCH
	ROLLBACK TRAN
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		   END_DATE = GETDATE(),PROC_NAME = ERROR_PROCEDURE(),
		   ERROR_MSG = '存储过程运行异常,校验客户数据时失败:'+ERROR_MESSAGE()+',校验错误:'+@ErrorMsg WHERE id = @Version_Id;
	RETURN -1;
END CATCH


--------------------------------------------------
--对通过基础校验的数据,进行业务校验
--------------------------------------------------
BEGIN TRAN
BEGIN TRY
-----------1.客户是经销商  ,那么客户渠道为null 并且不能是总仓和总仓供货,  如果不是经销商  那么必须要有客户渠道
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[Error:客户是经销商,那么客户渠道为null 并且不能是总仓和总仓供货;如果不是经销商,那么必须要有客户渠道.]'+CHAR(10)
FROM dbo.T_IMP_BI_MAIN_CUSTOMER_SYNC imp
WHERE imp.errorCheck = 1 AND imp.UUID = @uuid
AND (
		(imp.IS_DISTRIBUTOR = 1 AND (imp.CUS_CHANNEL_ID IS NOT NULL OR imp.IS_ZC = 1 OR imp.IS_ZC_SUPPLY = 1 ))
		OR
        ((imp.IS_DISTRIBUTOR = 0 OR imp.IS_DISTRIBUTOR IS NULL ) AND imp.CUS_CHANNEL_ID IS NULL)
	);


-----------2.总仓和总仓供货 的校验  一个客户不能同时为总仓和总仓供货
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[ERROR:一个客户不能同时为总仓和总仓供货.]'+CHAR(10)
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC imp
WHERE imp.errorCheck = 1 AND imp.UUID = @uuid
AND imp.is_zc = 1 AND imp.is_zc_supply =1;


------------3.客户如果是总仓,那么必须是sap相关并且是直供
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[ERROR:客户如果是总仓,那么必须是sap相关并且是直供.]'+CHAR(10)
--SELECT * 
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC imp 
WHERE imp.errorCheck = 1 AND imp.UUID = @uuid 
AND is_zc = 1 AND ( src <> 1 OR supply_type IN(SELECT cnvalue FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CKEY = 1));

-----------4.总仓供货,那么sap sold_to 必须是总仓
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[ERROR:总仓供货,那么 invoice_code(sap sold_to)对应的customer必须存在并且是总仓.]'+CHAR(10)
--SELECT * 
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC imp
WHERE imp.errorCheck = 1 AND imp.UUID = @uuid 
AND is_zc_supply = 1 
AND NOT EXISTS(SELECT code FROM t_bi_customer WHERE code = imp.invoice_code AND is_zc = 1  )
AND NOT EXISTS(SELECT code FROM T_IMP_BI_MAIN_CUSTOMER_SYNC WHERE code = imp.invoice_code AND is_zc = 1 AND UUID = @uuid AND errorCheck = 1 );



-----------5 间供的客户 名下必须没有 客户的直供是它 
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[ERROR:间供客户必须没有客户的直供是它.]'+CHAR(10)
--SELECT * 
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC IMP
WHERE IMP.UUID=@uuid  AND IMP.errorCheck = 0 
      AND IMP.SUPPLY_TYPE IN (SELECT cnvalue FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CKEY = 1)
	  AND EXISTS(SELECT CODE FROM dbo.T_IMP_BI_MAIN_CUSTOMER_SYNC WHERE UUID=@uuid  AND errorCheck = 0 AND SOLDTO_ID = IMP.CODE  );


-----------6.间供客户必须设置直供客户编码
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[ERROR:间供客户必须设置直供客户编码.]'+CHAR(10)
--SELECT * 
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC imp 
WHERE imp.errorCheck = 1 AND imp.UUID = @uuid 
AND supply_type IN (SELECT cnvalue FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CKEY = 1) AND 
(imp.SOLDTO_ID IS NULL   --未设置直供客户编码
	--设置的客户编码不是直供客户
	OR 
	(
		NOT EXISTS(SELECT code FROM t_bi_customer WHERE code = imp.SOLDTO_ID AND  supply_type = 0)
		AND
		NOT EXISTS(SELECT code FROM T_IMP_BI_MAIN_CUSTOMER_SYNC WHERE code = imp.SOLDTO_ID AND  supply_type  IN (SELECT cnvalue FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CKEY = 0) AND UUID = @uuid AND errorCheck = 1 )
	)
);

-----------7直供的客户  sold_to是本身
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[ERROR:直供的客户 sold_to是本身.]'+CHAR(10)
--SELECT * 
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC IMP
WHERE IMP.UUID=@uuid  AND IMP.errorCheck = 0 
	  AND IMP.SUPPLY_TYPE IN (SELECT cnvalue FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CKEY = 0)
	  AND IMP.SOLDTO_ID <> IMP.CODE;


---------------------------------------------------
--客户 - 区域关系  必须同时有效 即两者的检查全部通过
---------------------------------------------------
UPDATE hrcTmp SET hrcTmp.VALID = cusTmp.errorCheck , hrcTmp.ERROR_MSG = (ISNULL(hrcTmp.ERROR_MSG,'') + '[ERROR:<对应的客户主数据有错误!>]'+CHAR(10))
FROM
T_IMP_BI_MAIN_CUSTOMER_SYNC cusTmp
LEFT JOIN T_IMP_BI_MAIN_HRC_SALEGEO_SYNC hrcTmp ON cusTmp.code = hrcTmp.cus_code AND cusTmp.uuid = hrcTmp.UUID
WHERE cusTmp.UUID = @uuid AND cusTmp.errorCheck = 0 and hrcTmp.VALID = 1  ;



IF @ischeckValid = 2 BEGIN
	SET @ischeckValid = 1;
	SET @ErrorMsg = '核对客户业务逻辑时失败,临时表为:T_IMP_BI_MAIN_HRC_SALEGEO_SYNC,对应UUID为:'+@uuid;
END



COMMIT TRAN
END TRY

BEGIN CATCH
	ROLLBACK TRAN
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		   END_DATE = GETDATE(),PROC_NAME = ERROR_PROCEDURE(),
		   ERROR_MSG = '校验业务逻辑时发生异常:'+ERROR_MESSAGE()+',校验错误'+@ErrorMsg WHERE id = @Version_Id;
	RETURN -1;
END CATCH

--执行成功后,  判断检验数据时是否有错

UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = @ischeckValid,
       END_DATE = GETDATE(),PROC_NAME = 'SYNC_MAIN_MAINDATA_PLATFORM_CUSTOMER',
	   ERROR_MSG = @ErrorMsg WHERE id = @Version_Id;


BEGIN TRAN
BEGIN TRY
-----------检查是否有需要通知的信息,只会通知校验通过的数据

-----------------------------------------------------
--检测update 的 BU2的信息  是否有所变化
-----------------------------------------------------
UPDATE imp  SET @ischeckValid = 3,imp.INFO_MSG = ISNULL(imp.INFO_MSG,'')+'[INFO:<客户数据中预算控制项可能需要进行变更!{'+
(CASE WHEN bu2.ID IS NULL  THEN '<客户没有配置预算年'+CONVERT(VARCHAR(20),@budget_year)+'的预算控制项>' ELSE '' END )+
(CASE WHEN imp.BU <> cus.BU THEN '<BU:'+cus.BU +'-->'+imp.BU+'>' ELSE '' END )+
(CASE WHEN imp.NKA_NAME <> cus.NKA_NAME THEN '<NKA_NAME:'+cus.NKA_NAME +'-->'+imp.NKA_NAME+'>' ELSE '' end)+
(CASE WHEN cus.SUPPLY_TYPE <> (SELECT CKEY FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CNVALUE = imp.SUPPLY_TYPE) THEN '<SUPPLY_TYPE:'+cus.SUPPLY_TYPE +'-->'+imp.SUPPLY_TYPE+'>' ELSE '' END )+'}>]'
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC imp
INNER JOIN dbo.T_BI_CUSTOMER cus ON  imp.UUID = @uuid AND  imp.CODE = cus.CODE AND imp.errorCheck = 1 AND imp.Operate = 2
LEFT JOIN dbo.T_CUS_ACT_KEY_YEAR_MAPPING bu2 ON cus.ID = bu2.CUS_ID AND bu2.YEAR = @budget_year
WHERE 
(
 --只有bu/nkaName,supplytype发生了变化,才会检测bu2 是否变化  
imp.BU <> cus.BU 
OR imp.NKA_NAME <> cus.NKA_NAME 
OR cus.SUPPLY_TYPE <> (SELECT CKEY FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CNVALUE = imp.SUPPLY_TYPE)
)
AND bu2.ID IS NOT NULL 
	AND ((imp.bu2 IS NULL AND bu2.BU2 IS NOT  NULL) 
			OR (imp.bu2 IS NOT NULL AND bu2.BU2 IS NULL) 
			OR (imp.bu2 IS NOT NULL and bu2.BU2 IS NOT NULL AND  imp.bu2 <> bu2.BU2 )
		)

----------------如果有新的客户插入,那么需要有通知
--UPDATE imp  SET @ischeckValid = 3,imp.errorMsg = ISNULL(imp.errorMsg,'')+'[INFO:<客户数据中预算控制项需要用户进行核对!>]'
--FROM T_IMP_BI_MAIN_CUSTOMER_SYNC imp
--INNER JOIN dbo.T_BI_CUSTOMER cus ON   imp.CODE = cus.CODE 
--WHERE  imp.UUID = @uuid AND  imp.errorCheck = 1 AND imp.Operate = 1;

-------------------------------
--检查客户区域关系mapping  是否有变化
-------------------------------
UPDATE imp  SET @ischeckValid = 3,imp.INFO_MSG = ISNULL(imp.INFO_MSG,'')+ '[INFO:客户区域行政关系需要用户进行核对!{'+
(CASE WHEN mm.ID IS NULL THEN '<客户在预算年'+CONVERT(VARCHAR(20),@budget_year)+'的区域关系没有维护>' ELSE '' END )
+(CASE WHEN imp.REGION <> region.CODE THEN '<REGION:'+region.CODE +'-->'+imp.REGION +'>' ELSE '' END )
+(CASE WHEN imp.DUG <> dug.CODE THEN '<DUG:'+dug.CODE +'-->'+imp.DUG +'>' ELSE '' END )
+(CASE WHEN imp.CITY <> geo.CODE THEN '<CITY:'+geo.CODE +'-->'+imp.CITY +'>' ELSE '' END )
+'}>]' 
FROM dbo.T_IMP_BI_MAIN_HRC_SALEGEO_SYNC imp
INNER JOIN dbo.T_BI_CUSTOMER cus ON imp.UUID = @uuid AND imp.VALID = 1 AND cus.CODE = imp.cus_code
LEFT JOIN dbo.T_HRC_SGEO_CUS_MAPPING mm ON cus.ID = mm.CUS_ID AND mm.BUDGET_YEAR = @budget_year
LEFT JOIN dbo.T_HRC_SALESGEO sh ON mm.SH_ID = sh.ID AND sh.BUDGET_YEAR = @budget_year
LEFT JOIN dbo.T_BI_REGION region ON sh.REGION_ID = region.ID
LEFT JOIN T_BI_DUG dug ON dug.ID = sh.DUG_ID
LEFT JOIN dbo.T_BI_CITY city ON city.ID = sh.CITY_ID 
LEFT JOIN dbo.T_BI_GEO geo ON geo.ID = city.CITY_ID
WHERE mm.ID IS NULL OR imp.DUG <> dug.CODE OR imp.REGION <> region.CODE OR imp.CITY <> geo.CODE 





IF @ischeckValid = 3 BEGIN
	SET @ErrorMsg = '客户预算控制项/区域行政关系有变更,需要通知用户,临时表为:T_IMP_BI_MAIN_HRC_SALEGEO_SYNC,对应UUID为:'+@uuid;
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		END_DATE = GETDATE(),PROC_NAME = '',
		ERROR_MSG = ISNULL(ERROR_MSG,'')+@ErrorMsg WHERE id = @Version_Id;
END

COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		   END_DATE = GETDATE(),PROC_NAME = ERROR_PROCEDURE(),
		   ERROR_MSG = '获取通知信息时发生异常:'+ERROR_MESSAGE()+',校验错误'+@ErrorMsg WHERE id = @Version_Id;
	RETURN -1;;

END CATCH


--------------------------------------------------
--==  以下部分  即使执行失败  sync 数据依然照常运行
--------------------------------------------------


---------------------------------------------------
--记录错误日志
---------------------------------------------------
BEGIN TRAN
BEGIN TRY 
--插入错误详细的日志
--INSERT INTO T_MD_SYNC_ERROR_DETAIL_LOG(send_mail_id,cus_code,error_msg,table_name,content_desc)
--SELECT VERSION_ID,CODE,errorMsg,'T_IMP_BI_MAIN_CUSTOMER_SYNC','BI客户主数据'
--FROM dbo.T_IMP_BI_MAIN_CUSTOMER_SYNC
--WHERE UUID = @uuid AND errorCheck = 0 AND errorMsg IS NOT NULL;  

--INSERT INTO T_MD_SYNC_ERROR_DETAIL_LOG(send_mail_id,cus_code,error_msg,table_name,content_desc)
--SELECT VERSION_ID,cus_code,ERROR_MSG,'T_IMP_BI_MAIN_CUSTOMER_SYNC','BI客户区域关系数据'
--FROM dbo.T_IMP_BI_MAIN_HRC_SALEGEO_SYNC
--WHERE UUID = @uuid AND VALID = 0 AND ERROR_MSG IS NOT NULL;  


INSERT INTO T_MD_SYNC_ERROR_DETAIL_LOG
           ([SEND_MAIL_ID],[CUS_CODE],[ERROR_MSG],[TABLE_NAME],[CONTENT_DESC],[INFO_MSG]
           ,[CUS_BU],[CUS_NAKNAME],[CUS_SUPPLYTYPE],[CUS_REGION],[CUS_DUG],[CUS_CITY]
           ,[CUS_OLD_BU2],[CUS_NEW_BU2],CUS_NAME)
SELECT impcus.VERSION_ID,impcus.CODE,ISNULL(impcus.errorMsg,'')+CHAR(10)+ISNULL(imphrc.ERROR_MSG,''),'T_IMP_BI_MAIN_CUSTOMER_SYNC','BI客户&区域关系数据',ISNULL(impcus.INFO_MSG,'')+CHAR(10)+ISNULL(imphrc.INFO_MSG,'')
		,impcus.BU,impcus.NKA_NAME,impcus.SUPPLY_TYPE,imphrc.REGION,imphrc.DUG,imphrc.CITY,bu2.BU2,impcus.BU2,impcus.NAME
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC impcus
INNER JOIN T_IMP_BI_MAIN_HRC_SALEGEO_SYNC imphrc ON  impcus.UUID = @uuid AND imphrc.UUID = impcus.UUID AND imphrc.cus_code = impcus.CODE
LEFT JOIN dbo.T_BI_CUSTOMER cus ON  impcus.UUID = @uuid AND  impcus.CODE = cus.CODE 
LEFT JOIN dbo.T_CUS_ACT_KEY_YEAR_MAPPING bu2 ON cus.ID = bu2.CUS_ID AND bu2.YEAR = @budget_year
WHERE (impcus.errorMsg IS NOT NULL AND impcus.errorMsg <> '' ) OR  (impcus.INFO_MSG IS NOT NULL AND impcus.INFO_MSG <> '' )
 OR (imphrc.ERROR_MSG IS NOT NULL AND imphrc.ERROR_MSG <> '') OR (imphrc.INFO_MSG IS NOT NULL AND imphrc.INFO_MSG <> '') ;  


COMMIT TRAN

END TRY

BEGIN CATCH
	ROLLBACK TRAN
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		   END_DATE = GETDATE(),PROC_NAME = ERROR_PROCEDURE(),
		   ERROR_MSG = ISNULL(ERROR_MSG,'') +'[<存储过程运行异常,记录错误日志失败:'+ERROR_MESSAGE()+',[ERROR:<'+@ErrorMsg+'>]' WHERE id = @Version_Id;
	RETURN @Version_Id;
	
END CATCH


BEGIN TRAN

BEGIN TRY

-----------------------------------------------------
--删除一个星期前的缓存数据
-----------------------------------------------------
DELETE  
FROM  T_IMP_BI_MAIN_CUSTOMER_SYNC 
WHERE version_id IN (
	SELECT ID FROM T_MD_SYNC_SENDEMAIL_HISTORY 
	WHERE version_type = 2 AND  begin_Date < DATEADD(DAY,-7,GETDATE()) 
);

DELETE  
FROM T_IMP_BI_MAIN_HRC_SALEGEO_SYNC 
WHERE version_id IN (
	SELECT ID FROM T_MD_SYNC_SENDEMAIL_HISTORY 
	WHERE version_type = 2 AND  begin_Date < DATEADD(DAY,-7,GETDATE()) 
);

DELETE  
FROM T_IMP_BI_MAIN_CUSTOMER_UCODE 
WHERE version_id IN (
	SELECT ID FROM T_MD_SYNC_SENDEMAIL_HISTORY 
	WHERE version_type = 2 AND  begin_Date < DATEADD(DAY,-7,GETDATE()) 
);


COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		   END_DATE = GETDATE(),PROC_NAME = ERROR_PROCEDURE(),
		   ERROR_MSG = ISNULL(ERROR_MSG,'') +'[<存储过程运行异常,删除临时数据时失败:'+ERROR_MESSAGE()+',[ERROR:<'+@ErrorMsg+'>]' WHERE id = @Version_Id;
	RETURN @Version_Id;
END  CATCH

RETURN @Version_Id;

END;





GO


