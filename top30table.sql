set pagesize 70;
set linesize 2000;
-- Print the custom header
PROMPT MONITORING TOP 30 BIG TABLE FROM SASID


SELECT
    TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') AS "Timestamp",
    owner,
    tablespace_name,
    segment_name AS table_name,
    ROUND(SUM(bytes) / 1024 / 1024, 2) AS table_size_MB
FROM 
    dba_segments
WHERE 
    segment_type = 'TABLE' and owner ='SDM'
GROUP BY 
    owner, 
    tablespace_name, 
    segment_name
ORDER BY 
    table_size_MB DESC
FETCH FIRST 30 ROWS ONLY;



-- Exit
EXIT;
