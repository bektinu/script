  SELECT 
    ahs.sample_time,
    ahs.sql_id,
    ahs.sql_child_number,
    ahs.session_id,
    ahs.session_serial#,
    ahs.user_id,
    ahs.module,
    ahs.action
FROM 
    dba_hist_active_sess_history ahs
WHERE 
    ahs.action LIKE '%DM_ORBP_PROCESS_PROC%'
    AND ahs.sample_time BETWEEN TO_DATE('2025-04-18', 'YYYY-MM-DD') 
    AND TO_DATE('2025-04-19', 'YYYY-MM-DD')
ORDER BY 
    ahs.sample_time DESC;
