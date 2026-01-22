col object_name for a30
col owner for a25
select owner, object_type, object_name, created, last_ddl_time from dba_objects where object_name='&objname';

