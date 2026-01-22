SELECT a.tablespace_name tbsname
,      ROUND((((SUM(a.bytes) - b.free)*100) /  SUM(DECODE(a.autoextensible, 'NO', a.bytes, a.maxbytes))) , 0) percent_occupied
FROM   dba_data_files a
,      (SELECT   tablespace_name
        ,        SUM(bytes) free
        FROM     dba_free_space
        GROUP BY tablespace_name) b
WHERE   a.tablespace_name = b.tablespace_name(+)
GROUP BY a.tablespace_name
,        b.free
HAVING   ROUND((((SUM(a.bytes) - b.free)*100) /SUM(DECODE(a.autoextensible, 'NO', a.bytes, a.maxbytes))) , 0) < 80
--HAVING   ROUND((((SUM(a.bytes) - b.free)*100) /SUM(a.bytes)) , 0) > 80
ORDER BY 2 DESC;
