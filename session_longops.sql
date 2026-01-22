set lines 250
col sid form 999999
col serial# form 999999
col username form a10
col pct_done form 999
col message form a57
col event form a50
col wait_class form a20
select l.sid, l.serial#, s.status, s.logon_time, l.username , l.time_remaining, l.sofar/l.totalwork*100 pct_done,l.message, s.event, s.wait_class  from v$session_longops l, v$session s where l.totalwork <> l.sofar and s.sid=l.sid and s.serial#=l.serial# order by l.username, s.logon_time
/
