select d.demand_id,d.demandnum,d.create_date,d.title_ ,d.usernick  �ᵥ��,d.userprovince �ᵥʡ��,
       (select t.TFS_DEMAND_ID from unicom_oop.tfs_demand_type_view t where t.demand_id = d.DEMAND_ID -- ת��tfs�ļ�¼         
       ) tfs���,  
a.start_date ת���¼ܹ��Ŷ�ʱ��,a.systype1_name,a.systype2_name,a.systype3_name,
b.systype1_name ��άרҵ1,b.systype2_name ��άרҵ2,b.systype3_name ��άרҵ3,
b.start_date ת��άʱ��,b.user_nick ��ά��Ա,b.content_ ��ά�������,e.��ά������ʱ��,
case when c.user_nick is null then '��' else '��' END  �Ƿ�ת�з�,
c.start_date ת�з�ʱ��,c.user_nick �з���Ա,c.content_ �з��������,
ROUND(to_number( nvl(c.end_date,sysdate)-c.start_date)*24,2)  �з�����ʱ��,f.�з�������ʱ��,  
g.�ϼܹ�������ʱ��,
(case when c.user_nick is null and b.content_ is not null then '�ѽ��' 
when c.user_nick is not null and b.content_ is not null then '�ѽ��' 
else 'δ���' END ) �Ƿ��ѽ��
from 
--��һ��תcBSS1.0�¼ܹ�������
(SELECT t1.* from 
(select ROW_NUMBER() OVER(PARTITION BY crd.demand_id ORDER BY crd.id_) rn,
crd.id_,crd.demand_id,crd.start_date,crd.systype1_name,crd.systype2_name,crd.systype3_name
from unicom_oop.CIRCLERELEVANCEDEMAND_VIEW crd
where crd.circle_id='12003' 
and to_char(crd.start_date,'yyyy-mm-dd hh24:mi:ss')>='2020-01-01 00:00:00'
�� t1  where t1.rn=1 ) a
left JOIN
--��ά�������崦����Ա��Ϣ  ������ȡ����һ����¼  
(select t2.* from 
(select ROW_NUMBER() OVER(PARTITION BY crd.demand_id ORDER BY crd.start_date desc ) rn,
crd.id_,crd.demand_id,crd.start_date,crd.user_name,crd.user_nick,crd.content_,
crd.systype1_name,crd.systype2_name,crd.systype3_name,crd.nature_minute,crd.end_date
from unicom_oop.CIRCLERELEVANCEDEMAND_VIEW crd where crd.circle_id='12003'
) t2  where t2.rn=1
) b on a.demand_id=b.demand_id
left join
--ת�з���� �¼ܹ�������Ӧ����
(select t2.* from 
(select ROW_NUMBER() OVER(PARTITION BY crd.demand_id ORDER BY crd.start_date desc ) rn,
crd.id_,crd.demand_id,crd.start_date,crd.user_name,crd.user_nick,crd.content_,
crd.systype1_name,crd.systype2_name,crd.systype3_name,crd.nature_minute,crd.end_date
from unicom_oop.CIRCLERELEVANCEDEMAND_VIEW crd where crd.circle_id='12004'
) t2  where t2.rn=1
) c on a.demand_id=c.demand_id
left join
--��ά�ദ��ʱ������
(select t2.demand_id,t2.demandnum,sum(t2.��ά����ʱ����) ��ά������ʱ��
from (select crd.id_,crd.demand_id,crd.start_date,crd.user_name,crd.user_nick,crd.content_,
crd.systype1_name,crd.systype2_name,crd.systype3_name,crd.end_date,
crd.nature_minute,crd.work_minute,ROUND(to_number( nvl(crd.end_date,sysdate)-crd.start_date)*24,2) ��ά����ʱ����,d.demandnum
from unicom_oop.CIRCLERELEVANCEDEMAND_VIEW crd 
join unicom_oop.DEMAND_VIEW d on d.demand_id =crd.demand_id 
where  crd.circle_id='12003' 
and d.create_date > to_date('2020-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND d.create_date < to_date('2020-07-01 00:00:00','yyyy-mm-dd hh24:mi:ss')  
) t2 group by t2.demand_id,t2.demandnum 
) e  on a.demand_id=e.demand_id
left join
--�з��ദ��ʱ������
(select t2.demand_id,t2.demandnum,sum(t2.�з�����ʱ����) �з�������ʱ��
from (select crd.id_,crd.demand_id,crd.start_date,crd.user_name,crd.user_nick,crd.content_,
crd.systype1_name,crd.systype2_name,crd.systype3_name,crd.end_date,
crd.nature_minute,crd.work_minute,ROUND(to_number( nvl(crd.end_date,sysdate)-crd.start_date)*24,2) �з�����ʱ����,d.demandnum
from unicom_oop.CIRCLERELEVANCEDEMAND_VIEW crd 
join unicom_oop.DEMAND_VIEW d on d.demand_id =crd.demand_id 
where  crd.circle_id='12004' 
and d.create_date > to_date('2020-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND d.create_date < to_date('2020-07-01 00:00:00','yyyy-mm-dd hh24:mi:ss')  
) t2 group by t2.demand_id,t2.demandnum 
) f on a.demand_id=f.demand_id
left join 
--1.0����������Ƿ�������1.0+����ʱ��
(select t2.demand_id,t2.demandnum,sum(t2.�ϼܹ�����ʱ����) �ϼܹ�������ʱ��
from (select crd.id_,crd.demand_id,crd.start_date,crd.user_name,crd.user_nick,crd.content_,
crd.systype1_name,crd.systype2_name,crd.systype3_name,crd.end_date,
crd.nature_minute,crd.work_minute,ROUND(to_number( nvl(crd.end_date,sysdate)-crd.start_date)*24,2) �ϼܹ�����ʱ����,d.demandnum
from unicom_oop.CIRCLERELEVANCEDEMAND_VIEW crd 
join unicom_oop.DEMAND_VIEW d on d.demand_id =crd.demand_id 
where  crd.circle_id='307' and crd.systype2_ in (280,368) --��Bרҵ
and d.create_date > to_date('2020-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND d.create_date < to_date('2020-07-01 00:00:00','yyyy-mm-dd hh24:mi:ss')  
) t2 group by t2.demand_id,t2.demandnum 
) g  on a.demand_id=g.demand_id
left join unicom_oop.DEMAND_VIEW d on a.demand_id=d.demand_id
where to_char(d.create_date,'yyyy-mm-dd hh24:mi:ss')>='2020-01-01 00:00:00'
AND to_char(d.create_date,'yyyy-mm-dd hh24:mi:ss')<'2020-07-01 00:00:00'
;