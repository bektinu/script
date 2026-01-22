select name, total_mb/1024, free_mb/1024, type, state from v$asm_diskgroup;

select tablespace_name, file_name, bytes/1024/1024/1024 df_gb, increment_by/1024/1024/1024 inc_gb, maxbytes/1024/1024/1024 max_gb
from dba_data_files
order by 1,2;

select sum(bytes)/1024/1024/1024 dbdf_size from dba_data_files;

select sum(bytes)/1024/1024/1024 dbseg_size from dba_segments;
