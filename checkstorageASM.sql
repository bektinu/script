SELECT dg.name AS "Disk Group", d.name AS "Disk Name",
       ROUND(d.total_mb / 1024, 2) AS "SIZE_GB",
       ROUND(d.free_mb / 1024, 2) AS "AVAILABLE_GB",
       ROUND((d.total_mb - d.free_mb) / d.total_mb * 100, 2) AS "USED%"
FROM v$asm_disk d
JOIN v$asm_diskgroup dg ON (d.group_number = dg.group_number)
ORDER BY dg.name, d.name;

SELECT name, type, total_mb, free_mb, required_mirror_free_mb, usable_file_mb
FROM V$ASM_DISKGROUP where name in ('HDWID_DATA2', 'HDWID_DATA3')
