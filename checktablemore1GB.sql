SELECT owner,
       segment_name AS table_name,
       ROUND(SUM(bytes)/1024/1024/1024, 2) AS size_gb
FROM   dba_segments
WHERE  segment_type = 'TABLE'
GROUP  BY owner, segment_name
HAVING SUM(bytes) > 1024*1024*1024 -- > 1 GB
ORDER  BY size_gb DESC;
