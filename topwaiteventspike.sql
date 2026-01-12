SELECT
    NVL(event, 'ON CPU') AS event,
    COUNT(*) AS samples,
    ROUND(COUNT(*) * 10 / 60,2) AS minutes
FROM
    dba_hist_active_sess_history
WHERE
  sample_time BETWEEN
        TO_DATE('2025-11-21 19:30','YYYY-MM-DD HH24:MI') AND
        TO_DATE('2025-11-21 19:33','YYYY-MM-DD HH24:MI')
GROUP BY
    event
ORDER BY
    samples DESC;
