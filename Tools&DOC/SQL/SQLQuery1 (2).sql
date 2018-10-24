USE [jnjhoco_test_2]
GO

/****** Object:  StoredProcedure [dbo].[SYNC_MAIN_MAINDATA_PLATFORM_CUSTOMER]    Script Date: 04/11/2018 11:55:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER PROCEDURE [dbo].[SYNC_MAIN_MAINDATA_PLATFORM_CUSTOMER]
@returnParam NVARCHAR(50) OUTPUT,
@uuid NVARCHAR(200)  --��Ϊ���θ��µı�ʶ
AS
--��������
DECLARE 
		@ErrorMsg NVARCHAR(500),--��¼������Ϣ
		@versionNum INT,--��¼�汾��
		@ischeckValid INT,--��¼�����Ƿ�������
		@Version_Id NUMERIC(18,0),--��¼�汾ID
		@index INT,--ѭ��������
		@budget_year INT,--Ԥ����
		@len INT,--ѭ��������λ��
		@version_type INT;--����־�м�¼������,�ͻ�������ͬ��type Ϊ2 
--���ó�ʼֵ						
 SET @ischeckValid = 0;--0��ʾcheckû������
 SET @ErrorMsg = '';
 SET @index=0;
 SET @version_type = 2;
 SET @budget_year = YEAR(GETDATE());
 
 SELECT @versionNum = ISNULL((SELECT MAX(VERSION_NUM) 
 FROM T_MD_SYNC_SENDEMAIL_HISTORY WHERE VERSION_TYPE = @version_type),0)+1;
  

BEGIN 

---------------------------------------------------------
--�ȼ�¼�汾��ʷ д����־
---------------------------------------------------------
INSERT INTO T_MD_SYNC_SENDEMAIL_HISTORY(VERSION_NUM,BEGIN_DATE,VERSION_TYPE,IS_NEED_EMAIL_FLAG) 
VALUES(@versionNum,GETDATE(),@version_type,0) SELECT @Version_Id = IDENT_CURRENT('T_MD_SYNC_SENDEMAIL_HISTORY');


-----------------------------------------------------
--ͬ��BI ƽ̨��ChooseOption 
-----------------------------------------------------

--INSERT INTO dbo.T_BI_CHOOSE_OPTION( CKEY ,PACKAGE_NAME ,CODE ,NAME ,IS_AVAILABLE , SORT_NO , CNVALUE ,ENVALUE )
--SELECT SORT_NO,'DEFAULT',OPTION_CODE,OPTION_NAME,1,SORT_NO,TP_Value,BI_Value FROM V_BI_CHOOSE_OPTION_SYNC

--Account
--SELECT *  FROM [LNK_DF].[JJCC_Staging_Test].[dbo].[View_BI_choose_option_to_TP] tmp 
--LEFT JOIN dbo.T_BI_CUSTOMER_ACCOUNT account  ON tmp.BI_Value = account. CODE
--WHERE tmp.code = 'AccountGroupID' AND tmp.BI_Value IS NOT NULL AND  tmp.BI_Value <> '' AND account.ID IS NULL


-------------------------------------------------
--��try catch��  ��׽���� ��ʱ�� ����ʱ���쳣
--��һ��.�������ݵ���ʱ����
-------------------------------------------------
---------------------------------------------------------
--����ͻ����ݵ���ʱ��
---------------------------------------------------------
----------------��Ҫ����Update �Ŀͻ�����
SELECT @len =(SELECT COUNT(1) FROM [LNK_DF].[JJCC_Staging_Test].[dbo].[View_Store_Master_TO_TP] cus_VIEW 
					--LEFT  JOIN t_bi_customer cus ON cus_VIEW.CODE = cus.CODE 
					WHERE EXISTS(SELECT CODE FROM T_BI_CUSTOMER WHERE  cus_VIEW.CODE = CODE  AND (SYNC_DATE IS NULL OR cus_VIEW.SYNC_DATE <> SYNC_DATE  )));
WHILE  @index <@len
BEGIN   --����ѭ��
BEGIN TRAN  -- ��������
BEGIN TRY   --����try catch
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
		,CASE WHEN [EMAIL] = '��ά��' THEN NULL ELSE [EMAIL] END,@uuid,@Version_Id,1,2,
		case
		when TMP.BU='KA' AND TMP.NKA_NAME in(select KA_NAME from T_CUS_ACCOUNT_LIST  where YEAR = @budget_year ����Year
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
			--����ͬ��ʱ�����ж�
			WHERE EXISTS(SELECT CODE FROM T_BI_CUSTOMER WHERE  cus_VIEW.CODE = CODE  AND (SYNC_DATE IS NULL OR cus_VIEW.SYNC_DATE <> SYNC_DATE  ))
		) TMP
WHERE  tmp.rownum between @index+1 and @index+10000;
SET  @index= @index+10000;
COMMIT  TRAN --�����ύ
END TRY

BEGIN CATCH 
	--��ȡ�쳣��־
	ROLLBACK TRAN
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		   END_DATE = GETDATE(),PROC_NAME = ERROR_PROCEDURE(),
		   ERROR_MSG = '�洢���������쳣,������ʱ������ʧ��:'+ERROR_MESSAGE() WHERE id = @Version_Id;
	RETURN -1;
END CATCH
END  ;

---------------------------��Ҫ����Insert �Ŀͻ�����
SET  @index= 0;
SELECT @len =(SELECT count(1) FROM [LNK_DF].[JJCC_Staging_Test].[dbo].[View_Store_Master_TO_TP]  cus_VIEW
			--LEFT  JOIN t_bi_customer cus ON cus_VIEW.CODE = cus.CODE 
			WHERE cus_VIEW.CODE IS NOT NULL and cus_VIEW.CODE <>'#N/A' and cus_VIEW.CODE <>'0' and cus_VIEW.CODE <> ''  
				   AND NOT EXISTS (SELECT CODE FROM dbo.T_BI_CUSTOMER WHERE cus_VIEW.CODE = CODE));
WHILE  @index <@len
BEGIN   --����ѭ��
BEGIN TRAN  -- ��������
BEGIN TRY   --����try catch
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
		,CASE WHEN [EMAIL] = '��ά��' THEN NULL ELSE [EMAIL] END,@uuid,@Version_Id,1,1,
		case
		when TMP.BU='KA' AND TMP.NKA_NAME in(select KA_NAME from T_CUS_ACCOUNT_LIST  where YEAR = @budget_year --����Year
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
			--����ͬ��ʱ�����ж�
			WHERE cus_VIEW.CODE IS NOT NULL and cus_VIEW.CODE <>'#N/A' and cus_VIEW.CODE <>'0' and cus_VIEW.CODE <> ''  
				   AND NOT EXISTS (SELECT CODE FROM dbo.T_BI_CUSTOMER WHERE cus_VIEW.CODE = CODE)
		) TMP
WHERE  tmp.rownum between @index+1 and @index+10000;
SET  @index= @index+10000;
COMMIT  TRAN --�����ύ
END TRY

BEGIN CATCH 
	--��ȡ�쳣��־
	ROLLBACK TRAN
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		   END_DATE = GETDATE(),PROC_NAME = ERROR_PROCEDURE(),
		   ERROR_MSG = '�洢���������쳣,������ʱ������ʧ��:'+ERROR_MESSAGE() WHERE id = @Version_Id;
	RETURN -1;
END CATCH
END  ;

SET  @index= 0;

BEGIN TRAN
BEGIN TRY


------------------------------------------------------
--���������ϵ ����ʱ��
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
--����ͬ��ʱ�����ж�
WHERE   CODE IN (SELECT CODE  FROM T_IMP_BI_MAIN_CUSTOMER_SYNC WHERE UUID = @uuid);


---------------------------------------
--����Ucode
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
	--��ȡ�쳣��־
	ROLLBACK TRAN
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		   END_DATE = GETDATE(),PROC_NAME = ERROR_PROCEDURE(),
		   ERROR_MSG = '�洢���������쳣,������ʱ������ʧ��:'+ERROR_MESSAGE() WHERE id = @Version_Id;
	RETURN -1;
END CATCH

-------------------------�ύ������
BEGIN TRAN
BEGIN TRY

--------------------------------------------
--�ڶ��� У������
--�ͻ����ݼ��
--���������ϵ����,����Ƿ��������Ŀͻ������ϵ
--------------------------------------------

---------------------У���ظ�code ������
UPDATE 
tmp
SET tmp.errorCheck = 0,@ischeckValid = 1,tmp.errorMsg = (ISNULL(tmp.errorMsg,'')+'[ERROR:<�ͻ���Ϣ�����ظ���code.>]'+CHAR(10))
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


-----------------2.1 У���д���Ŀͻ�����-------------------------------------------------
---------2.1.1  ȥ���ͻ��е� �ǿ���  Ϊnullֵ��
update t set t.errorCheck = 0,@ischeckValid = 1,t.errorMsg = (ISNULL(t.errorMsg,'')+'[ERROR:<�ͻ���Ϣ�в�Ϊnull������nullֵ.>]'+CHAR(10))
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

--------2.1.2 У��Sap��ؿͻ��Ƿ���ϵͳ�д���
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<Sap_Customer_id��SapCustomer��û���ҵ���Ӧ�Ŀͻ�!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp 
LEFT  JOIN  t_sap_customer cus on tmp.SAP_CUSTOMER_ID = cus.CODE and  cus.COCD = '7046'
WHERE tmp.UUID = @uuid AND SRC = 1 and cus.ID IS  NULL ;

--------2.1.3  У��cusChannel ��Ϣ
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<�ͻ�����(cus_channel_id)��ϵͳ��û���ҵ���Ӧ��������Ϣ!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
left join t_bi_customer_channel channel on  tmp.cus_channel_id = channel.code
WHERE tmp.UUID = @uuid AND tmp.CUS_CHANNEL_ID IS NOT NULL AND tmp.CUS_CHANNEL_ID <> '' AND channel.ID IS  NULL ;
 
----------2.1.4 ���� AcountGroup��Ϣ   accountGroup �ĳ���Account����
--update tmp 
--set  tmp.errorCheck = 0,@ischeckValid = 1,
--     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<�ͻ�Account��(cus_account_group_id)��ϵͳ��û���ҵ���Ӧ��AccountGroup��Ϣ!>]' )
--from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
--left join t_bi_customer_account_group accountgroup on  tmp.cus_account_group_id = accountgroup.code
--WHERE tmp.UUID = @uuid AND tmp.CUS_ACCOUNT_GROUP_ID IS NOT NULL AND tmp.CUS_ACCOUNT_GROUP_ID <> '' AND  accountgroup.ID IS  NULL ;

--------2.1.4 ���� Account��Ϣ
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<�ͻ�Account(cus_account_id)��ϵͳ��û���ҵ���Ӧ��Account��Ϣ!>]' +CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
left join t_bi_customer_account account on  tmp.CUS_ACCOUNT_ID = account.CODE
WHERE tmp.UUID = @uuid AND tmp.CUS_ACCOUNT_ID IS NOT NULL AND tmp.CUS_ACCOUNT_ID <> '' AND  account.ID IS NULL ;

--------2.1.5  У��ͻ���������Ϣ
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<�ͻ�������(repsales_id)��Ϣ�����ڻ�����ϵͳ��û���ҵ���Ӧ���û�!>]'+CHAR(10) )
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.SYSUSER  u ON  tmp.repsales_id = u.USERNAME
left join t_bi_user repsales ON  repsales.SYSUSERID = u.ID
WHERE tmp.UUID = @uuid AND repsales.ID IS  NULL ;

--------2.1.6   ��� sap soldTo Code
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<Sap Soldto(invoice_code)��Ϣ�����ڻ�����ϵͳ��û���ҵ���Ӧ��SapCustomer!>]'+CHAR(10) )
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp 
LEFT JOIN T_SAP_CUSTOMER CUS ON tmp.invoice_code = cus.code AND CUS.COCD = '7046'
LEFT JOIN  T_SAP_CUSTOMER_FUCTION FUNCT on FUNCT.CUSTOMER = CUS.ID AND FUNCT.FUNCT = 'AG'
WHERE tmp.UUID = @uuid AND (CUS.ID is NULL OR  FUNCT.ID IS NULL);


--------2.1.7  ����������� EXT_BRR_MGR ��Ϣ 
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<��������(EXT_BRR_MGR)��ϵͳ��û���ҵ���Ӧ���û�!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.SYSUSER U_BRR ON U_BRR.USERNAME = tmp.EXT_BRR_MGR  
left join t_bi_User BRR on BRR.SYSUSERID = U_BRR.ID
WHERE tmp.UUID = @uuid AND tmp.EXT_BRR_MGR IS NOT NULL AND tmp.EXT_BRR_MGR <> '' AND BRR.ID IS  NULL ;

---------2.1.8   ���Э������Ϣ 
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<Э����(EXT_XTR)��ϵͳ��û���ҵ���Ӧ���û�!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.SYSUSER U_XTR ON U_XTR.USERNAME = tmp.EXT_XTR 
left join t_bi_User XTR ON XTR.SYSUSERID = U_XTR.ID
WHERE tmp.UUID = @uuid AND tmp.EXT_XTR IS NOT NULL AND tmp.EXT_XTR <> '' AND XTR.ID IS  NULL ;

---------2.1.9 ���ASM/AKM 
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<AKM/ASM(EXT_ASM_AKM)��ϵͳ��û���ҵ���Ӧ���û�!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.SYSUSER U_ASM ON U_ASM.USERNAME = tmp.EXT_ASM_AKM
left join t_bi_User ASM on ASM.SYSUSERID = U_ASM.ID
WHERE tmp.UUID = @uuid AND tmp.EXT_ASM_AKM IS NOT NULL AND tmp.EXT_ASM_AKM <> '' AND ASM.ID IS  NULL ;

--------2.1.10  ���RSM
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<RSM(EXT_RSM)��ϵͳ��û���ҵ���Ӧ���û�!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.SYSUSER U_RSM ON U_RSM.USERNAME = tmp.EXT_RSM
left join t_bi_User RSM on RSM.SYSUSERID = U_RSM.ID
WHERE tmp.UUID = @uuid AND tmp.EXT_RSM IS NOT NULL AND tmp.EXT_RSM <> '' AND  RSM.ID IS  NULL ;

-------2.1.11 DESTINATION


-------2.1.12 ������vendor 
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<SapVendor(PAYMENT_VENDOR_ID)��ϵͳ��û���ҵ���Ӧ��Vendor!>]'+CHAR(10))
FROM  T_IMP_BI_MAIN_CUSTOMER_SYNC tmp 
LEFT JOIN t_sap_vendor VENDOR ON TMP.PAYMENT_VENDOR_ID = VENDOR.CODE
WHERE tmp.UUID = @uuid AND tmp.PAYMENT_VENDOR_ID IS NOT NULL AND tmp.PAYMENT_VENDOR_ID <> '' AND VENDOR.ID is null;

-------2.1.13  ���� paylink
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<PayLink(PAYLINK_ID)��ϵͳ��û���ҵ���Ӧ��SapCutomer!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
left join t_sap_customer cus on tmp.PAYLINK_ID = cus.code and cus.cocd = '7046'
WHERE tmp.UUID = @uuid AND tmp.PAYLINK_ID IS NOT NULL AND tmp.PAYLINK_ID <> '' AND cus.ID is null;

-------2.1.14 Ʒ�����÷�Χ����Ϊ��
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<Ʒ�����÷�Χ(BRAND_TYPE)Ϊ��,����chooseOption��û�ж�Ӧ��ֵ!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.T_BI_CHOOSE_OPTION brandOption ON  brandOption.CODE = 'CUS_BRAND_TYPE' AND brandOption.CNVALUE = tmp.BRAND_TYPE 
WHERE tmp.UUID = @uuid  AND brandOption.CKEY IS NULL;

-------2.1.15 email��֤  BUΪ GT ʱ����Ϊ��
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<Email��BUΪGT��ʱ����Ϊ��!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
WHERE tmp.UUID = @uuid AND BU IN ( 'GT','DT') AND (EMAIL IS NULL OR EMAIL = '') ;


-------2.1.16 STORE_TYPE chooseOption����Ϊ��
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<�ŵ�������chooseOption��û�ж�Ӧ��ֵ!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.T_BI_CHOOSE_OPTION brandOption ON  brandOption.CODE = 'STORE_TYPE' AND brandOption.CNVALUE = tmp.STORE_TYPE
WHERE tmp.UUID = @uuid AND brandOption.CKEY IS NULL AND (tmp.STORE_TYPE IS NOT NULL OR tmp.STORE_TYPE <> '');

-------2.1.17 SUPPLY_TYPE chooseOption����Ϊ��
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<��Ӧ������chooseOption��û�ж�Ӧ��ֵ!>]'+CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp
LEFT JOIN dbo.T_BI_CHOOSE_OPTION brandOption ON  brandOption.CODE = 'SUPPLY_TYPE' AND brandOption.CNVALUE = tmp.SUPPLY_TYPE 
WHERE tmp.UUID = @uuid AND brandOption.CKEY IS NULL AND (tmp.SUPPLY_TYPE IS NOT NULL OR tmp.SUPPLY_TYPE <> '');

--------2.1.18  payer_code ������sapcustomer ����  ��payer
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<Sap Soldto(invoice_code)��Ϣ�����ڻ�����ϵͳ��û���ҵ���Ӧ��SapCustomer!>]' +CHAR(10))
from T_IMP_BI_MAIN_CUSTOMER_SYNC tmp 
LEFT JOIN T_SAP_CUSTOMER sapCUS ON tmp.PAYER_CODE = sapCUS.code AND sapCUS.COCD = '7046'
LEFT  JOIN  T_SAP_CUSTOMER_FUCTION FUNCT on FUNCT.CUSTOMER1 = sapCUS.ID AND FUNCT.FUNCT = 'RG'
WHERE tmp.UUID = @uuid AND tmp.PAYER_CODE IS NOT NULL AND tmp.PAYER_CODE <> '' AND (sapCUS.ID is NULL OR  FUNCT.ID IS NULL);

---------------------------------------------------------
--2.2 check �д���Ŀͻ������ϵ,��¼�������з����ʼ�
--1.region,dug,city Ϊnull
--2. region,dug,city �ڵ�ǰ��û�ж���
---------------------------------------------------------
UPDATE tmp SET tmp.VALID = 0,@ischeckValid = 1,tmp.ERROR_MSG = (ISNULL(tmp.ERROR_MSG,'')+
('[ERROR:{Ԥ����Ϊ:'+CONVERT(NVARCHAR(50),tmp.BUDGET_YEAR)+'#'+
(CASE 
	WHEN city.city_id IS NULL
		THEN '[error:city->'+tmp.city+'�ڵ�ǰԤ����û�ж���!]' 
		ELSE '[city:'+city.city_code+']' end)
		+','+
(CASE 
	WHEN region.region_id IS NULL 
		THEN '[error:region->'+tmp.region+'�ڵ�ǰԤ����û�ж���!]' 
		ELSE '[region:'+region.code+']' END )
		+','+
(CASE 
	WHEN dug.ID IS NULL 
	THEN '[error:area->'+tmp.dug+'�ڵ�ǰԤ����û�ж���!]' 
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
--�ͻ� - �����ϵ  ����ͬʱ��Ч �����ߵļ��ȫ��ͨ��
---------------------------------------------------
UPDATE cusTmp SET cusTmp.errorCheck = hrcTmp.VALID,cusTmp.errorMsg = (ISNULL(cusTmp.errorMsg,'') + '[ERROR:<�ͻ���Ӧ�����ϵ�д���!>]'+CHAR(10))
FROM
T_IMP_BI_MAIN_CUSTOMER_SYNC cusTmp
LEFT JOIN T_IMP_BI_MAIN_HRC_SALEGEO_SYNC hrcTmp ON cusTmp.code = hrcTmp.cus_code AND hrcTmp.UUID = cusTmp.UUID
WHERE cusTmp.UUID = @uuid AND cusTmp.errorCheck = 1 and hrcTmp.VALID = 0;

--UPDATE hrcTmp SET hrcTmp.VALID = cusTmp.errorCheck , hrcTmp.ERROR_MSG = (ISNULL(hrcTmp.ERROR_MSG,'') + '[ERROR:<�ͻ��������д���!')
--FROM
--T_IMP_BI_MAIN_CUSTOMER_SYNC cusTmp
--LEFT JOIN T_IMP_BI_MAIN_HRC_SALEGEO_SYNC hrcTmp ON cusTmp.code = hrcTmp.cus_code AND hrcTmp.UUID = cusTmp.UUID
--WHERE cusTmp.UUID = @uuid AND cusTmp.errorCheck = 0 and hrcTmp.VALID = 1;


--------------------------------------
--��� ����ͻ���sold_to�Ƿ���Ч,ֻ��Լ乩�ͻ�,��Ϊֱ���ͻ���soldto�Ǳ���
--------------------------------------
update tmp 
set  tmp.errorCheck = 0,@ischeckValid = 1,
     tmp.errorMsg = (isnull(tmp.errorMsg,'')+'[ERROR:<ֱ���ͻ�(soldTo_id)�����ڻ�������ϵͳ��û���ҵ���Ӧ��ֱ���ͻ�,�����Ƕ�Ӧ��ֱ���ͻ���Ϣ�д���,�޷�����!>]')+CHAR(10)
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
	SET @ErrorMsg = '�˶Կͻ�����ʱʧ��,��ʱ��Ϊ:T_IMP_BI_MAIN_HRC_SALEGEO_SYNC&&T_IMP_BI_MAIN_CUSTOMER_SYNC,��ӦUUIDΪ:'+@uuid;
END
-----------------�ύУ����
COMMIT TRAN

END TRY

BEGIN CATCH
	ROLLBACK TRAN
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		   END_DATE = GETDATE(),PROC_NAME = ERROR_PROCEDURE(),
		   ERROR_MSG = '�洢���������쳣,У��ͻ�����ʱʧ��:'+ERROR_MESSAGE()+',У�����:'+@ErrorMsg WHERE id = @Version_Id;
	RETURN -1;
END CATCH


--------------------------------------------------
--��ͨ������У�������,����ҵ��У��
--------------------------------------------------
BEGIN TRAN
BEGIN TRY
-----------1.�ͻ��Ǿ�����  ,��ô�ͻ�����Ϊnull ���Ҳ������ֺܲ��ֹܲ���,  ������Ǿ�����  ��ô����Ҫ�пͻ�����
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[Error:�ͻ��Ǿ�����,��ô�ͻ�����Ϊnull ���Ҳ������ֺܲ��ֹܲ���;������Ǿ�����,��ô����Ҫ�пͻ�����.]'+CHAR(10)
FROM dbo.T_IMP_BI_MAIN_CUSTOMER_SYNC imp
WHERE imp.errorCheck = 1 AND imp.UUID = @uuid
AND (
		(imp.IS_DISTRIBUTOR = 1 AND (imp.CUS_CHANNEL_ID IS NOT NULL OR imp.IS_ZC = 1 OR imp.IS_ZC_SUPPLY = 1 ))
		OR
        ((imp.IS_DISTRIBUTOR = 0 OR imp.IS_DISTRIBUTOR IS NULL ) AND imp.CUS_CHANNEL_ID IS NULL)
	);


-----------2.�ֺܲ��ֹܲ��� ��У��  һ���ͻ�����ͬʱΪ�ֺܲ��ֹܲ���
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[ERROR:һ���ͻ�����ͬʱΪ�ֺܲ��ֹܲ���.]'+CHAR(10)
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC imp
WHERE imp.errorCheck = 1 AND imp.UUID = @uuid
AND imp.is_zc = 1 AND imp.is_zc_supply =1;


------------3.�ͻ�������ܲ�,��ô������sap��ز�����ֱ��
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[ERROR:�ͻ�������ܲ�,��ô������sap��ز�����ֱ��.]'+CHAR(10)
--SELECT * 
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC imp 
WHERE imp.errorCheck = 1 AND imp.UUID = @uuid 
AND is_zc = 1 AND ( src <> 1 OR supply_type IN(SELECT cnvalue FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CKEY = 1));

-----------4.�ֹܲ���,��ôsap sold_to �������ܲ�
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[ERROR:�ֹܲ���,��ô invoice_code(sap sold_to)��Ӧ��customer������ڲ������ܲ�.]'+CHAR(10)
--SELECT * 
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC imp
WHERE imp.errorCheck = 1 AND imp.UUID = @uuid 
AND is_zc_supply = 1 
AND NOT EXISTS(SELECT code FROM t_bi_customer WHERE code = imp.invoice_code AND is_zc = 1  )
AND NOT EXISTS(SELECT code FROM T_IMP_BI_MAIN_CUSTOMER_SYNC WHERE code = imp.invoice_code AND is_zc = 1 AND UUID = @uuid AND errorCheck = 1 );



-----------5 �乩�Ŀͻ� ���±���û�� �ͻ���ֱ������ 
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[ERROR:�乩�ͻ�����û�пͻ���ֱ������.]'+CHAR(10)
--SELECT * 
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC IMP
WHERE IMP.UUID=@uuid  AND IMP.errorCheck = 0 
      AND IMP.SUPPLY_TYPE IN (SELECT cnvalue FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CKEY = 1)
	  AND EXISTS(SELECT CODE FROM dbo.T_IMP_BI_MAIN_CUSTOMER_SYNC WHERE UUID=@uuid  AND errorCheck = 0 AND SOLDTO_ID = IMP.CODE  );


-----------6.�乩�ͻ���������ֱ���ͻ�����
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[ERROR:�乩�ͻ���������ֱ���ͻ�����.]'+CHAR(10)
--SELECT * 
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC imp 
WHERE imp.errorCheck = 1 AND imp.UUID = @uuid 
AND supply_type IN (SELECT cnvalue FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CKEY = 1) AND 
(imp.SOLDTO_ID IS NULL   --δ����ֱ���ͻ�����
	--���õĿͻ����벻��ֱ���ͻ�
	OR 
	(
		NOT EXISTS(SELECT code FROM t_bi_customer WHERE code = imp.SOLDTO_ID AND  supply_type = 0)
		AND
		NOT EXISTS(SELECT code FROM T_IMP_BI_MAIN_CUSTOMER_SYNC WHERE code = imp.SOLDTO_ID AND  supply_type  IN (SELECT cnvalue FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CKEY = 0) AND UUID = @uuid AND errorCheck = 1 )
	)
);

-----------7ֱ���Ŀͻ�  sold_to�Ǳ���
UPDATE imp SET @ischeckValid = 2,imp.errorCheck = 0,imp.errorMsg = ISNULL(imp.errorMsg,'') + '[ERROR:ֱ���Ŀͻ� sold_to�Ǳ���.]'+CHAR(10)
--SELECT * 
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC IMP
WHERE IMP.UUID=@uuid  AND IMP.errorCheck = 0 
	  AND IMP.SUPPLY_TYPE IN (SELECT cnvalue FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CKEY = 0)
	  AND IMP.SOLDTO_ID <> IMP.CODE;


---------------------------------------------------
--�ͻ� - �����ϵ  ����ͬʱ��Ч �����ߵļ��ȫ��ͨ��
---------------------------------------------------
UPDATE hrcTmp SET hrcTmp.VALID = cusTmp.errorCheck , hrcTmp.ERROR_MSG = (ISNULL(hrcTmp.ERROR_MSG,'') + '[ERROR:<��Ӧ�Ŀͻ��������д���!>]'+CHAR(10))
FROM
T_IMP_BI_MAIN_CUSTOMER_SYNC cusTmp
LEFT JOIN T_IMP_BI_MAIN_HRC_SALEGEO_SYNC hrcTmp ON cusTmp.code = hrcTmp.cus_code AND cusTmp.uuid = hrcTmp.UUID
WHERE cusTmp.UUID = @uuid AND cusTmp.errorCheck = 0 and hrcTmp.VALID = 1  ;



IF @ischeckValid = 2 BEGIN
	SET @ischeckValid = 1;
	SET @ErrorMsg = '�˶Կͻ�ҵ���߼�ʱʧ��,��ʱ��Ϊ:T_IMP_BI_MAIN_HRC_SALEGEO_SYNC,��ӦUUIDΪ:'+@uuid;
END



COMMIT TRAN
END TRY

BEGIN CATCH
	ROLLBACK TRAN
	UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = 1,
		   END_DATE = GETDATE(),PROC_NAME = ERROR_PROCEDURE(),
		   ERROR_MSG = 'У��ҵ���߼�ʱ�����쳣:'+ERROR_MESSAGE()+',У�����'+@ErrorMsg WHERE id = @Version_Id;
	RETURN -1;
END CATCH

--ִ�гɹ���,  �жϼ�������ʱ�Ƿ��д�

UPDATE T_MD_SYNC_SENDEMAIL_HISTORY SET IS_NEED_EMAIL_FLAG = @ischeckValid,
       END_DATE = GETDATE(),PROC_NAME = 'SYNC_MAIN_MAINDATA_PLATFORM_CUSTOMER',
	   ERROR_MSG = @ErrorMsg WHERE id = @Version_Id;


BEGIN TRAN
BEGIN TRY
-----------����Ƿ�����Ҫ֪ͨ����Ϣ,ֻ��֪ͨУ��ͨ��������

-----------------------------------------------------
--���update �� BU2����Ϣ  �Ƿ������仯
-----------------------------------------------------
UPDATE imp  SET @ischeckValid = 3,imp.INFO_MSG = ISNULL(imp.INFO_MSG,'')+'[INFO:<�ͻ�������Ԥ������������Ҫ���б��!{'+
(CASE WHEN bu2.ID IS NULL  THEN '<�ͻ�û������Ԥ����'+CONVERT(VARCHAR(20),@budget_year)+'��Ԥ�������>' ELSE '' END )+
(CASE WHEN imp.BU <> cus.BU THEN '<BU:'+cus.BU +'-->'+imp.BU+'>' ELSE '' END )+
(CASE WHEN imp.NKA_NAME <> cus.NKA_NAME THEN '<NKA_NAME:'+cus.NKA_NAME +'-->'+imp.NKA_NAME+'>' ELSE '' end)+
(CASE WHEN cus.SUPPLY_TYPE <> (SELECT CKEY FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CNVALUE = imp.SUPPLY_TYPE) THEN '<SUPPLY_TYPE:'+cus.SUPPLY_TYPE +'-->'+imp.SUPPLY_TYPE+'>' ELSE '' END )+'}>]'
FROM T_IMP_BI_MAIN_CUSTOMER_SYNC imp
INNER JOIN dbo.T_BI_CUSTOMER cus ON  imp.UUID = @uuid AND  imp.CODE = cus.CODE AND imp.errorCheck = 1 AND imp.Operate = 2
LEFT JOIN dbo.T_CUS_ACT_KEY_YEAR_MAPPING bu2 ON cus.ID = bu2.CUS_ID AND bu2.YEAR = @budget_year
WHERE 
(
 --ֻ��bu/nkaName,supplytype�����˱仯,�Ż���bu2 �Ƿ�仯  
imp.BU <> cus.BU 
OR imp.NKA_NAME <> cus.NKA_NAME 
OR cus.SUPPLY_TYPE <> (SELECT CKEY FROM dbo.T_BI_CHOOSE_OPTION WHERE code = 'SUPPLY_TYPE' AND CNVALUE = imp.SUPPLY_TYPE)
)
AND bu2.ID IS NOT NULL 
	AND ((imp.bu2 IS NULL AND bu2.BU2 IS NOT  NULL) 
			OR (imp.bu2 IS NOT NULL AND bu2.BU2 IS NULL) 
			OR (imp.bu2 IS NOT NULL and bu2.BU2 IS NOT NULL AND  imp.bu2 <> bu2.BU2 )
		)

----------------������µĿͻ�����,��ô��Ҫ��֪ͨ
--UPDATE imp  SET @ischeckValid = 3,imp.errorMsg = ISNULL(imp.errorMsg,'')+'[INFO:<�ͻ�������Ԥ���������Ҫ�û����к˶�!>]'
--FROM T_IMP_BI_MAIN_CUSTOMER_SYNC imp
--INNER JOIN dbo.T_BI_CUSTOMER cus ON   imp.CODE = cus.CODE 
--WHERE  imp.UUID = @uuid AND  imp.errorCheck = 1 AND imp.Operate = 1;

-------------------------------
--���ͻ������ϵmapping  �Ƿ��б仯
-------------------------------
UPDATE imp  SET @ischeckValid = 3,imp.INFO_MSG = ISNULL(imp.INFO_MSG,'')+ '[INFO:�ͻ�����������ϵ��Ҫ�û����к˶�!{'+
(CASE WHEN mm.ID IS NULL THEN '<�ͻ���Ԥ����'+CONVERT(VARCHAR(20),@budget_year)+'�������ϵû��ά��>' ELSE '' END )
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
	SET @ErrorMsg = '�ͻ�Ԥ�������/����������ϵ�б��,��Ҫ֪ͨ�û�,��ʱ��Ϊ:T_IMP_BI_MAIN_HRC_SALEGEO_SYNC,��ӦUUIDΪ:'+@uuid;
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
		   ERROR_MSG = '��ȡ֪ͨ��Ϣʱ�����쳣:'+ERROR_MESSAGE()+',У�����'+@ErrorMsg WHERE id = @Version_Id;
	RETURN -1;;

END CATCH


--------------------------------------------------
--==  ���²���  ��ʹִ��ʧ��  sync ������Ȼ�ճ�����
--------------------------------------------------


---------------------------------------------------
--��¼������־
---------------------------------------------------
BEGIN TRAN
BEGIN TRY 
--���������ϸ����־
--INSERT INTO T_MD_SYNC_ERROR_DETAIL_LOG(send_mail_id,cus_code,error_msg,table_name,content_desc)
--SELECT VERSION_ID,CODE,errorMsg,'T_IMP_BI_MAIN_CUSTOMER_SYNC','BI�ͻ�������'
--FROM dbo.T_IMP_BI_MAIN_CUSTOMER_SYNC
--WHERE UUID = @uuid AND errorCheck = 0 AND errorMsg IS NOT NULL;  

--INSERT INTO T_MD_SYNC_ERROR_DETAIL_LOG(send_mail_id,cus_code,error_msg,table_name,content_desc)
--SELECT VERSION_ID,cus_code,ERROR_MSG,'T_IMP_BI_MAIN_CUSTOMER_SYNC','BI�ͻ������ϵ����'
--FROM dbo.T_IMP_BI_MAIN_HRC_SALEGEO_SYNC
--WHERE UUID = @uuid AND VALID = 0 AND ERROR_MSG IS NOT NULL;  


INSERT INTO T_MD_SYNC_ERROR_DETAIL_LOG
           ([SEND_MAIL_ID],[CUS_CODE],[ERROR_MSG],[TABLE_NAME],[CONTENT_DESC],[INFO_MSG]
           ,[CUS_BU],[CUS_NAKNAME],[CUS_SUPPLYTYPE],[CUS_REGION],[CUS_DUG],[CUS_CITY]
           ,[CUS_OLD_BU2],[CUS_NEW_BU2],CUS_NAME)
SELECT impcus.VERSION_ID,impcus.CODE,ISNULL(impcus.errorMsg,'')+CHAR(10)+ISNULL(imphrc.ERROR_MSG,''),'T_IMP_BI_MAIN_CUSTOMER_SYNC','BI�ͻ�&�����ϵ����',ISNULL(impcus.INFO_MSG,'')+CHAR(10)+ISNULL(imphrc.INFO_MSG,'')
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
		   ERROR_MSG = ISNULL(ERROR_MSG,'') +'[<�洢���������쳣,��¼������־ʧ��:'+ERROR_MESSAGE()+',[ERROR:<'+@ErrorMsg+'>]' WHERE id = @Version_Id;
	RETURN @Version_Id;
	
END CATCH


BEGIN TRAN

BEGIN TRY

-----------------------------------------------------
--ɾ��һ������ǰ�Ļ�������
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
		   ERROR_MSG = ISNULL(ERROR_MSG,'') +'[<�洢���������쳣,ɾ����ʱ����ʱʧ��:'+ERROR_MESSAGE()+',[ERROR:<'+@ErrorMsg+'>]' WHERE id = @Version_Id;
	RETURN @Version_Id;
END  CATCH

RETURN @Version_Id;

END;





GO


