select index_name, status, uniqueness, last_analyzed, tablespace_name from dba_indexes where owner='&OWNER' and table_name='&TNAME' order by 1;
