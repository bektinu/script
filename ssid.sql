set lines 125 pages 1000 feed off echo off ver off

col sid form 99999
col serial# form 9999999
col spid form a7
col username form a11
col osuser form a10
col status form a8
col sql_text form a100
col program form a10
col machine form a16
col event for a50
col wait_class for a20
col sql_id new_value VSQL_ID

ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';

accept sid prompt 'enter value for sid: '

sELECT s.SID, s.serial#, p.spid, s.username, s.osuser, s.status, s.logon_time, s.program, s.machine, SYSDATE, event, wait_class, wait_time, seconds_in_wait, state, s.sql_id, s.prev_sql_id
S FROM v$session s, v$process p
 WHERE s.paddr = p.addr
   AND s.sid = '&sid';



--select * from table(dbms_xplan.display_cursor('&VSQL_ID');
SELECT   piece, replace(sql_text,chr(10)) sql_text from v$sqltext_with_newlines
   WHERE address =
               (SELECT DECODE (RAWTOHEX (s.sql_address), '00', s.prev_sql_addr, null, s.prev_sql_addr, s.sql_address)
                  FROM v$session s, v$process p
                 WHERE p.addr=s.paddr
                 and   s.sid='&sid')
ORDER BY piece;

select sid, client_identifier from v$session s where s.sid=&sid;
PROMPT
clear buffer
set feed on


