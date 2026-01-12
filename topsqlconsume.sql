SELECT
    sql_id,
    COUNT(*) * 10 AS db_time_sec,
    ROUND(COUNT(*) * 10 / 60, 2) AS db_time_min
FROM
    dba_hist_active_sess_history
WHERE
    sample_time BETWEEN
        TO_DATE('2025-12-01 08:50','YYYY-MM-DD HH24:MI') AND
        TO_DATE('2025-12-01 09:20','YYYY-MM-DD HH24:MI')
GROUP BY
    sql_id
ORDER BY
    db_time_sec DESC
FETCH FIRST 10 ROWS ONLY;
