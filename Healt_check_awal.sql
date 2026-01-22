--
--sql cek kondisi DB Versi 0.1
--date 16-oct-2021
--
spool cek_db.log
col SQL_TEXT format a60
col UP_TIME format a60
col USERNAME format a20
col DISKGROUP format a30
col ASMDISK format a30
col FAILGROUP format a30
col UP_TIME format a60
col RESOURCE_NAME format a30
set linesize 300
--Info Database
--TANGGAL
Select to_char(SYSDATE, 'DAY , DD/MON/YYYY HH24:MI:SS') as TANGGAL from dual;

select 'Info Database' as Info_Database from dual;
select   NAME, CREATED, LOG_MODE, CHECKPOINT_CHANGE#, ARCHIVE_CHANGE# from     sys.v_$database;

select 'Info Instance' as PENGECEKAN_instance from dual;
select   instance_name, instance_number, STARTUP_TIME, trunc(SYSDATE-(STARTUP_TIME) ) || ' day(s), ' || trunc(24*((SYSDATE-STARTUP_TIME) - trunc(SYSDATE-STARTUP_TIME)))||' hour(s), ' ||
         mod(trunc(1440*((SYSDATE-STARTUP_TIME) - trunc(SYSDATE-STARTUP_TIME))), 60) ||' minute(s), ' ||
         mod(trunc(86400*((SYSDATE-STARTUP_TIME) - trunc(SYSDATE-STARTUP_TIME))), 60) ||' seconds' as "UP_TIME"
from     sys.gv_$instance;


-- ASM STATUS

--Cek diskgroup ANOMALI
select 'CEK_ASM_STATUS_ANOMALI' as PENGECEKAN_asm from dual;
SELECT SUBSTR(dg.name,1,16) AS diskgroup, SUBSTR(d.name,1,16) AS asmdisk,
d.mount_status, d.state, SUBSTR(d.failgroup,1,16) AS failgroup 
FROM V$ASM_DISKGROUP dg, V$ASM_DISK d WHERE dg.group_number = d.group_number and d.state not in ('NORMAL');

--Status DB connect ke asm
select 'CEK_DB_CONNECT_KE_ASM' as PENGECEKAN_DB_KONEK_ASM from dual;
select group_number, db_name, status from v$asm_client;

--Cek Size ASM
select 'CEK_DISKGROUP_LEBIH_BESAR_95%_USED' as PENGECEKAN_space_diskgroup from dual;
select name, total_mb, free_mb, usable_file_mb,
round(((total_mb-nvl(free_mb,0))/total_mb)*100,0) "percent_used_>95"
from V$ASM_DISKGROUP_STAT where round(((total_mb-nvl(free_mb,0))/total_mb)*100,0) > 95 ;

--atau ini
select z.NAME, z.TOTAL_MB, z.USED_MB, z.free_mb, z.pct_used, z.pct_free from (SELECT G.NAME,
       sum(b.total_mb)                                     total_mb,
       sum((b.total_mb - b.free_mb))                        used_mb,
       sum(B.FREE_MB)   free_mb,
       decode(sum(b.total_mb),0,0,(ROUND((1- (sum(b.free_mb) / sum(b.total_mb)))*100, 2))) pct_used,
       decode(sum(b.total_mb),0,0,(ROUND(((sum(b.free_mb) / sum(b.total_mb)))*100, 2))) pct_free
FROM v$asm_disk b,v$asm_diskgroup g
where b.group_number = g.group_number(+)
group by g.name) z where z.pct_used >=95;


--Cek ASM proses
select 'CEK_ASM_PROSES' as PENGECEKAN_asm_proses from dual;
select INST_ID, OPERATION, STATE, POWER, SOFAR, EST_WORK, EST_RATE, EST_MINUTES from GV$ASM_OPERATION;

-- TABLESPACE
-- Cek tablespace Size
select 'CEK tablespace used % di atas 95%' as PENGECEKAN_tablespace from dual;
Select   ddf.TABLESPACE_NAME "TABLESPACE",
         ddf.MAXBYTES "MAXSIZE (MB)",
         (ddf.BYTES - dfs.bytes) "USED (MB)",
         ddf.MAXBYTES-(ddf.BYTES - dfs.bytes) "FREE (MB)",
         round(((ddf.BYTES - dfs.BYTES)/ddf.MAXBYTES)*100,2) "% USED"
