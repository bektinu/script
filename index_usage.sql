SELECT index_name,
       table_name,
       monitoring,
       used,
       start_monitoring,
       end_monitoring
FROM   dba_object_usage
WHERE  index_name = '&name'
AND    owner = '&owner'
ORDER BY index_name;
