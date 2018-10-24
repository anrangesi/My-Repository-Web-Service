select * from sysrolefunction where function_id=1290


select * from T_AP_ORDER_LINE_ALLOC

select * from T_BI_SPECIAL_KA_CUS_ACCOUNT
select * from T_SD_CUS_SALES
select * from T_SAP_CUSTOMER_FUCTION where id=105214

select * from T_BI_CUSTOMER

select * from T_AP_ORDER_LINE_ALLOC as TAOLA,T_SD_CUS_SALES as TSCS,T_BI_SPECIAL_KA_CUS_ACCOUNT as TBSKCA
where TAOLA.QTY=TSCS.QTY and  TBSKCA.CREATOR_ID=TSCS.CREATOR_ID


select * from T_BI_RS_SOLD_TO