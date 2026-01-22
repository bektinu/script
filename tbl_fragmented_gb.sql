set feedback off
set echo off

accept table_name char prompt 'Enter Table Name: '
variable b1 varchar2(50)
exec :b1 := upper('&table_name');

select owner, table_name, num_rows, partitioned, tablespace_name, last_analyzed, round((blocks*8)/1024/1024,2) "Frag GB size",
round((num_rows*avg_row_len)/1024/1024/1024,2) "Real GB size",
((round((blocks*8)/1024/1024,2)-round((num_rows*avg_row_len)/1024/1024/1024,2))/round((blocks*8)/1024/1024,2))*100 "Percentage"
from dba_tables
where owner = '&OWNER' and table_name = :b1;

undefine b1

set feedback on
set echo on
