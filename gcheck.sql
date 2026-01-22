set lines 125
set long 10000
set linesize 500
set pagesize 100
set trimspool on
col sid for 999999
col username for a15
col program for a30
col machine for a30
col sql_id for a15
col serial# for 999999
col owner for a20
col object_type for a25
col object_name for a30
col table_name for a30
col index_name for a30
col column_name for a20
col first_time for 99999
col to_char(first_time,'YYYY-MON-DD') for a5
col to_char(sum(decode(to_char(first_time,'HH24'),'10',1,0)),'99') for a5
col "05" for 999999
col window_name for a25
col sequence_owner for a25
col sequence_name for a30
col min_value for 999,999
col max_value for 999,999,999,999,999,999,999,999,999,999,999
col for 999999
col inst_id for 99
col status for a10
col pid for a5
col ser# for a8
-- comment out this line for non-cdb. Modify or Enter the expected PDB Name for runtime execution
alter session set container=MYINDIHOME;

column dat noprint new_value file_dat
set head off
select to_char(sysdate,'DDMMYYYY-HH24') dat
from dual;
set head on

column pdbn noprint new_value file_pdb
set head off
select instance_name pdbn
from v$instance;
set head on

spool gcheck_&file_pdb-&file_dat

prompt #########################################################################################################################
prompt display free sga memory
prompt ########################################################################################################################
select pool,
       round(bytes/1024/1024,0) free_mb
from v$sgastat
where name like '%free_memory%';

prompt ########################################################################################################################
prompt display buffer cache hit ratio
prompt ########################################################################################################################
select  (1 - (prc.value / (cgfc.value + dbgfc.value))) * 100 "Buffer Hit Ratio"
from v$sysstat prc,
     v$sysstat cgfc,
     v$sysstat dbgfc
where prc.name = 'physical reads cache' and
     dbgfc.name = 'db block gets from cache' and
     cgfc.name = 'consistent gets from cache';

prompt ########################################################################################################################
prompt display buffer pool advisory
prompt ########################################################################################################################
col size_for_estimate          for 999,999,999,999 heading 'Cache Size (MB)'
col buffers_for_estimate       for 999,999,999 heading 'Buffers'
col estd_physical_read_factor  for 999.90 heading 'Estd Phys|Read Factor'
col estd_physical_reads        for 999,999,999,999 heading 'Estd Phys| Reads'
select size_for_estimate,
       buffers_for_estimate,
       estd_physical_read_factor,
       estd_physical_reads
from v$db_cache_advice
where name = 'DEFAULT' and
      block_size = (select value from v$parameter where name = 'db_block_size') and
      advice_status = 'ON';

prompt ########################################################################################################################
prompt display library cache namespace trends
prompt ########################################################################################################################
select namespace,
       pins,
       pinhits,
       reloads,
       invalidations
from v$librarycache
order BY namespace;

prompt ########################################################################################################################
prompt display library cache hit ratio
prompt ########################################################################################################################
select (sum(pinhits)/sum(pins)) * 100 "Library Cache Hit Ratio"
from v$librarycache;

prompt ########################################################################################################################
prompt display dictionary cache statistics
prompt ########################################################################################################################
select parameter,
       sum(gets),
       sum(getmisses),
       100*sum(gets - getmisses) / sum(gets) pct_succ_gets,
       sum(modifications) updates
from v$rowcache
where gets > 0
group by parameter;

prompt ########################################################################################################################
prompt display dictionary cache hit ratio
prompt ########################################################################################################################
select ((sum(gets - getmisses - fixed)) / sum (gets))*100 "row cache"
from v$rowcache;

prompt ########################################################################################################################
prompt display sga advisory
prompt ########################################################################################################################
conn / as sysdba
select sga_size,
       sga_size_factor,
       estd_db_time_factor
from v$sga_target_advice
order by sga_size asc;

-- @change2pdb.sql --> alter session set container=PDBNAME;
alter session set container=MYINDIHOME;

prompt ########################################################################################################################
prompt display pga hit ratio
prompt ########################################################################################################################
select value
from v$pgastat
where name='cache hit percentage';

prompt ########################################################################################################################
prompt display top-20 fragmented objects
prompt ########################################################################################################################
select *
from (select owner,
			 table_name,
			 round((blocks * 8)/1024, 2) "size (mb)",
			 round((num_rows * avg_row_len / 1024 /1024), 2) "actual_data (mb)",
			 (round((blocks * 8)/1024, 2) - round((num_rows * avg_row_len / 1024 / 1024), 2)) "wasted_space (mb)"
      from dba_tables
      where (round((blocks * 8)/1024, 2) > round((num_rows * avg_row_len / 1024 / 1024), 2))
      order by 5 desc)
