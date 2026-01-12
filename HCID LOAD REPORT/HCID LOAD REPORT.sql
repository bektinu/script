#1 Generate SQL load data
select parsing_schema_name as schema , sql_id , plan_hash_value, sum(executions_delta) totalexec, trunc(avg(buffer_gets_delta/decode(executions_delta,0,1,executions_delta))) avggetsperexec , 
trunc(avg(disk_reads_delta/decode(executions_delta,0,1,executions_delta))) avgreadsperexec, trunc(avg(elapsed_time_delta/decode(executions_delta,0,1,executions_delta)/1000000/60)) avgelapsedperexec , 
trunc(avg(physical_read_bytes_delta/decode(executions_delta,0,1,executions_delta))) avgreadsizeperexec , trunc(avg(physical_write_bytes_delta/decode(executions_delta,0,1,executions_delta))) avgwritesizeperexec
from dba_hist_snapshot a , dba_hist_sqlstat b where a.snap_id = b.snap_id and end_interval_time between sysdate-30 and sysdate and (parsing_schema_name like 'APP\_%' escape '\' or parsing_schema_name like 'CS\_%' escape '\')
group by parsing_schema_name , sql_id , plan_hash_value order by 1,2,5 desc;

#2 Generate seg load data
with basedata as (select distinct parsing_schema_name as schema , sql_id,plan_hash_value
from dba_hist_snapshot a , dba_hist_sqlstat b where a.snap_id = b.snap_id and end_interval_time between sysdate-30 and sysdate and (parsing_schema_name like 'APP\_%' escape '\' or parsing_schema_name like 'CS\_%' escape '\')),
busytable as (
select a.sql_id,a.object#, object_owner, object_name, object_type from DBA_HIST_SQL_PLAN a , basedata b where a.sql_id=b.sql_id and a.plan_hash_value=b.plan_hash_value /*and timestamp
between sysdate-30 and sysdate*/
),
uniondata as (
select schema,a.sql_id, object#,object_owner,object_name, object_type from busytable a , basedata b where a.sql_id= b.sql_id
and object_owner is not null),
finaldata as (
select 
schema, sql_id, a.object_owner, a.object_name ,a.object_type , trunc(avg(logical_reads_delta)) avglogical, trunc(avg(physical_reads_delta)) avgphysicalrd , trunc(avg(physical_writes_delta)) avgphysicalwr
from uniondata a, DBA_HIST_SEG_STAT b , dba_hist_snapshot c where b.snap_id=c.snap_id and end_interval_time between sysdate-30 and sysdate and
a.object#=b.obj# group by schema, sql_id, a.object_owner, a.object_name ,a.object_type
)
select * from finaldata where sql_id = '&sqlid' order by 1,2,6 desc;

#3 Generate Segment Stats for past a Month
select owner,object_name, object_type, sum(logical_reads_delta), sum(db_block_changes_delta),  sum(physical_reads_delta), sum(physical_writes_delta), sum(space_used_delta)
from DBA_HIST_SEG_STAT a, dba_hist_snapshot b , dba_objects c where a.snap_id=b.snap_id and end_interval_time between sysdate-30 and sysdate and a.obj#=c.object_id and owner like 'APP_%' escape '\'
group by owner , object_name, object_type order by 6 desc;

#4 DWH Load
set serveroutput on verify off;
declare
schemagets number:=0;
begin
for recowner in (select username from dba_users where 
--username = 'AP_RISK'
username like 'AP%_%' and username not in ('APPDEPLOY','APPQOSSYS') 
order by 1)
      loop
      for recdata in (with 
queryStat as (
select b.SQL_ID, sum(EXECUTIONS_DELTA) execs,
sum(DISK_READS_DELTA)/decode(sum(EXECUTIONS_DELTA),0,1,sum(EXECUTIONS_DELTA)) reads ,
sum(BUFFER_GETS_DELTA)/decode(sum(EXECUTIONS_DELTA),0,1,sum(EXECUTIONS_DELTA)) gets,
sum(ROWS_PROCESSED_DELTA)/decode(sum(EXECUTIONS_DELTA),0,1,sum(EXECUTIONS_DELTA)) row_process,
(sum(CPU_TIME_DELTA)/decode(sum(EXECUTIONS_DELTA),0,1,sum(EXECUTIONS_DELTA))/1000000/60) cpu_mins,
(sum(ELAPSED_TIME_DELTA)/decode(sum(EXECUTIONS_DELTA),0,1,sum(EXECUTIONS_DELTA))/1000000/60) elap_mins,
sum(SORTS_DELTA)/decode(sum(EXECUTIONS_DELTA),0,1,sum(EXECUTIONS_DELTA)) sorts,b.action
from dba_hist_snapshot a, DBA_HIST_SQLSTAT b where b.snap_id = a.snap_id and trunc(a.END_INTERVAL_TIME) between trunc(sysdate-&day) and trunc(sysdate-&day2) and PARSING_SCHEMA_NAME = recowner.username
and EXECUTIONS_DELTA is not null and b.action not like 'ORA$AT%' 
group by b.sql_id,b.action
)
select * from (select b.sql_id , execs, trunc(reads) reads,trunc(gets) gets, trunc(row_process) row_process , trunc(cpu_mins,2) cpu_mins, trunc(elap_mins,2) elap_mins, trunc(sorts,2) sorts,action from queryStat b 
--where sql_id not in ('d193fykn9ymhg','10q23wg18drqu','8b43b0dnsh6jj','4c7f6n6v403jc','cvcvct29vdfzw','cgg2c4rj68nz3','f66ysx1ac6hyj')
--and action <> 'SQL Window - New'
order by gets desc) where rownum <=10)
      loop
      dbms_output.put_line (recowner.username || ';' || recdata.sql_id || ';' || recdata.gets || ';' || recdata.action);
      schemagets:=schemagets + recdata.gets;
      end loop;
      if schemagets > 0 then
      dbms_output.put_line (';' ||recowner.username || ';' || schemagets);
      dbms_output.put_line (';' || ';');
      end if;
      schemagets:=0;
      end loop;
      end;
/
