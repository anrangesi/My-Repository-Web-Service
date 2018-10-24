select * from T_BI_CUSTOMER where bu='KA'  -- 客户表

 -- 地区 城市
select * from T_HRC_SGEO_CUS_MAPPING -- 客户行政区域关系
select * from T_HRC_SALESGEO -- 地区一城市-DUG 年度区域行政关系表
select * from T_BI_REGION
select * from T_BI_DUG
select * from T_BI_CITY c left join T_BI_GEO g on c.CITY_ID=g.ID  
select * from T_BI_GEO 
select * from T_CUS_ACT_KEY_YEAR_MAPPING  -- BU2预算控制项
select * from T_CUS_ACCOUNT_LIST 

select * from T_HRC_SGEO_CUS_MAPPING as SCM 
left join T_HRC_SALESGEO as SG on SCM.SH_ID = SG.ID 
left join T_BI_CITY as C on SG.CITY_ID=C.ID
left join T_BI_DUG as D on SG.DUG_ID=D.ID
left join T_BI_REGION as RG on RG.ID=SG.REGION_ID
left join T_BI_GEO as G on G.ID = C.CITY_ID
left join T_BI_CUSTOMER as CT on CT.ID = SCM.CUS_ID
where sg.BUDGET_YEAR=2018





