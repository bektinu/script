SET LINESIZE 300 PAGESIZE 200 TRIMSPOOL ON VERIFY OFF FEEDBACK ON
COLUMN sql_id           FORMAT A13
COLUMN plan_hash_value  FORMAT 9999999999
COLUMN parsing_schema   FORMAT A20
COLUMN module           FORMAT A20
COLUMN buffer_gets      FORMAT 999,999,999,999
COLUMN execs            FORMAT 999,999,999
COLUMN gets_per_exec    FORMAT 999,999,999.99
COLUMN elapsed_s        FORMAT 999,999,999.99
COLUMN cpu_s            FORMAT 999,999,999.99
COLUMN disk_reads       FORMAT 999,999,999
COLUMN first_load_time  FORMAT A19
COLUMN last_active_time FORMAT A19

DEF topn = 30

WITH base AS (
  SELECT
    s.sql_id,
    s.plan_hash_value,
    NVL(s.parsing_schema_name, 'UNKNOWN') AS parsing_schema,
    s.module,
    s.buffer_gets,
    s.EXECUTIONS AS execs,
    CASE WHEN s.EXECUTIONS > 0 THEN s.buffer_gets / s.EXECUTIONS ELSE NULL END AS gets_per_exec,
    s.elapsed_time/1e6 AS elapsed_s,
    s.cpu_time/1e6     AS cpu_s,
    s.disk_reads,
    TO_CHAR(s.first_load_time,'YYYY-MM-DD HH24:MI:SS') AS first_load_time,
    TO_CHAR(s.LAST_ACTIVE_TIME,'YYYY-MM-DD HH24:MI:SS') AS last_active_time
  FROM   V$SQLSTATS s
  WHERE  s.buffer_gets > 0
)
SELECT *
FROM   base
ORDER  BY buffer_gets DESC
FETCH  FIRST &topn ROWS ONLY;
