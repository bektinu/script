select a.*,b.sql_text
from(
select a.sql_opname,a.sql_id,b.username,b.account_status,b.profile,to_char(a.sample_time,'DD-MON-YYYY HH24') "HOUR",COUNT(DISTINCT a.SESSION_ID||a.SESSION_SERIAL#)as total
from dba_hist_active_sess_history a
join dba_users b on a.user_id = b.user_id
where a.sample_time >=to_timestamp('11-SEP-2024 16:55','DD-MON-YYYY HH24:MI')
and a.sample_time <= to_timestamp('11-SEP-2024 17:10','DD-MON-YYYY HH24:MI')
and b.username in('APP_MOBILE','APP_MERO')
GROUP BY to_char(a.sample_time,'DD-MON-YYYY HH24'),a.sql_opname,a.sql_id,b.username,b.account_status,b.profile
) a
join DBA_HIST_SQLTEXT b on a.sql_id = b.sql_id
order by a.total desc;




----check resource session, processes

SELECT resource_name,
       current_utilization,
       --max_utilization,
       limit_value
FROM v$resource_limit
WHERE resource_name IN ('sessions', 'processes');



    ---- PERFORMANCE DEGRADATION

    SELECT
    ash.sql_id,
    COUNT(*) AS total_samples,
    COUNT(DISTINCT ash.session_id || '-' || ash.session_serial#) AS distinct_sessions,
    DBMS_LOB.SUBSTR(sqt.sql_text, 1000, 1) AS sql_text
FROM
    dba_hist_active_sess_history ash
JOIN
    dba_hist_sqltext sqt ON ash.sql_id = sqt.sql_id
WHERE
    ash.event LIKE 'db file%'  -- Or use 'user I/O%' if applicable
    AND ash.sample_time BETWEEN TO_DATE('2025-04-30 18:30', 'YYYY-MM-DD HH24:MI')
                            AND TO_DATE('2025-04-30 19:40', 'YYYY-MM-DD HH24:MI')
GROUP BY
    ash.sql_id,
    DBMS_LOB.SUBSTR(sqt.sql_text, 1000, 1)
ORDER BY
    total_samples DESC
FETCH FIRST 10 ROWS ONLY;



---check performance degradation -- CHECK SPIKE SESSION
SELECT
    s.sql_id,
    s.plan_hash_value,
    s.snap_id,
    TO_CHAR(sn.begin_interval_time, 'YYYY-MM-DD HH24') AS begin_time,
    s.executions_delta,
    s.elapsed_time_delta / 1000000 AS elapsed_seconds,
    s.cpu_time_delta / 1000000 AS cpu_seconds,
    s.buffer_gets_delta,
    s.disk_reads_delta,
    s.rows_processed_delta,
    COUNT(DISTINCT ash.session_id || '-' || ash.session_serial#) AS distinct_sessions
FROM
    dba_hist_sqlstat s
JOIN
    dba_hist_snapshot sn
    ON s.snap_id = sn.snap_id
    AND s.dbid = sn.dbid
    AND s.instance_number = sn.instance_number
LEFT JOIN
    dba_hist_active_sess_history ash
    ON ash.sql_id = s.sql_id
    AND ash.sample_time BETWEEN sn.begin_interval_time AND sn.end_interval_time
WHERE
    s.sql_id IN ('1y2upd0mny15u')
    AND s.plan_hash_value = 4277205809
    AND sn.begin_interval_time >= TO_DATE('2025-04-23 01', 'YYYY-MM-DD HH24')
GROUP BY
    s.sql_id,
    s.plan_hash_value,
    s.snap_id,
    sn.begin_interval_time,
    s.executions_delta,
    s.elapsed_time_delta,
    s.cpu_time_delta,
    s.buffer_gets_delta,
    s.disk_reads_delta,
    s.rows_processed_delta
ORDER BY
    distinct_sessions DESC;
