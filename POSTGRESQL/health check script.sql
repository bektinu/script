PostgreSQL – Health Check Scripts

Check Uptime
SELECT current_timestamp - pg_postmaster_start_time();


Checking session in postgresql (Melihat berapa banyak koneksi yang aktif dan apakah ada kueri yang berjalan terlalu lama)
--Cari kueri dengan age yang sangat lama
SELECT pid, age(clock_timestamp(), query_start), usename, state, query 
FROM pg_stat_activity 
WHERE state != 'idle' AND query NOT LIKE '%pg_stat_activity%';


Monitor cache hit ratio
Tells how often your data is served from memory vs having to go to disk. 99% is a good metric for performance. Read Less

SELECT
  sum(heap_blks_read) as heap_read,
  sum(heap_blks_hit)  as heap_hit,
  sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) as ratio
FROM
  pg_statio_user_tables;
SELECT 
  datname, 
  (
    blks_hit * 100 /(blks_hit + blks_read)
  ):: numeric as hit_ratio 
from 
  pg_stat_database WHERE 
  datname not in (
    'postgres', 'template0', 'template1'
  );
If the hit ratio is less than 90%, there may be a problem with low allocation of shared buffers or queries doing large table scans. The hit ratio should be close to 100%. Boost shared buffers or tweak queries that do more IO.

Check unvacummed dead tupes – Get table bloat information

Bloat can slow down other write and creates other issues.

1st script:

