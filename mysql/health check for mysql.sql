health check for mysql

1. Confirm MySQL Service Is Healthy and Stable
SELECT NOW(), VERSION();


From the command line:

mysqladmin -u root -p ping
mysqladmin -u root -p status

2. Review MySQL Error Logs
SHOW VARIABLES LIKE 'log_error';

Open the log file and scan recent entries for:
ERROR
InnoDB warnings
Table corruption messages
Repeated restart logs

3. Check Disk Space and Data Directory Health
Disk issues are still one of the top causes of database downtime.
SHOW VARIABLES LIKE 'datadir';

4. Look for Long-Running Transactions
Long transactions block cleanup and slowly degrade performance.
  SELECT trx_id,
       trx_started,
       TIMESTAMPDIFF(SECOND, trx_started, NOW()) AS age_seconds,
       trx_state,
       trx_mysql_thread_id
FROM INFORMATION_SCHEMA.INNODB_TRX
ORDER BY age_seconds DESC;
What to watch for:
Transactions running longer than expected for your workload (often > 5–10 minutes).

5. Review Slow Queries (Top Performance Killers)
Slow queries rarely fix themselves.

SHOW VARIABLES LIKE 'slow_query_log';
SHOW VARIABLES LIKE 'long_query_time';
If slow queries are logged to a table:

SELECT sql_text,
       COUNT(*) AS executions,
       AVG(query_time) AS avg_time
FROM mysql.slow_log
GROUP BY sql_text
ORDER BY avg_time DESC
LIMIT 10;
Weekly habit:
Fix at least one slow query every week.

6. Check Table and Index Health
Indexes and table structure matter more as data grows.

SELECT TABLE_SCHEMA,
       TABLE_NAME,
       ENGINE,
       TABLE_ROWS,
       DATA_LENGTH,
       INDEX_LENGTH
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA NOT IN ('mysql','performance_schema','sys')
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC
LIMIT 20;
For suspicious tables:

CHECK TABLE dbname.table_name;
ANALYZE TABLE dbname.table_name;
Why it matters:
Large, poorly indexed tables are common performance bottlenecks.

7. Verify Binary Logs and Backup Readiness
Binary logs are critical for recovery — but only if managed properly.

SHOW BINARY LOGS;
SHOW MASTER STATUS;
SHOW VARIABLES LIKE 'expire_logs_days';
What to confirm:

Binlogs exist
Retention matches your recovery needs
Recent backups completed successfully

8. Check Replication Health (If Used)
Replication failures often go unnoticed until a failover is needed.

SHOW SLAVE STATUS\G
(or SHOW REPLICA STATUS\G on newer versions)

Watch for:

Seconds_Behind_Master growing
Last_SQL_Error not empty
IO or SQL threads not running

9. Monitor Connections, Threads, and InnoDB Buffer Pool
Resource pressure shows up here first.

SHOW GLOBAL STATUS LIKE 'Threads_connected';
SHOW GLOBAL STATUS LIKE 'Threads_running';
SHOW GLOBAL STATUS LIKE 'Connections';
SHOW GLOBAL STATUS LIKE 'Threads_created';
Buffer pool insight:

SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool%';
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
Red flags:
Sudden spikes in connections or thread creation usually indicate application issues.
  


10. Review Users and Privileges
Security problems often start with forgotten accounts.

SELECT user, host
FROM mysql.user
WHERE user = '';
Check privileged users:

SELECT user, host
FROM mysql.user
WHERE Grant_priv = 'Y'
   OR Super_priv = 'Y';
Best practice:
Remove unused users, restrict root access, and apply least privilege.

