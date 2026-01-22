set lines 125 pages 1000
col member for a60
select l.group#, l.thread#, l.bytes, l.status, lf.member
from v$log l, v$logfile lf
where l.group# = lf.group#
order by 2,1;