where rownum <= 20;

prompt ########################################################################################################################
prompt auto task operation and schedule
prompt ########################################################################################################################
select client_name,
       status
from dba_autotask_operation;
select * from dba_autotask_schedule;

prompt ########################################################################################################################
prompt display invalid objects
prompt ########################################################################################################################
select owner,
       object_type,
       object_name,
       status
from dba_objects
where status='INVALID'
order by 1,2,3;

prompt ########################################################################################################################
prompt display missing statistics in non-system objects
prompt ########################################################################################################################
select 'TABLE' object_type,
       owner,
       table_name object_name,
       last_analyzed,
       stattype_locked,
       stale_stats
from all_tab_statistics
where (last_analyzed is null or stale_stats = 'YES') and
      stattype_locked is null and
      owner not in ('ANONYMOUS', 'CTXSYS', 'DBSNMP','EXFSYS','LBACSYS','MDSYS','MGMT_VIEW') and
      owner not in ('OLAPSYS','OWBSYS','ORDPLUGINS','ORDSYS','OUTLN','SI_INFORMTN_SCHEMA','SYS','ORDDATA','OJVMSYS') and
      owner not in ('SYSMAN','SYSTEM','TSMSYS','WK_TEST','WKSYS','WKPROXY','WMSYS','XDB','APEX_040200') and
      owner not like 'FLOW%'
union all
select 'INDEX' object_type,owner,
       index_name object_name,
       last_analyzed,
       stattype_locked,
       stale_stats
from all_ind_statistics
where (last_analyzed is null or stale_stats = 'YES') and
       stattype_locked IS NULL and
       owner not in ('ANONYMOUS', 'CTXSYS', 'DBSNMP','EXFSYS','LBACSYS','MDSYS','MGMT_VIEW') and
       owner not in ('OLAPSYS','OWBSYS','ORDPLUGINS','ORDSYS','OUTLN','SI_INFORMTN_SCHEMA','SYS','ORDDATA','OJVMSYS') and
       owner not in ('SYSMAN','SYSTEM','TSMSYS','WK_TEST','WKSYS','WKPROXY','WMSYS','XDB','APEX_040200') and
       owner not like 'FLOW%'
order by object_type desc, owner, object_name
/

prompt ########################################################################################################################
prompt display archivelog generation
prompt ########################################################################################################################
select to_char(first_time,'YYYY-MON-DD') day,
to_char(sum(decode(to_char(first_time,'HH24'),'00',1,0)),'999') "00",
to_char(sum(decode(to_char(first_time,'HH24'),'01',1,0)),'999') "01",
to_char(sum(decode(to_char(first_time,'HH24'),'02',1,0)),'999') "02",
to_char(sum(decode(to_char(first_time,'HH24'),'03',1,0)),'999') "03",
to_char(sum(decode(to_char(first_time,'HH24'),'04',1,0)),'999') "04",
to_char(sum(decode(to_char(first_time,'HH24'),'05',1,0)),'999') "05",
to_char(sum(decode(to_char(first_time,'HH24'),'06',1,0)),'999') "06",
to_char(sum(decode(to_char(first_time,'HH24'),'07',1,0)),'999') "07",
to_char(sum(decode(to_char(first_time,'HH24'),'08',1,0)),'999') "08",
to_char(sum(decode(to_char(first_time,'HH24'),'09',1,0)),'999') "09",
to_char(sum(decode(to_char(first_time,'HH24'),'10',1,0)),'999') "10",
to_char(sum(decode(to_char(first_time,'HH24'),'11',1,0)),'999') "11",
to_char(sum(decode(to_char(first_time,'HH24'),'12',1,0)),'999') "12",
to_char(sum(decode(to_char(first_time,'HH24'),'13',1,0)),'999') "13",
to_char(sum(decode(to_char(first_time,'HH24'),'14',1,0)),'999') "14",
to_char(sum(decode(to_char(first_time,'HH24'),'15',1,0)),'999') "15",
to_char(sum(decode(to_char(first_time,'HH24'),'16',1,0)),'999') "16",
to_char(sum(decode(to_char(first_time,'HH24'),'17',1,0)),'999') "17",
to_char(sum(decode(to_char(first_time,'HH24'),'18',1,0)),'999') "18",
to_char(sum(decode(to_char(first_time,'HH24'),'19',1,0)),'999') "19",
to_char(sum(decode(to_char(first_time,'HH24'),'20',1,0)),'999') "20",
to_char(sum(decode(to_char(first_time,'HH24'),'21',1,0)),'999') "21",
to_char(sum(decode(to_char(first_time,'HH24'),'22',1,0)),'999') "22",
to_char(sum(decode(to_char(first_time,'HH24'),'23',1,0)),'999') "23"
from v$log_history
where to_char(first_time,'YYYY-MON')='2017-DEC'
group by to_char(first_time,'YYYY-MON-DD')
order by to_char(first_time,'YYYY-MON-DD');

