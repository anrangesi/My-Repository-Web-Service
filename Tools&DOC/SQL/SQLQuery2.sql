select * from T_BI_CUSTOMER where bu='KA'  -- �ͻ���

 -- ���� ����
select * from T_HRC_SGEO_CUS_MAPPING -- �ͻ����������ϵ
select * from T_HRC_SALESGEO -- ����һ����-DUG �������������ϵ��
select * from T_BI_REGION
select * from T_BI_DUG
select * from T_BI_CITY c left join T_BI_GEO g on c.CITY_ID=g.ID  
select * from T_BI_GEO 
select * from T_CUS_ACT_KEY_YEAR_MAPPING  -- BU2Ԥ�������
select * from T_CUS_ACCOUNT_LIST 

select * from T_HRC_SGEO_CUS_MAPPING as SCM 
left join T_HRC_SALESGEO as SG on SCM.SH_ID = SG.ID 
left join T_BI_CITY as C on SG.CITY_ID=C.ID
left join T_BI_DUG as D on SG.DUG_ID=D.ID
left join T_BI_REGION as RG on RG.ID=SG.REGION_ID
left join T_BI_GEO as G on G.ID = C.CITY_ID
left join T_BI_CUSTOMER as CT on CT.ID = SCM.CUS_ID
where sg.BUDGET_YEAR=2018