from    (select TABLESPACE_NAME,
         round(sum(BYTES)/1024/1024,2) bytes,
         round(sum(decode(autoextensible,'NO',BYTES,MAXBYTES))/1024/1024,2) maxbytes
         from   dba_data_files
         group  by TABLESPACE_NAME) ddf,
        (select TABLESPACE_NAME,
                round(sum(BYTES)/1024/1024,2) bytes
         from   dba_free_space
         group  by TABLESPACE_NAME) dfs
where    ddf.TABLESPACE_NAME=dfs.TABLESPACE_NAME and round(((ddf.BYTES - dfs.BYTES)/ddf.MAXBYTES)*100,2) >95
order by (((ddf.BYTES - dfs.BYTES))/ddf.MAXBYTES) desc;


--REDO LOG
--cek redo swithselect 'CEK_redolog' as PENGECEKAN_redologswith from dual;
select 'CEK redo swith log' as PENGECEKAN_Redolog from dual;
col T00 format a4
col T01 format a4
col T02 format a4
col T03 format a4
col T04 format a4
col T05 format a4
col T06 format a4
col T07 format a4
col T08 format a4
col T09 format a4
col T10 format a4
col T11 format a4
col T12 format a4
col T13 format a4
col T14 format a4
col T15 format a4
col T16 format a4
col T17 format a4
col T18 format a4
col T19 format a4
col T20 format a4
col T21 format a4
col T22 format a4
col T23 format a4    
col FIRST_TIME format a15   
select   substr(to_char(FIRST_TIME,'DD/MM/YYYY, DY'),1,15) ,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0))) as T00,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0))) as T01,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0))) as T02,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0))) as T03,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0))) as T04,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0))) as T05,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0))) as T06,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0))) as T07,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0))) as T08,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0))) as T09,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0))) as T10,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0))) as T11,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0))) as T12,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0))) as T13,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0))) as T14,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0))) as T15,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0))) as T16,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0))) as T17,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0))) as T18,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0))) as T19,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0))) as T20,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0))) as T21,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0))) as T22,
         decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0))) as T23
from     sys.v_$log_history                                                                                                                     
group by substr(to_char(FIRST_TIME,'DD/MM/YYYY, DY'),1,15) 
order by substr(to_char(FIRST_TIME,'DD/MM/YYYY, DY'),1,15) ASC;


--Cek Redo File
col MEMBER format a60
select 'CEK REDO MEMBER' as CEK_REDO_MEMBER from dual;
select   a.MEMBER, b.GROUP#, b.THREAD#, b.SEQUENCE#, b.BYTES, b.MEMBERS, b.ARCHIVED, b.STATUS, b.FIRST_CHANGE#, b.FIRST_TIME
from     sys.v_$logfile a, sys.v_$log b where    a.GROUP# = b.GROUP# order by b.THREAD#, b.GROUP#, a.MEMBER;

--CEK RESOURCE
select 'CEK RESOURCE LIMITASI SESSION PROCCESS Dan TRANSAKSI' as CEK_RESOURCE from dual;
select INST_ID,  resource_name, current_utilization, max_utilization, limit_value
from gv$resource_limit
where resource_name in ( 'sessions', 'processes','transactions') order by INST_ID;


-- SESSION
select 'CEK SESSION ACTIVE DAN INACTIVE' as CEK_SESSION from dual;
set linesize 300 ;
select Username, count(1) as ACTIVE from gv$session where status ='ACTIVE' and username is not null and username not in ('SYS','SYSTEM')  group by username order by username;

set linesize 300 ;
select username, count(1) as INACTIVE from gv$session where status ='INACTIVE' and username is not null and username not in ('SYS','SYSTEM') group by username order by username;


--set linesize 300 ;
--col USERNAME_ACTIVE format a20
--select INST_ID, sid, serial#, username as USERNAME_ACTIVE, to_char(logon_time,'MM/DD/YYYY HH:MI:SS AM'),  machine, program from gv$session 
--where status ='ACTIVE' and username is not null and username not in ('SYS','SYSTEM') order by logon_time ,username;

--set linesize 300 ;
--col  USERNAME_INACTIVE format a20
--select INST_ID, sid, serial#, username as USERNAME_INACTIVE, to_char(logon_time,'MM/DD/YYYY HH:MI:SS AM'),  machine, program from gv$session 
--where status ='INACTIVE' and username is not null and username not in ('SYS','SYSTEM') order by logon_time ,username;