prompt ########################################################################################################################
prompt display sql_id ordered by cpu_time
prompt ########################################################################################################################
select *
from (select sql_id,
             plan_hash_value,
             (cpu_time/1000000) "CPU SECONDS",
             disk_reads "DISK READS",
             buffer_gets "BUFFER GETS",
             executions "EXECUTIONS",
             (elapsed_time/1000000) "ELAPSED SECONDS",
             sql_fulltext
      from gv$sql s
      order by cpu_time desc nulls last )
where rownum <=5;

prompt ########################################################################################################################
prompt display sql_id ordered by disk_reads
prompt ########################################################################################################################
select *
from (select sql_id,
             plan_hash_value,
             (cpu_time/1000000) "CPU SECONDS",
             disk_reads "DISK READS",
             buffer_gets "BUFFER GETS",
             executions "EXECUTIONS",
             (elapsed_time/1000000) "ELAPSED SECONDS",
             sql_fulltext
      from gv$sql s
      order by disk_reads desc nulls last )
where rownum <=5;

prompt ########################################################################################################################
prompt display sql_id ordered by buffer_gets
prompt ########################################################################################################################
select *
from (select sql_id,
             plan_hash_value,
             (cpu_time/1000000) "CPU SECONDS",
             disk_reads "DISK READS",
             buffer_gets "BUFFER GETS",
             executions "EXECUTIONS",
             (elapsed_time/1000000) "ELAPSED SECONDS",
             sql_fulltext
      from gv$sql s
      order by buffer_gets desc nulls last )
where rownum <=5;

prompt ########################################################################################################################
prompt display sql_id ordered by executions
prompt ########################################################################################################################
select *
from (select sql_id,
             plan_hash_value,
             (cpu_time/1000000) "CPU SECONDS",
             disk_reads "DISK READS",
             buffer_gets "BUFFER GETS",
             executions "EXECUTIONS",
             (elapsed_time/1000000) "ELAPSED SECONDS",
             sql_fulltext
      from gv$sql s
      order by executions desc nulls last )
where rownum <=5;

prompt ########################################################################################################################
prompt display sql_id ordered by elapsed_time
prompt ########################################################################################################################
select *
from (select sql_id,
             plan_hash_value,
             (cpu_time/1000000) "CPU SECONDS",
             disk_reads "DISK READS",
             buffer_gets "BUFFER GETS",
             executions "EXECUTIONS",
             (elapsed_time/1000000) "ELAPSED SECONDS",
             sql_fulltext
      from gv$sql s
      order by elapsed_time/1000000 desc nulls last )
where rownum <=5;

prompt ########################################################################################################################
prompt display running session
prompt ########################################################################################################################
select b.inst_id,
       substr(a.spid,1,9) pid,
       substr(b.sid,1,5) sid,
       substr(b.serial#,1,5) ser#,
       substr(b.machine,1,6) box,
       substr(b.username,1,10) username,
       substr(b.osuser,1,8) os_user,
       substr(b.program,1,30) program,
       to_date(b.logon_time,'DD-MON-YYYY HH24:MI:SS') logon_time,
       b.status
from gv$session b,
     gv$process a
where b.paddr = a.addr and
      type='USER' and
      to_date(b.logon_time,'DD-MON-YYYY HH24:MI:SS') < sysdate-1
order by logon_time;

prompt ########################################################################################################################
prompt display near limit sequence
prompt ########################################################################################################################
select sequence_owner, 
       sequence_name, 
       min_value, 
       max_value, 
       increment_by, 
       cycle_flag, 
       cache_size, 
       last_number,
       max_value - (last_number+increment_by) limit
from dba_sequences
where max_value - (last_number+increment_by) < 1000;

spool off
