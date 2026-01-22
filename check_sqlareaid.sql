select fetches, executions, parse_calls, cpu_time, elapsed_time, disk_reads, buffer_gets, buffer_gets/executions
from v$sqlarea where sql_id='&sqlid';
