---------------CHECK  Top DML query by execution  


WITH sqlstattoday AS (
    SELECT to_char(end_interval_time, 'hh24') AS jam,
           parsing_schema_name,
           sql_id,
           SUM(executions_delta) AS totalexec,
           TRUNC(SUM(physical_read_bytes_delta / 1024 / 1024), 2) AS totalreadsmb,
           TRUNC(SUM(physical_write_bytes_delta / 1024 / 1024 / 1024), 2) AS write_GB
    FROM dba_hist_sqlstat a
    JOIN dba_hist_snapshot b ON a.snap_id = b.snap_id
    WHERE TRUNC(end_interval_time) = TRUNC(TO_DATE('2024-10-02', 'YYYY-MM-DD'))
      AND parsing_schema_name IS NOT NULL
    GROUP BY to_char(end_interval_time, 'hh24'), parsing_schema_name, sql_id
),
sqlstat_previous_day AS (
    SELECT to_char(end_interval_time, 'hh24') AS jam,
           parsing_schema_name,
           sql_id,
           SUM(executions_delta) AS totalexec,
           TRUNC(SUM(physical_read_bytes_delta / 1024 / 1024), 2) AS totalreadsmb,
           TRUNC(SUM(physical_write_bytes_delta / 1024 / 1024 / 1024), 2) AS write_GB
    FROM dba_hist_sqlstat a
    JOIN dba_hist_snapshot b ON a.snap_id = b.snap_id
    WHERE TRUNC(end_interval_time) = TRUNC(TO_DATE('2024-10-01', 'YYYY-MM-DD'))
      AND parsing_schema_name IS NOT NULL
    GROUP BY to_char(end_interval_time, 'hh24'), parsing_schema_name, sql_id
),
sesssql AS (
    SELECT to_char(sample_time, 'hh24') AS jam,
           sql_opname,
           sql_id,
           COUNT(DISTINCT session_id || session_serial#) AS totalsess
    FROM DBA_HIST_ACTIVE_SESS_HISTORY a
    WHERE to_char(sample_time, 'hh24') = :jam
      AND TRUNC(sample_time) = TRUNC(TO_DATE('2024-10-02', 'YYYY-MM-DD'))
      AND sql_opname IN ('INSERT', 'UPDATE', 'DELETE', 'UPSERT')
    GROUP BY to_char(sample_time, 'hh24'), sql_id, sql_opname
)
SELECT *
FROM (
    SELECT a.parsing_schema_name AS username,
           a.sql_id,
           b.sql_opname AS type,
           dbms_lob.substr(d.sql_text, 50, 1) AS text,
           CASE
               WHEN c.totalexec IS NULL THEN a.totalexec
               ELSE TRUNC(a.totalexec / DECODE(c.totalexec, 0, 1, c.totalexec), 2)
           END AS escl,
           a.totalexec AS exectoday,
           c.totalexec AS exec_previous_day,
           a.write_GB AS writetoday,
           c.write_GB AS write_previous_day,
           a.totalreadsmb AS readsmbtoday,
           c.totalreadsmb AS readsmb_previous_day,
           b.totalsess
    FROM sqlstattoday a
    JOIN sesssql b ON a.sql_id = b.sql_id AND a.jam = b.jam
    LEFT JOIN sqlstat_previous_day c ON a.sql_id = c.sql_id AND a.jam = c.jam AND a.parsing_schema_name = c.parsing_schema_name
    LEFT JOIN dba_hist_sqltext d ON a.sql_id = d.sql_id
    ORDER BY escl DESC
)
WHERE rownum <= 25;



------ BISA DETAIL PER JAM DAN SESUAIKAN TANGGALNYA 



WITH sqlstattoday AS (
    SELECT to_char(end_interval_time, 'hh24') AS jam,
           parsing_schema_name,
           sql_id,
           SUM(executions_delta) AS totalexec,
           TRUNC(SUM(physical_read_bytes_delta / 1024 / 1024/ 1024), 2) AS totalreadsGB,
           TRUNC(SUM(physical_write_bytes_delta / 1024 / 1024 / 1024), 2) AS write_GB
    FROM dba_hist_sqlstat a
    JOIN dba_hist_snapshot b ON a.snap_id = b.snap_id
    WHERE TRUNC(end_interval_time) = TRUNC(TO_DATE('2024-11-08', 'YYYY-MM-DD'))
      AND parsing_schema_name IS NOT NULL
    GROUP BY to_char(end_interval_time, 'hh24'), parsing_schema_name, sql_id
),
sqlstat_previous_day AS (
    SELECT to_char(end_interval_time, 'hh24') AS jam,
           parsing_schema_name,
           sql_id,
           SUM(executions_delta) AS totalexec,
           TRUNC(SUM(physical_read_bytes_delta / 1024 / 1024 / 1024), 2) AS totalreadsGB,
           TRUNC(SUM(physical_write_bytes_delta / 1024 / 1024 / 1024), 2) AS write_GB
    FROM dba_hist_sqlstat a
    JOIN dba_hist_snapshot b ON a.snap_id = b.snap_id
    WHERE TRUNC(end_interval_time) = TRUNC(TO_DATE('2024-11-07', 'YYYY-MM-DD'))
      AND parsing_schema_name IS NOT NULL
    GROUP BY to_char(end_interval_time, 'hh24'), parsing_schema_name, sql_id
),
sesssql AS (
    SELECT to_char(sample_time, 'hh24') AS jam,
           sql_opname,
           sql_id,
           COUNT(DISTINCT session_id || session_serial#) AS totalsess
    FROM DBA_HIST_ACTIVE_SESS_HISTORY a
    WHERE to_char(sample_time, 'hh24') = :jam
      AND TRUNC(sample_time) = TRUNC(TO_DATE('2024-11-08', 'YYYY-MM-DD'))
      AND sql_opname IN ('INSERT', 'UPDATE', 'DELETE', 'UPSERT')
    GROUP BY to_char(sample_time, 'hh24'), sql_id, sql_opname
)
SELECT *
FROM (
    SELECT a.parsing_schema_name AS username,
           a.sql_id,
           b.sql_opname AS type,
           dbms_lob.substr(d.sql_text, 50, 1) AS text,
           CASE
               WHEN c.totalexec IS NULL THEN a.totalexec
               ELSE TRUNC(a.totalexec / DECODE(c.totalexec, 0, 1, c.totalexec), 2)
           END AS escl,
           a.totalexec AS exectoday,
           c.totalexec AS exec_previous_day,
           a.write_GB AS writetodayGB,
           c.write_GB AS write_previous_dayGB,
           a.totalreadsGB AS readsGBtoday,
           c.totalreadsGB AS readsGB_previous_day,
           b.totalsess
    FROM sqlstattoday a
    JOIN sesssql b ON a.sql_id = b.sql_id AND a.jam = b.jam
    LEFT JOIN sqlstat_previous_day c ON a.sql_id = c.sql_id AND a.jam = c.jam AND a.parsing_schema_name = c.parsing_schema_name
    LEFT JOIN dba_hist_sqltext d ON a.sql_id = d.sql_id
    ORDER BY escl DESC
)
WHERE rownum <= 25;

===========
1. check redolog switch tinggi atau tidak
2. check growth jika anomali spesifik bisa pakai query inst_id
============



-==============CHECK process WITH write_GB TERTINGGI per hari

WITH sqlstattoday AS (
    SELECT parsing_schema_name,
           sql_id,
           SUM(executions_delta) AS totalexec,
           TRUNC(SUM(physical_read_bytes_delta / 1024 / 1024 / 1024), 2) AS totalreadsGB,
           TRUNC(SUM(physical_write_bytes_delta / 1024 / 1024 / 1024), 2) AS write_GB
    FROM dba_hist_sqlstat a
    JOIN dba_hist_snapshot b ON a.snap_id = b.snap_id
    WHERE TRUNC(end_interval_time) = TRUNC(TO_DATE('2024-11-08', 'YYYY-MM-DD'))
      AND parsing_schema_name IS NOT NULL
    GROUP BY parsing_schema_name, sql_id
),
sqlstat_previous_day AS (
    SELECT parsing_schema_name,
           sql_id,
           SUM(executions_delta) AS totalexec,
           TRUNC(SUM(physical_read_bytes_delta / 1024 / 1024 / 1024), 2) AS totalreadsGB,
           TRUNC(SUM(physical_write_bytes_delta / 1024 / 1024 / 1024), 2) AS write_GB
    FROM dba_hist_sqlstat a
    JOIN dba_hist_snapshot b ON a.snap_id = b.snap_id
    WHERE TRUNC(end_interval_time) = TRUNC(TO_DATE('2024-11-07', 'YYYY-MM-DD'))
      AND parsing_schema_name IS NOT NULL
    GROUP BY parsing_schema_name, sql_id
),
sesssql AS (
    SELECT sql_opname,
           sql_id,
           COUNT(DISTINCT session_id || session_serial#) AS totalsess
    FROM DBA_HIST_ACTIVE_SESS_HISTORY a
    WHERE TRUNC(sample_time) = TRUNC(TO_DATE('2024-11-08', 'YYYY-MM-DD'))
      AND sql_opname IN ('INSERT', 'UPDATE', 'DELETE', 'UPSERT')
    GROUP BY sql_id, sql_opname
)
SELECT *
FROM (
    SELECT a.parsing_schema_name AS username,
           a.sql_id,
           b.sql_opname AS type,
           dbms_lob.substr(d.sql_text, 50, 1) AS text,
           CASE
               WHEN c.totalexec IS NULL THEN a.totalexec
               ELSE TRUNC(a.totalexec / DECODE(c.totalexec, 0, 1, c.totalexec), 2)
           END AS escl,
           a.totalexec AS exectoday,
           c.totalexec AS exec_previous_day,
           a.write_GB AS writetodayGB,
           c.write_GB AS write_previous_dayGB,
           a.totalreadsGB AS readsGBtoday,
           c.totalreadsGB AS readsGB_previous_day,
           b.totalsess
    FROM sqlstattoday a
    JOIN sesssql b ON a.sql_id = b.sql_id
    LEFT JOIN sqlstat_previous_day c ON a.sql_id = c.sql_id AND a.parsing_schema_name = c.parsing_schema_name
    LEFT JOIN dba_hist_sqltext d ON a.sql_id = d.sql_id
    ORDER BY escl DESC
)
WHERE rownum <= 25;


-----filter per sql_id top dml consumption tablespace or storage asm

WITH sqlstattoday AS (
    SELECT parsing_schema_name,
           sql_id,
           SUM(executions_delta) AS totalexec,
           TRUNC(SUM(physical_read_bytes_delta / 1024 / 1024 / 1024), 2) AS totalreadsGB,
           TRUNC(SUM(physical_write_bytes_delta / 1024 / 1024 / 1024), 2) AS write_GB
    FROM dba_hist_sqlstat a
    JOIN dba_hist_snapshot b ON a.snap_id = b.snap_id
    WHERE TRUNC(end_interval_time) = TRUNC(TO_DATE('2025-09-01', 'YYYY-MM-DD'))
      AND parsing_schema_name IS NOT NULL
      AND sql_id IN ('95twp4kdyfv3p','4httdn2fuczhv')
    GROUP BY parsing_schema_name, sql_id
),
sqlstat_previous_day AS (
    SELECT parsing_schema_name,
           sql_id,
           SUM(executions_delta) AS totalexec,
           TRUNC(SUM(physical_read_bytes_delta / 1024 / 1024 / 1024), 2) AS totalreadsGB,
           TRUNC(SUM(physical_write_bytes_delta / 1024 / 1024 / 1024), 2) AS write_GB
    FROM dba_hist_sqlstat a
    JOIN dba_hist_snapshot b ON a.snap_id = b.snap_id
    WHERE TRUNC(end_interval_time) = TRUNC(TO_DATE('2025-08-31', 'YYYY-MM-DD'))
      AND parsing_schema_name IS NOT NULL
      AND sql_id IN ('95twp4kdyfv3p','4httdn2fuczhv')
    GROUP BY parsing_schema_name, sql_id
),
sesssql AS (
    SELECT sql_opname,
           sql_id,
           COUNT(DISTINCT session_id || session_serial#) AS totalsess
    FROM DBA_HIST_ACTIVE_SESS_HISTORY a
    WHERE TRUNC(sample_time) = TRUNC(TO_DATE('2025-09-01', 'YYYY-MM-DD'))
      AND sql_opname IN ('INSERT', 'UPDATE', 'DELETE', 'UPSERT')
      AND sql_id IN ('95twp4kdyfv3p','4httdn2fuczhv')
    GROUP BY sql_id, sql_opname
)
SELECT *
FROM (
    SELECT a.parsing_schema_name AS username,
           a.sql_id,
           b.sql_opname AS type,
           dbms_lob.substr(d.sql_text, 50, 1) AS text,
           CASE
               WHEN c.totalexec IS NULL THEN a.totalexec
               ELSE TRUNC(a.totalexec / DECODE(c.totalexec, 0, 1, c.totalexec), 2)
           END AS escl,
           a.totalexec AS exectoday,
           c.totalexec AS exec_previous_day,
           a.write_GB AS writetodayGB,
           c.write_GB AS write_previous_dayGB,
           a.totalreadsGB AS readsGBtoday,
           c.totalreadsGB AS readsGB_previous_day,
           b.totalsess
    FROM sqlstattoday a
    JOIN sesssql b ON a.sql_id = b.sql_id
    LEFT JOIN sqlstat_previous_day c 
           ON a.sql_id = c.sql_id AND a.parsing_schema_name = c.parsing_schema_name
    LEFT JOIN dba_hist_sqltext d ON a.sql_id = d.sql_id
    ORDER BY escl DESC
)
WHERE rownum <= 25;



-==============CHECK process WITH write_GB TERTINGGI per hari
