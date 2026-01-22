prompt -- "cpu_time", "disk_reads", "buffer_gets", "executions", "elapsed_time"
select * from (
	select inst_id, sql_id ,
	plan_hash_value,
	(cpu_time/1000000) "cpu_Secs",
	disk_reads "Dsk_Rds",
	buffer_gets "Buf_Gets",
	executions "Execs",
	(elapsed_time/1000000) "Elps_Secs"
	from gv$sql s
	order by &orderby desc nulls last )
where rownum <=5;
