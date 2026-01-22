set lines 125 pages 1000 ver off feed off

col sid form 9999
col serial# form 9999999
col spid form a7
col username form a12
col osuser form a17
col status form a8
col sql_text form a100
col terminal form a10
col program form a18
col FETCHES form 9999999
col CPU_TIME form 99999999999
col ELAPSED_TIME form 99999999999 
col event for a30
col wait_class for a20

ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YY HH24:MI';

accept pid prompt 'enter value for pid: '

SELECT s.SID, s.serial#, p.spid, s.username, s.osuser, s.status, s.logon_time, s.program, s.terminal, SYSDATE, event, wait_class, wait_time, seconds_in_wait, state, s.sql_id, s.prev_sql_id
  FROM v$session s, v$process p
 WHERE s.paddr = p.addr
   AND p.spid = '&pid';

SELECT   piece, replace(sql_text,chr(10)) sql_text
    FROM v$sqltext_with_newlines
   WHERE address =
               (SELECT DECODE (RAWTOHEX (s.sql_address), '00', s.prev_sql_addr, null, s.prev_sql_addr, s.sql_address)
                  FROM v$session s, v$process p
                 WHERE p.addr=s.paddr
                 and   p.spid='&pid')
ORDER BY piece;
PROMPT

SELECT FETCHES,EXECUTIONS,PARSE_CALLS,DISK_READS,BUFFER_GETS,ROWS_PROCESSED,OPTIMIZER_MODE,OPTIMIZER_COST,CPU_TIME,ELAPSED_TIME
FROM V$SQLAREA
WHERE ADDRESS = (SELECT DECODE (RAWTOHEX (s.sql_address), '00', s.prev_sql_addr, null, s.prev_sql_addr, s.sql_address)
                  FROM v$session s, v$process p
                 WHERE p.addr=s.paddr
                 and   p.spid='&pid');
PROMPT
clear buffer

set VER ON feed on



