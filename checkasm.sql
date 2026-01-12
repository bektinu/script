SELECT
name group_name
, sector_size sector_size
, block_size block_size
, allocation_unit_size allocation_unit_size
, state state
, type type
, total_mb total_mb
, (total_mb - free_mb) used_mb
, ROUND((1- (free_mb / total_mb))*100, 2) pct_used
FROM
v$asm_diskgroup
ORDER BY
name
;



---historical asm 
-- Tablespace usage monitoring query (similar to your output)
SELECT
    (SELECT name FROM v$database) AS DBNAME,
    df.tablespace_name           AS DG_NAME,
    ROUND(SUM(df.bytes) / 1024 / 1024) AS TOTAL_MB,
    ROUND((SUM(df.bytes) - SUM(f.free_bytes)) / 1024 / 1024) AS USED_MB,
    ROUND(SUM(f.free_bytes) / 1024 / 1024) AS FREE_MB,
    ROUND(((SUM(df.bytes) - SUM(f.free_bytes)) / SUM(df.bytes)) * 100) AS PCT_USED,
    CASE 
        WHEN ((SUM(df.bytes) - SUM(f.free_bytes)) / SUM(df.bytes)) * 100 >= 95 THEN '*****'
        WHEN ((SUM(df.bytes) - SUM(f.free_bytes)) / SUM(df.bytes)) * 100 >= 90 THEN '****'
        WHEN ((SUM(df.bytes) - SUM(f.free_bytes)) / SUM(df.bytes)) * 100 >= 80 THEN '***'
        ELSE '**'
    END AS ALRT,
    TRUNC(SYSDATE) AS CREATED_DATE
FROM
    (SELECT tablespace_name, SUM(bytes) AS bytes
     FROM dba_data_files
     GROUP BY tablespace_name) df,
    (SELECT tablespace_name, SUM(bytes) AS free_bytes
     FROM dba_free_space
     GROUP BY tablespace_name) f
WHERE df.tablespace_name = f.tablespace_name
GROUP BY df.tablespace_name
ORDER BY PCT_USED DESC;


-- Combined Tablespace + ASM DiskGroup Usage Report
SELECT 
    (SELECT name FROM v$database) AS DBNAME,
    ts.tablespace_name            AS DG_NAME,
    ROUND(SUM(ts.total_mb))       AS TOTAL_MB,
    ROUND(SUM(ts.used_mb))        AS USED_MB,
    ROUND(SUM(ts.free_mb))        AS FREE_MB,
    ROUND((SUM(ts.used_mb)/SUM(ts.total_mb))*100) AS PCT_USED,
    CASE 
        WHEN (SUM(ts.used_mb)/SUM(ts.total_mb))*100 >= 95 THEN '*****'
        WHEN (SUM(ts.used_mb)/SUM(ts.total_mb))*100 >= 90 THEN '****'
        WHEN (SUM(ts.used_mb)/SUM(ts.total_mb))*100 >= 80 THEN '***'
        ELSE '**'
    END AS ALRT,
    TRUNC(SYSDATE) AS CREATED_DATE
FROM (
    -- Tablespace usage
    SELECT 
        df.tablespace_name,
        ROUND(SUM(df.bytes)/1024/1024) AS total_mb,
        ROUND((SUM(df.bytes)-SUM(fs.free_bytes))/1024/1024) AS used_mb,
        ROUND(SUM(fs.free_bytes)/1024/1024) AS free_mb
    FROM (
        SELECT tablespace_name, SUM(bytes) AS bytes
        FROM dba_data_files
        GROUP BY tablespace_name
    ) df
    JOIN (
        SELECT tablespace_name, SUM(bytes) AS free_bytes
        FROM dba_free_space
        GROUP BY tablespace_name
    ) fs ON df.tablespace_name = fs.tablespace_name
    GROUP BY df.tablespace_name

    UNION ALL

    -- ASM Diskgroup usage
    SELECT 
        dg.name AS tablespace_name,
        ROUND(dg.total_mb) AS total_mb,
        ROUND(dg.total_mb - dg.free_mb) AS used_mb,
        ROUND(dg.free_mb) AS free_mb
    FROM v$asm_diskgroup dg
) ts
GROUP BY ts.tablespace_name
ORDER BY PCT_USED DESC;