WITH constants AS (
  SELECT current_setting('block_size')::numeric AS bs, 23 AS hdr, 4 AS ma
), bloat_info AS (
  SELECT
    ma,bs,schemaname,tablename,
    (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
    (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
  FROM (
    SELECT
      schemaname, tablename, hdr, ma, bs,
      SUM((1-null_frac)*avg_width) AS datawidth,
      MAX(null_frac) AS maxfracsum,
      hdr+(
        SELECT 1+count(*)/8
        FROM pg_stats s2
        WHERE null_frac<>0 AND s2.schemaname = s.schemaname AND s2.tablename = s.tablename
      ) AS nullhdr
    FROM pg_stats s, constants
    GROUP BY 1,2,3,4,5
  ) AS foo
), table_bloat AS (
  SELECT
    schemaname, tablename, cc.relpages, bs,
    CEIL((cc.reltuples*((datahdr+ma-
      (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::float)) AS otta
  FROM bloat_info
  JOIN pg_class cc ON cc.relname = bloat_info.tablename
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = bloat_info.schemaname AND nn.nspname <> 'information_schema'
), index_bloat AS (
  SELECT
    schemaname, tablename, bs,
    COALESCE(c2.relname,'?') AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
    COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::float)),0) AS iotta -- very rough approximation, assumes all cols
  FROM bloat_info
  JOIN pg_class cc ON cc.relname = bloat_info.tablename
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = bloat_info.schemaname AND nn.nspname <> 'information_schema'
  JOIN pg_index i ON indrelid = cc.oid
  JOIN pg_class c2 ON c2.oid = i.indexrelid
)
SELECT
  type, schemaname, object_name, bloat, pg_size_pretty(raw_waste) as waste
FROM
(SELECT
  'table' as type,
  schemaname,
  tablename as object_name,
  ROUND(CASE WHEN otta=0 THEN 0.0 ELSE table_bloat.relpages/otta::numeric END,1) AS bloat,
  CASE WHEN relpages < otta THEN '0' ELSE (bs*(table_bloat.relpages-otta)::bigint)::bigint END AS raw_waste
FROM
  table_bloat
    UNION
SELECT
  'index' as type,
  schemaname,
  tablename || '::' || iname as object_name,
  ROUND(CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages/iotta::numeric END,1) AS bloat,
  CASE WHEN ipages < iotta THEN '0' ELSE (bs*(ipages-iotta))::bigint END AS raw_waste
FROM
  index_bloat) bloat_summary
ORDER BY raw_waste DESC, bloat DESC;
2nd Script:

WITH constants AS 
(
       -- define some constants for sizes of things
       -- for reference down the query and easy maintenance
       
   SELECT
      current_setting('block_size')::numeric AS bs,
      23 AS hdr,
      8 AS ma 
)
,
no_stats AS 
(
       -- screen out table who have attributes
       -- which dont have stats, such as JSON
       
   SELECT
      table_schema,
      table_name,
              n_live_tup::numeric as est_rows,
              pg_table_size(relid)::numeric as table_size     
   FROM
      information_schema.columns         
      JOIN
         pg_stat_user_tables as psut            
         ON table_schema = psut.schemaname            
         AND table_name = psut.relname         
      LEFT OUTER JOIN
         pg_stats         
         ON table_schema = pg_stats.schemaname             
         AND table_name = pg_stats.tablename             
         AND column_name = attname     
   WHERE
      attname IS NULL         
      AND table_schema NOT IN 
      (
         'pg_catalog',
         'information_schema'
      )
          
   GROUP BY
      table_schema,
      table_name,
      relid,
      n_live_tup 
)
,
null_headers AS 
(
       -- calculate null header sizes
       -- omitting tables which dont have complete stats
       -- and attributes which aren't visible
       
   SELECT
              hdr + 1 + (sum(
      case
         when
            null_frac <> 0 
         THEN
            1 
         else
            0 
      END
) / 8) as nullhdr,         SUM((1 - null_frac)*avg_width) as datawidth,         MAX(null_frac) as maxfracsum,         schemaname,         tablename,         hdr, ma, bs     
   FROM
      pg_stats 
      CROSS JOIN
         constants         
      LEFT OUTER JOIN
         no_stats             
         ON schemaname = no_stats.table_schema             
         AND tablename = no_stats.table_name     
   WHERE
      schemaname NOT IN 
      (
         'pg_catalog', 'information_schema'
      )
              
      AND no_stats.table_name IS NULL         
      AND EXISTS 
      (
         SELECT
            1             
         FROM
            information_schema.columns                 
         WHERE
            schemaname = columns.table_schema                     
            AND tablename = columns.table_name 
      )
          
   GROUP BY
      schemaname,
      tablename,
      hdr,
      ma,
      bs 
)
,
data_headers AS 
(
       -- estimate header and row size
       
   SELECT
              ma,
      bs,
      hdr,
      schemaname,
      tablename,
              (datawidth + (hdr + ma - (
      case
         when
            hdr % ma = 0 
         THEN
            ma 
         ELSE
            hdr % ma 
      END
)))::numeric AS datahdr,         (maxfracsum*(nullhdr + ma - (
      case
         when
            nullhdr % ma = 0 
         THEN
            ma 
         ELSE
            nullhdr % ma 
      END
))) AS nullhdr2     
   FROM
      null_headers 
)
, table_estimates AS 
(
       -- make estimates of how large the table should be
       -- based on row and page size
       
   SELECT
      schemaname,
      tablename,
      bs,
              reltuples::numeric as est_rows,
      relpages * bs as table_bytes,
          CEIL((reltuples*             (datahdr + nullhdr2 + 4 + ma -                 (
      CASE
         WHEN
            datahdr % ma = 0                     
         THEN
            ma 
         ELSE
            datahdr % ma 
      END
)                 ) / (bs - 20))) * bs AS expected_bytes,         reltoastrelid     
   FROM
      data_headers         
      JOIN
         pg_class 
         ON tablename = relname         
      JOIN
         pg_namespace 
         ON relnamespace = pg_namespace.oid             
         AND schemaname = nspname     
   WHERE
      pg_class.relkind = 'r' 
)
, estimates_with_toast AS 
(
       -- add in estimated TOAST table sizes
       -- estimate based on 4 toast tuples per page because we dont have
       -- anything better.  also append the no_data tables
       
   SELECT
      schemaname,
      tablename,
              TRUE as can_estimate,
              est_rows,
              table_bytes + ( coalesce(toast.relpages, 0) * bs ) as table_bytes,
              expected_bytes + ( ceil( coalesce(toast.reltuples, 0) / 4 ) * bs ) as expected_bytes     
   FROM
      table_estimates 
      LEFT OUTER JOIN
         pg_class as toast         
         ON table_estimates.reltoastrelid = toast.oid             
         AND toast.relkind = 't' 
)
,
table_estimates_plus AS 
(
   -- add some extra metadata to the table data
   -- and calculations to be reused
   -- including whether we cant estimate it
   -- or whether we think it might be compressed
       
   SELECT
      current_database() as databasename,
                  schemaname,
      tablename,
      can_estimate,
                  est_rows,
                  
      CASE
         WHEN
            table_bytes > 0                 
         THEN
            table_bytes::NUMERIC                 
         ELSE
            NULL::NUMERIC 
      END
                      AS table_bytes,             
      CASE
         WHEN
            expected_bytes > 0                 
         THEN
            expected_bytes::NUMERIC                 
         ELSE
            NULL::NUMERIC 
      END
                          AS expected_bytes,             
      CASE
         WHEN
            expected_bytes > 0 
            AND table_bytes > 0                 
            AND expected_bytes <= table_bytes                 
         THEN
(table_bytes - expected_bytes)::NUMERIC                 
         ELSE
            0::NUMERIC 
      END
      AS bloat_bytes     
   FROM
      estimates_with_toast     
   UNION ALL
       
   SELECT
      current_database() as databasename,
              table_schema,
      table_name,
      FALSE,
              est_rows,
      table_size,
              NULL::NUMERIC,
      NULL::NUMERIC     FROM no_stats 
)
,
bloat_data AS 
(
       -- do final math calculations and formatting
       
   select
      current_database() as databasename,
              schemaname,
      tablename,
      can_estimate,
              table_bytes,
      round(table_bytes / (1024 ^ 2)::NUMERIC, 3) as table_mb,
              expected_bytes,
      round(expected_bytes / (1024 ^ 2)::NUMERIC, 3) as expected_mb,
              round(bloat_bytes*100 / table_bytes) as pct_bloat,
              round(bloat_bytes / (1024::NUMERIC ^ 2), 2) as mb_bloat,
              table_bytes,
      expected_bytes,
      est_rows     
   FROM
      table_estimates_plus 
)
-- filter output for bloated tables
SELECT
   databasename,
   schemaname,
   tablename,
       can_estimate,
       est_rows,
       pct_bloat,
   mb_bloat,
       table_mb 
FROM
   bloat_data -- this where clause defines which tables actually appear
   -- in the bloat chart
   -- example below filters for tables which are either 50%
   -- bloated and more than 20mb in size, or more than 25%
   -- bloated and more than 1GB in size
WHERE
   (
      pct_bloat >= 50 
      AND mb_bloat >= 20 
   )
       
   OR 
   (
      pct_bloat >= 25 
      AND mb_bloat >= 1000 
   )
ORDER BY
   pct_bloat DESC;
Finding Unused Indexes

The following query will return any unused indexes which are not part of any constraint.

SELECT s.schemaname,
  s.relname AS tablename,
  s.indexrelname AS indexname,
  pg_relation_size(s.indexrelid) AS index_size
FROM pg_catalog.pg_stat_user_indexes s
  JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
WHERE s.idx_scan = 0  
  AND 0 <>ALL (i.indkey)  
  AND NOT i.indisunique  
  AND NOT EXISTS  
  (SELECT 1 FROM pg_catalog.pg_constraint c
  WHERE c.conindid = s.indexrelid)
  AND NOT EXISTS  
  (SELECT 1 FROM pg_catalog.pg_inherits AS inh
  WHERE inh.inhrelid = s.indexrelid)
ORDER BY pg_relation_size(s.indexrelid) DESC;
Check query performance

SELECT query,
       calls,
       total_time,
       total_time / calls as time_per,
       stddev_time,
       rows,
       rows / calls as rows_per,
       100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent
FROM pg_stat_statements
WHERE query not similar to '%pg_%'
and calls > 500
--ORDER BY calls
--ORDER BY total_time
order by time_per
--ORDER BY rows_per
DESC LIMIT 20;
Check commit ratio of database

We must engage with the application team to determine why there are so many transaction rollbacks if the commit percentage is less than 95%. Consider a scenario where many of your transactions contain DML which can result in fragmentation.

SELECT 
  datname, 
  round(
    (
      xact_commit :: float * 100 /(xact_commit + xact_rollback)
    ):: numeric, 
    2
  ) as successful_xact_ratio 
FROM 
  pg_stat_database 
WHERE 
  datname not in (
    'postgres', 'template0', 'template1'
  );

rollback  (Melihat apakah banyak transaksi yang gagal/dibatalkan oleh aplikasi
  SELECT datname, xact_commit, xact_rollback, 
       (xact_commit::float / (xact_commit + xact_rollback)) * 100 as success_ratio
FROM pg_stat_database 
WHERE (xact_commit + xact_rollback) > 0;

  
Get the temp file usage of database
Use the log_temp_files parameter to log queries utilizing the temp files and modify the queries if you see that the temp files and bytes are high.

select 
  datname, 
  temp_files, 
  round(temp_bytes / 1024 / 1024, 2) as temp_filesize_MB 
from 
  pg_stat_database 
WHERE 
  datname not in (
    'postgres', 'template0', 'template1'
  ) 
  and temp_files > 0;


Frequency of Checkpoints

There are two important columns checkpoints_req, checkpoints_timed.

If the checkpoints_req is more than the checkpoints_timed, PostgreSQL is doing checkpoints due to the high WAL generation.

If the checkpoints are happening frequently it will cause more IO load on the machine so increase the max_wal_size parameter.

checkpoints_req > checkpoints_timed = (bad)PostgreSQL is doing checkpoints due to the high WAL generation.

Use the below query to find the frequency of the checkpoints.

Use below query to find the frequency of the checkpoints
WITH sub as (
  SELECT 
    EXTRACT(
      EPOCH 
      FROM 
        (now() - stats_reset)
    ) AS seconds_since_start, 
    (
      checkpoints_timed + checkpoints_req
    ) AS total_checkpoints 
  FROM 
    pg_stat_bgwriter
) 
SELECT 
  total_checkpoints, 
  seconds_since_start / total_checkpoints / 60 AS minutes_between_checkpoints 
FROM 
  sub;
Get top five tables with highest sequential scans

SELECT 
  schemaname, 
  relname, 
  seq_scan, 
  seq_tup_read, 
  seq_tup_read / seq_scan as avg_seq_tup_read 
FROM 
  pg_stat_all_tables 
WHERE 
  seq_scan > 0 
  and pg_total_relation_size(schemaname || '.' || relname) > 104857600 
  and schemaname IN ('"gameserver"')
ORDER BY 
  5 DESC 
LIMIT 
  20;


