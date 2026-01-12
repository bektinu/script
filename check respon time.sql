SELECT 
    s.sql_id,
    u.username AS parsing_schema_name,
    s.executions_delta,
    (s.elapsed_time_delta / GREATEST(s.executions_delta, 1)) / 1000000 AS avg_response_time_sec,
    q.sql_text
FROM 
    dba_hist_sqlstat s
JOIN 
    dba_hist_snapshot sn 
    ON s.snap_id = sn.snap_id 
   AND s.dbid = sn.dbid 
   AND s.instance_number = sn.instance_number
JOIN 
    dba_hist_sqltext q 
    ON s.sql_id = q.sql_id
JOIN 
    dba_users u 
    ON s.parsing_schema_id = u.user_id
WHERE 
    sn.begin_interval_time BETWEEN TO_DATE('2025-05-05 15:30', 'YYYY-MM-DD HH24:MI')
                              AND TO_DATE('2025-05-05 16:59', 'YYYY-MM-DD HH24:MI')
  AND s.executions_delta > 0
ORDER BY 
    avg_response_time_sec DESC
FETCH FIRST 10 ROWS ONLY;
