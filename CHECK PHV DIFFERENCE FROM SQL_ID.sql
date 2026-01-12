SELECT
    s.sql_id,
    s.plan_hash_value,
    COUNT(*) AS snapshots,
    MIN(sn.begin_interval_time) AS first_seen,
    MAX(sn.end_interval_time) AS last_seen
FROM
    dba_hist_sqlstat s
JOIN
    dba_hist_snapshot sn ON s.snap_id = sn.snap_id AND s.instance_number = sn.instance_number
WHERE
    s.sql_id = 'your_sql_id_here'
GROUP BY
    s.sql_id,
    s.plan_hash_value
ORDER BY
    snapshots DESC;
