select sum(bytes)/1024/1024 from dba_segments
where segment_type='TABLE'
and segment_name='&name'
and owner='&owner';
