SQL> select 'ALTER SYSTEM KILL SESSION ''' || sid ||','|| serial# ||',@'||inst_id||''' immediate;'
  2  from gv$session where status = 'SNIPED';
select 'ALTER SYSTEM KILL SESSION ''' || sid ||','|| serial# ||',@'||inst_id||''' immediate;'
*
ERROR at line 1:
ORA-01034: ORACLE not available 
Process ID: 0 
Session ID: 0 Serial number: 0 


SQL> spool off