---LOCKING
--Cek Locking
select 'CEK LOCKING' as PENGECEKAN_locking from dual;
col OS_USER_NAME format a20
col PROCESS format a30
col ORACLE_USERNAME format a20
col TYPE_LOCK format a40
col LMODE format a20
col REQUEST format a20
col BLOCK_MODE format a20
select   OS_USER_NAME, PROCESS, ORACLE_USERNAME, l.SID,
         decode(TYPE,'MR', 'Media Recovery','RT', 'Redo Thread','UN', 'User Name','TX', 'Transaction',
            'TM', 'DML','UL', 'PL/SQL User Lock','DX', 'Distributed Xaction','CF', 'Control File','IS', 'Instance State',
            'FS', 'File Set','IR', 'Instance Recovery','ST', 'Disk Space Transaction', 'TS', 'Temp Segment','IV', 'Library Cache Invalidation','LS', 'Log Start or Switch',
            'RW', 'Row Wait','SQ', 'Sequence Number','TE', 'Extend Table','TT', 'Temp Table', type) as TYPE_LOCK,
         decode(LMODE, 0, 'None', 1, 'Null', 2, 'Row-S (SS)', 3, 'Row-X (SX)', 4, 'Share', 5, 'S/Row-X (SSX)', 6, 'Exclusive', lmode) as LMODE,
         decode(REQUEST, 0, 'None', 1, 'Null', 2, 'Row-S (SS)', 3, 'Row-X (SX)', 4, 'Share', 5, 'S/Row-X (SSX)', 6, 'Exclusive', request) as REQUEST,
         decode(BLOCK, 0, 'Not Blocking', 1, 'Blocking', 2, 'Global', block) as BLOCK_MODE,
         OWNER,
         OBJECT_NAME
from     sys.v_$locked_object lo, dba_objects do, sys.v_$lock l
where    lo.OBJECT_ID = do.OBJECT_ID
and      l.SID = lo.SESSION_ID;



-- Sql Lock
col USERNAME format a20
select 'CEK SESSION LOCKING SERTA Object Loking' as PENGECEKAN_LOCKING_SQL from dual;
select   sn.USERNAME,         m.SID,         sn.SERIAL#,         m.TYPE,
         decode(LMODE, 0, 'None', 1, 'Null', 2, 'Row-S (SS)', 3, 'Row-X (SX)', 4, 'Share',  5, 'S/Row-X (SSX)', 6, 'Exclusive') as LMODE,
         decode(REQUEST, 0, 'None', 1, 'Null', 2, 'Row-S (SS)', 3, 'Row-X (SX)', 4, 'Share', 5, 'S/Row-X (SSX)', 6, 'Exclusive') as REQUEST,
         m.ID1,  m.ID2,
         t.SQL_TEXT
from     sys.v_$session sn, sys.v_$lock m, sys.v_$sqltext t
where    t.ADDRESS = sn.SQL_ADDRESS 
and      t.HASH_VALUE = sn.SQL_HASH_VALUE 
and      ((sn.SID = m.SID and m.REQUEST != 0) 
or       (sn.SID = m.SID and m.REQUEST = 0 and LMODE != 4 and (ID1, ID2) in (
            select   s.ID1, 
                     s.ID2 
            from     sys.v_$lock S 
            where    REQUEST != 0 
            and      s.ID1 = m.ID1 
            and      s.ID2 = m.ID2)))
order by sn.USERNAME, sn.SID, t.PIECE;

--LONG OPERATION
set linesize 300
col MESSAGE format a120;
col STARTIME format a22;
select 'CEK SESSION LONG OPERATION' as PENGECEKAN_LONGOPS from dual;
select sid , to_char (START_TIME,'DD-MON-YY HH:MI AM') as startime,
serial#,
username, sofar/totalwork*100 pct_done,
TIME_REMAINING/60 as REMAINING_MIn ,
ELAPSED_SECONDs/60 as ELAPSED_MIN,
message from gv$session_longops where totalwork > sofar;


--CEK INDEX Unusable
select 'CEK INDEX YANG STATUS UNUSABLE' as PENGECEKAN_INDEX from dual;
SELECT owner, index_name, tablespace_name FROM   dba_indexes WHERE  status = 'UNUSABLE';
--Index partitions:
SELECT index_owner, index_name, partition_name, tablespace_name FROM   dba_ind_PARTITIONS WHERE  status = 'UNUSABLE';
--Index subpartitions:
SELECT index_owner, index_name, partition_name, subpartition_name, tablespace_name FROM   dba_ind_SUBPARTITIONS WHERE  status = 'UNUSABLE';


