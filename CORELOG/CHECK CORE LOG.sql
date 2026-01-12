#1 Check Core Log Detail for DWH Job
select 
   t.log_process,
   t.log_info,
   t.started,
   t.finished,
   ceil((FINISHED-STARTED)*24*60) as duration_MINUTES,
   err_msg,
   DML_ROWS   
from AP_PUBLIC.CORE_LOG_detail t 
where LOG_module = upper('&schema')
and work_day = trunc(sysdate-&day)
and upper(LOG_PROCESS) = upper('&logprocess')
and upper(log_info) = upper('&loginfo')
and err_msg is null
and finished is not null
order by log_pk desc;

#2 Check Daily Duration of DWH Job
select 
    trunc(t.started) starttime,
      trunc(sum(ceil((FINISHED-STARTED)*24*60))) as duration_MINUTES
from AP_PUBLIC.CORE_LOG_detail t 
where LOG_module = upper('&schema')
and work_day >= trunc(sysdate-&day)
and upper(LOG_PROCESS) = upper('&logprocess')
and err_msg is null
and finished is not null
group by trunc(t.started)
order by 1 desc;

#3 Check Sum Duration Per Day per Process
with data as (
SELECT work_day, log_id, LOG_PROCESS,log_info , started, finished, trunc((finished-started)*1440,2) as "Duration(mins)" FROM AP_PUBLIC.CORE_LOG_DETAIL A
WHERE A.LOG_MODULE =upper('&module')
AND TRUNC(A.WORK_DAY) > TRUNC(SYSDATE)-60
AND A.LOG_PROCESS = upper('&process') and A.log_info like '%&loginfo%' )--group by A.WORK_DAY , A.LOG_PROCESS
select work_day,LOG_PROCESS, sum("Duration(mins)") totDur from data
group by work_day,LOG_PROCESS
order by work_day desc;
