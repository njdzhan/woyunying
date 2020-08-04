select d.demand_id,d.demandnum,d.create_date,d.title_ ,d.usernick  提单人,d.userprovince 提单省分,
       (select t.TFS_DEMAND_ID from unicom_oop.tfs_demand_type_view t where t.demand_id = d.DEMAND_ID -- 转发tfs的记录         
       ) tfs编号,  
a.start_date 转发新架构团队时间,a.systype1_name,a.systype2_name,a.systype3_name,
b.systype1_name 运维专业1,b.systype2_name 运维专业2,b.systype3_name 运维专业3,
b.start_date 转运维时间,b.user_nick 运维人员,b.content_ 运维处理情况,e.运维处理总时长,
case when c.user_nick is null then '否' else '是' END  是否转研发,
c.start_date 转研发时间,c.user_nick 研发人员,c.content_ 研发处理情况,
ROUND(to_number( nvl(c.end_date,sysdate)-c.start_date)*24,2)  研发处理时长,f.研发处理总时长,  
g.老架构处理总时长,
(case when c.user_nick is null and b.content_ is not null then '已解决' 
when c.user_nick is not null and b.content_ is not null then '已解决' 
else '未解决' END ) 是否已解决
from 
--第一次转cBSS1.0新架构处理工单
(SELECT t1.* from 
(select ROW_NUMBER() OVER(PARTITION BY crd.demand_id ORDER BY crd.id_) rn,
crd.id_,crd.demand_id,crd.start_date,crd.systype1_name,crd.systype2_name,crd.systype3_name
from unicom_oop.CIRCLERELEVANCEDEMAND_VIEW crd
where crd.circle_id='12003' 
and to_char(crd.start_date,'yyyy-mm-dd hh24:mi:ss')>='2020-01-01 00:00:00'
） t1  where t1.rn=1 ) a
left JOIN
--运维侧二组具体处理人员信息  分组后均取最新一条记录  
(select t2.* from 
(select ROW_NUMBER() OVER(PARTITION BY crd.demand_id ORDER BY crd.start_date desc ) rn,
crd.id_,crd.demand_id,crd.start_date,crd.user_name,crd.user_nick,crd.content_,
crd.systype1_name,crd.systype2_name,crd.systype3_name,crd.nature_minute,crd.end_date
from unicom_oop.CIRCLERELEVANCEDEMAND_VIEW crd where crd.circle_id='12003'
) t2  where t2.rn=1
) b on a.demand_id=b.demand_id
left join
--转研发情况 新架构运行响应二组
(select t2.* from 
(select ROW_NUMBER() OVER(PARTITION BY crd.demand_id ORDER BY crd.start_date desc ) rn,
crd.id_,crd.demand_id,crd.start_date,crd.user_name,crd.user_nick,crd.content_,
crd.systype1_name,crd.systype2_name,crd.systype3_name,crd.nature_minute,crd.end_date
from unicom_oop.CIRCLERELEVANCEDEMAND_VIEW crd where crd.circle_id='12004'
) t2  where t2.rn=1
) c on a.demand_id=c.demand_id
left join
--运维侧处理时长汇总
(select t2.demand_id,t2.demandnum,sum(t2.运维处理时长新) 运维处理总时长
from (select crd.id_,crd.demand_id,crd.start_date,crd.user_name,crd.user_nick,crd.content_,
crd.systype1_name,crd.systype2_name,crd.systype3_name,crd.end_date,
crd.nature_minute,crd.work_minute,ROUND(to_number( nvl(crd.end_date,sysdate)-crd.start_date)*24,2) 运维处理时长新,d.demandnum
from unicom_oop.CIRCLERELEVANCEDEMAND_VIEW crd 
join unicom_oop.DEMAND_VIEW d on d.demand_id =crd.demand_id 
where  crd.circle_id='12003' 
and d.create_date > to_date('2020-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND d.create_date < to_date('2020-07-01 00:00:00','yyyy-mm-dd hh24:mi:ss')  
) t2 group by t2.demand_id,t2.demandnum 
) e  on a.demand_id=e.demand_id
left join
--研发侧处理时长汇总
(select t2.demand_id,t2.demandnum,sum(t2.研发处理时长新) 研发处理总时长
from (select crd.id_,crd.demand_id,crd.start_date,crd.user_name,crd.user_nick,crd.content_,
crd.systype1_name,crd.systype2_name,crd.systype3_name,crd.end_date,
crd.nature_minute,crd.work_minute,ROUND(to_number( nvl(crd.end_date,sysdate)-crd.start_date)*24,2) 研发处理时长新,d.demandnum
from unicom_oop.CIRCLERELEVANCEDEMAND_VIEW crd 
join unicom_oop.DEMAND_VIEW d on d.demand_id =crd.demand_id 
where  crd.circle_id='12004' 
and d.create_date > to_date('2020-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND d.create_date < to_date('2020-07-01 00:00:00','yyyy-mm-dd hh24:mi:ss')  
) t2 group by t2.demand_id,t2.demandnum 
) f on a.demand_id=f.demand_id
left join 
--1.0处理情况，是否有流经1.0+处理时长
(select t2.demand_id,t2.demandnum,sum(t2.老架构处理时长新) 老架构处理总时长
from (select crd.id_,crd.demand_id,crd.start_date,crd.user_name,crd.user_nick,crd.content_,
crd.systype1_name,crd.systype2_name,crd.systype3_name,crd.end_date,
crd.nature_minute,crd.work_minute,ROUND(to_number( nvl(crd.end_date,sysdate)-crd.start_date)*24,2) 老架构处理时长新,d.demandnum
from unicom_oop.CIRCLERELEVANCEDEMAND_VIEW crd 
join unicom_oop.DEMAND_VIEW d on d.demand_id =crd.demand_id 
where  crd.circle_id='307' and crd.systype2_ in (280,368) --大B专业
and d.create_date > to_date('2020-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND d.create_date < to_date('2020-07-01 00:00:00','yyyy-mm-dd hh24:mi:ss')  
) t2 group by t2.demand_id,t2.demandnum 
) g  on a.demand_id=g.demand_id
left join unicom_oop.DEMAND_VIEW d on a.demand_id=d.demand_id
where to_char(d.create_date,'yyyy-mm-dd hh24:mi:ss')>='2020-01-01 00:00:00'
AND to_char(d.create_date,'yyyy-mm-dd hh24:mi:ss')<'2020-07-01 00:00:00'
;