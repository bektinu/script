SELECT 'TABLE' object_type,owner, table_name object_name, last_analyzed, stattype_locked, stale_stats
FROM all_tab_statistics
WHERE (last_analyzed IS NULL OR stale_stats = 'YES') and stattype_locked IS NULL
and owner='MYINDIHOME'
UNION ALL
SELECT 'INDEX' object_type,owner, index_name object_name,  last_analyzed, stattype_locked, stale_stats
FROM all_ind_statistics
WHERE (last_analyzed IS NULL OR stale_stats = 'YES') and stattype_locked IS NULL
AND owner ='MYINDIHOME'
AND owner NOT LIKE 'FLOW%'
ORDER BY object_type desc, owner, object_name
/
