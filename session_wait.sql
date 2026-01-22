set feed off
alter session set nls_date_format='DD-MON-RR HH24:MI:SS';

set lines 125 pages 1000 feed on
col event for a40
col wait_class for a17
col username for a15
col program for a28

select sid, username, status, program, logon_time, event, wait_class, wait_time, seconds_in_wait, state from v$session where status='ACTIVE' and wait_class <> 'Idle' order by logon_time
/