--SQL TOP
--Cek SQL 10 top 1 Dalam waktu 1 jam terakhir
select 'CEK TOP 10 SQL dalam 1 jam' as PENGECEKAN_SQL from dual;
select * from (
select active_session_history.sql_id,
 dba_users.username,
 sqlarea.sql_text,
sum(active_session_history.wait_time +
active_session_history.time_waited) ttl_wait_time
from v$active_session_history active_session_history,
v$sqlarea sqlarea,
 dba_users
where 
active_session_history.sample_time between sysdate -  1/24  and sysdate
  and active_session_history.sql_id = sqlarea.sql_id
and active_session_history.user_id = dba_users.user_id
 group by active_session_history.sql_id,sqlarea.sql_text, dba_users.username
 order by 4 desc )
where rownum <=10;


--Cek SQL Top Used CPU
select 'CEK TOP 10 SQL Pengunaan CPU dalam 24 Jam' as PENGECEKAN_SQL from dual;
select * from (
select a.SQL_ID, 
    sum(CPU_TIME_DELTA), 
    sum(DISK_READS_DELTA),
    count(*)
from 
    DBA_HIST_SQLSTAT a, dba_hist_snapshot s,v$sql ss
where
 s.snap_id = a.snap_id and a.sql_id=ss.sql_id
 and s.begin_interval_time > sysdate -1
    group by 
    ss.sql_text,a.SQL_ID
order by 
    sum(CPU_TIME_DELTA) desc)
where rownum<=10; 


--Cek SQL Top Used IO
select 'CEK TOP 10 SQL Penggunaan I/O dalam 24 Jam' as PENGECEKAN_SQL from dual;

select * from 
(
SELECT /*+LEADING(x h) USE_NL(h)*/ 
       h.sql_id
,      SUM(10) ash_secs
FROM   dba_hist_snapshot x
,      dba_hist_active_sess_history h
WHERE   x.begin_interval_time > sysdate -1
AND    h.SNAP_id = X.SNAP_id
AND    h.dbid = x.dbid
AND    h.instance_number = x.instance_number
AND    h.event in  ('db file sequential read','db file scattered read')
GROUP BY h.sql_id
ORDER BY ash_secs desc )
where rownum<=10;


--TOP 5 SQL dengan tidak menggunakan bind variable
select 'CEK TOP 10 SQL Tanpa Bind Variable' as PENGECEKAN_SQL from dual;
col SQL_TEXT format a60
col PLSQL_PROCEDURE format a20
col USER_NAME format a20
Select * 
from (
With subs as
(SELECT /*+ materialize */ m.sql_id, k.*, m.SQL_TEXT, m.SQL_FULLTEXT
FROM (SELECT inst_id, parsing_schema_name AS user_name, module, plan_hash_value, COUNT(0) copies, SUM(executions) executions, SUM(round(sharable_mem / (1024 * 1024), 2)) sharable_mem_mb
FROM gv$sqlarea WHERE executions < 5 AND kept_versions = 0
GROUP BY inst_id, parsing_schema_name, module, plan_hash_value
HAVING COUNT(0) > 10
ORDER BY COUNT(0) DESC) k
LEFT JOIN gv$sqlarea m
ON k.plan_hash_value = m.plan_hash_value
WHERE k.plan_hash_value > 0)
select distinct ki.inst_id, t.sql_id, ki.sql_text, t.plsql_procedure, ki.user_name, sum(ki.copies) copies, sum(ki.executions) executions, sum(ki.sharable_mem_mb) sharable_mem_mb
from (select sql_id, program_id, program_line#, action, module, service, parsing_schema_name, round(buffer_gets / decode(executions, 0, 1, executions)) buffer_per_Exec,
row_number() over(partition by sql_id order by program_id desc, program_line#) sira, decode(program_id, 0, null, owner || '.' || object_name || '(' || program_line# || ')') plsql_procedure
from gv$sql a, dba_objects b
where a.program_id = b.object_id(+)) t, subs ki
where ki.sql_id = t.sql_id and t.sira = 1
group by ki.inst_id, t.sql_id, ki.sql_text, t.plsql_procedure, ki.user_name
order by sum(ki.executions) desc
)
where rownum <= 10; 

spool off

exit


