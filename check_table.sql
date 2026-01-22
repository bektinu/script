select owner, object_type, object_name from dba_objects where object_name='&oname';

select owner, table_name, num_rows, last_analyzed, partitioned
from dba_tables
where owner='&owner' and table_name='&tname';
