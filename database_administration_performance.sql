-- +----------------------------------------------------------------------------+
-- |                          Bekti Nugroho            		                    |
-- |                      bekti.nugroho@homecredit.co.id                        |
-- |                         DBA Enggineer		                                |
-- |----------------------------------------------------------------------------|
-- |      					Copyright (c) 2024.       							|		
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : database_admnistration_HCI_report.sql                                   |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : This SQL script provides a detailed report (in HTML format) on  |
-- |            all database metrics including installed options, storage,      |
-- |            performance data, and security.                                 |
-- | VERSION  : This script was designed for Oracle10g.                         |
-- | USAGE    :                                                                 |
-- |                                                                            |
--|sqlplus -s <dba>/<password>@<TNS string> @database_admnistration_HCI_report.sql |
-- |                                                                            |
-- | TESTING  : This script has been successfully tested on the following       |
-- |            platforms:                                                      |
-- |                                                                            |
-- |              Linux      : Oracle Database 10.2.0.3.0                       |
-- |              Linux      : Oracle RAC 10.2.0.3.0                            |
-- |              Linux      : Oracle Database 10.1.0.2.0                       |
-- |              Solaris    : Oracle Database 10.2.0.2.0                       |
-- |              Windows XP : Oracle Database 10.2.0.3.0                       |
-- |                                                                            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

define reportHeader="<font size=+3 color=darkgreen><b>Database Administration HCI Report <i>19c</i></b></font><hr>Copyright (c) 2024 Bekti Nugroho. All rights reserved. (<a target=""_blank"" href=""http://www.bektinugroho.info"">www.bektinugroho.i
nfo</a>)<p>"


-- +----------------------------------------------------------------------------+
-- |                           SCRIPT SETTINGS                                  |
-- +----------------------------------------------------------------------------+

set termout       off
set echo          off
set feedback      off
set heading       off
set verify        off
set wrap          on
set trimspool     on
set serveroutput  on
set escape        on

set pagesize 50000
set linesize 175
set long     2000000000

clear buffer computes columns breaks screen

define fileName=database_admnistration_HCI_report
define versionNumber=4.7


-- +----------------------------------------------------------------------------+
-- |                   GATHER DATABASE REPORT INFORMATION                       |
-- +----------------------------------------------------------------------------+

COLUMN tdate NEW_VALUE _date NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY') tdate FROM dual;

COLUMN time NEW_VALUE _time NOPRINT
SELECT TO_CHAR(SYSDATE,'HH24:MI:SS') time FROM dual;

COLUMN date_time NEW_VALUE _date_time NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS') date_time FROM dual;

COLUMN date_time_timezone NEW_VALUE _date_time_timezone NOPRINT
SELECT TO_CHAR(systimestamp, 'Mon DD, YYYY (') || TRIM(TO_CHAR(systimestamp, 'Day')) || TO_CHAR(systimestamp, ') "at" HH:MI:SS AM') || TO_CHAR(systimestamp, ' "in Timezone" TZR') date_time_timezone
FROM dual;

COLUMN spool_time NEW_VALUE _spool_time NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD') spool_time FROM dual;

COLUMN dbname NEW_VALUE _dbname NOPRINT
SELECT name dbname FROM v$database;

COLUMN dbid NEW_VALUE _dbid NOPRINT
SELECT dbid dbid FROM v$database;

COLUMN platform_id NEW_VALUE _platform_id NOPRINT
SELECT platform_id platform_id FROM v$database;

COLUMN platform_name NEW_VALUE _platform_name NOPRINT
SELECT platform_name platform_name FROM v$database;

COLUMN global_name NEW_VALUE _global_name NOPRINT
SELECT global_name global_name FROM global_name;

COLUMN blocksize NEW_VALUE _blocksize NOPRINT
SELECT value blocksize FROM v$parameter WHERE name='db_block_size';

COLUMN startup_time NEW_VALUE _startup_time NOPRINT
SELECT TO_CHAR(startup_time, 'MM/DD/YYYY HH24:MI:SS') startup_time FROM v$instance;

COLUMN host_name NEW_VALUE _host_name NOPRINT
SELECT host_name host_name FROM v$instance;

COLUMN instance_name NEW_VALUE _instance_name NOPRINT
SELECT instance_name instance_name FROM v$instance;

COLUMN instance_number NEW_VALUE _instance_number NOPRINT
SELECT instance_number instance_number FROM v$instance;

COLUMN thread_number NEW_VALUE _thread_number NOPRINT
SELECT thread# thread_number FROM v$instance;

COLUMN cluster_database NEW_VALUE _cluster_database NOPRINT
SELECT value cluster_database FROM v$parameter WHERE name='cluster_database';

COLUMN cluster_database_instances NEW_VALUE _cluster_database_instances NOPRINT
SELECT value cluster_database_instances FROM v$parameter WHERE name='cluster_database_instances';

COLUMN reportRunUser NEW_VALUE _reportRunUser NOPRINT
SELECT user reportRunUser FROM dual;



-- +----------------------------------------------------------------------------+
-- |                   GATHER DATABASE REPORT INFORMATION                       |
-- +----------------------------------------------------------------------------+

set heading on

set markup html on spool on preformat off entmap on -
head ' -
  <title>Database Report</title> -
  <style type="text/css"> -
    body              {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    p                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    table,tr,td       {font:9pt Arial,Helvetica,sans-serif; color:Black; background:#C0C0C0; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;} -
    th                {font:bold 9pt Arial,Helvetica,sans-serif; color:#336699; background:#cccc99; padding:0px 0px 0px 0px;} -
    h1                {font:bold 12pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} -
    h2                {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;} -
    a                 {font:9pt Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.link            {font:9pt Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLink          {font:9pt Arial,Helvetica,sans-serif; color:#663300; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkBlue      {font:9pt Arial,Helvetica,sans-serif; color:#0000ff; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkBlue  {font:9pt Arial,Helvetica,sans-serif; color:#000099; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkRed       {font:9pt Arial,Helvetica,sans-serif; color:#ff0000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkRed   {font:9pt Arial,Helvetica,sans-serif; color:#990000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkGreen     {font:9pt Arial,Helvetica,sans-serif; color:#00ff00; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkGreen {font:9pt Arial,Helvetica,sans-serif; color:#009900; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
  </style>' -
body   'BGCOLOR="#C0C0C0"' -
table  'WIDTH="90%" BORDER="1"' 

spool &FileName._&_dbname._&_spool_time..html

set markup html on entmap off


-- +----------------------------------------------------------------------------+
-- |                             - REPORT HEADER -                              |
-- +----------------------------------------------------------------------------+

prompt <a name=top></a>
prompt &reportHeader








-- +============================================================================+
-- |                                                                            |
-- |        <<<<<     Database and Instance Information    >>>>>                |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Database and Instance Information</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                            - REPORT HEADER -                               |
-- +----------------------------------------------------------------------------+

prompt 
prompt <a name="report_header"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Report Header</b></font><hr align="left" width="460">

prompt <table width="90%" border="1"> -
<tr><th align="left" width="20%">Report Name</th><td width="80%"><tt>&FileName._&_dbname._&_spool_time..html</tt></td></tr> -
<tr><th align="left" width="20%">Snapshot Database Version</th><td width="80%"><tt>&versionNumber</tt></td></tr> -
<tr><th align="left" width="20%">Run Date / Time / Timezone</th><td width="80%"><tt>&_date_time_timezone</tt></td></tr> -
<tr><th align="left" width="20%">Host Name</th><td width="80%"><tt>&_host_name</tt></td></tr> -
<tr><th align="left" width="20%">Database Name</th><td width="80%"><tt>&_dbname</tt></td></tr> -
<tr><th align="left" width="20%">Database ID</th><td width="80%"><tt>&_dbid</tt></td></tr> -
<tr><th align="left" width="20%">Global Database Name</th><td width="80%"><tt>&_global_name</tt></td></tr> -
<tr><th align="left" width="20%">Platform Name / ID</th><td width="80%"><tt>&_platform_name / &_platform_id</tt></td></tr> -
<tr><th align="left" width="20%">Clustered Database?</th><td width="80%"><tt>&_cluster_database</tt></td></tr> -
<tr><th align="left" width="20%">Clustered Database Instances</th><td width="80%"><tt>&_cluster_database_instances</tt></td></tr> -
<tr><th align="left" width="20%">Instance Name</th><td width="80%"><tt>&_instance_name</tt></td></tr> -
<tr><th align="left" width="20%">Instance Number</th><td width="80%"><tt>&_instance_number</tt></td></tr> -
<tr><th align="left" width="20%">Thread Number</th><td width="80%"><tt>&_thread_number</tt></td></tr> -
<tr><th align="left" width="20%">Database Startup Time</th><td width="80%"><tt>&_startup_time</tt></td></tr> -
<tr><th align="left" width="20%">Database Block Size</th><td width="80%"><tt>&_blocksize</tt></td></tr> -
<tr><th align="left" width="20%">Report Run User</th><td width="80%"><tt>&_reportRunUser</tt></td></tr> -
</table>

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- SET TIMING ON




-- +----------------------------------------------------------------------------+
-- |                                 - VERSION -                                |
-- +----------------------------------------------------------------------------+

prompt <a name="version"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Version</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN banner   FORMAT a120   HEADING 'Banner'

SELECT * FROM v$version;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +----------------------------------------------------------------------------+
-- |                           - INSTANCE OVERVIEW -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="instance_overview"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Instance Overview</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print       FORMAT a75    HEADING 'Instance|Name'       ENTMAP off
COLUMN instance_number_print     FORMAT a75    HEADING 'Instance|Num'        ENTMAP off
COLUMN thread_number_print                     HEADING 'Thread|Num'          ENTMAP off
COLUMN host_name_print           FORMAT a75    HEADING 'Host|Name'           ENTMAP off
COLUMN version                                 HEADING 'Oracle|Version'      ENTMAP off
COLUMN start_time                FORMAT a75    HEADING 'Start|Time'          ENTMAP off
COLUMN uptime                                  HEADING 'Uptime|(in days)'    ENTMAP off
COLUMN parallel                  FORMAT a75    HEADING 'Parallel - (RAC)'    ENTMAP off
COLUMN instance_status           FORMAT a75    HEADING 'Instance|Status'     ENTMAP off
COLUMN database_status           FORMAT a75    HEADING 'Database|Status'     ENTMAP off
COLUMN logins                    FORMAT a75    HEADING 'Logins'              ENTMAP off
COLUMN archiver                  FORMAT a75    HEADING 'Archiver'            ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || instance_name || '</b></font></div>'         instance_name_print
  , '<div align="center">' || instance_number || '</div>'                                           instance_number_print
  , '<div align="center">' || thread#         || '</div>'                                           thread_number_print
  , '<div align="center">' || host_name       || '</div>'                                           host_name_print
  , '<div align="center">' || version         || '</div>'                                           version
  , '<div align="center">' || TO_CHAR(startup_time,'mm/dd/yyyy HH24:MI:SS') || '</div>'             start_time
  , ROUND(TO_CHAR(SYSDATE-startup_time), 2)                                                         uptime
  , '<div align="center">' || parallel        || '</div>'                                           parallel
  , '<div align="center">' || status          || '</div>'                                           instance_status
  , '<div align="center">' || logins          || '</div>'                                           logins
  , DECODE(   archiver
            , 'FAILED'
            , '<div align="center"><b><font color="#990000">'   || archiver || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || archiver || '</font></b></div>') archiver
FROM gv$instance
ORDER BY instance_number;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - DATABASE OVERVIEW -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="database_overview"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Overview</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                            FORMAT a75     HEADING 'Database|Name'              ENTMAP off
COLUMN dbid                                           HEADING 'Database|ID'                ENTMAP off
COLUMN db_unique_name                                 HEADING 'Database|Unique Name'       ENTMAP off
COLUMN creation_date                                  HEADING 'Creation|Date'              ENTMAP off
COLUMN platform_name_print                            HEADING 'Platform|Name'              ENTMAP off
COLUMN current_scn                                    HEADING 'Current|SCN'                ENTMAP off
COLUMN log_mode                                       HEADING 'Log|Mode'                   ENTMAP off
COLUMN open_mode                                      HEADING 'Open|Mode'                  ENTMAP off
COLUMN force_logging                                  HEADING 'Force|Logging'              ENTMAP off
COLUMN flashback_on                                   HEADING 'Flashback|On?'              ENTMAP off
COLUMN controlfile_type                               HEADING 'Controlfile|Type'           ENTMAP off
COLUMN last_open_incarnation_number                   HEADING 'Last Open|Incarnation Num'  ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>'  || name  || '</b></font></div>'          name
  , '<div align="center">' || dbid                   || '</div>'                              dbid
  , '<div align="center">' || db_unique_name         || '</div>'                              db_unique_name
  , '<div align="center">' || TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS') || '</div>'           creation_date
  , '<div align="center">' || platform_name          || '</div>'                              platform_name_print
  , '<div align="center">' || current_scn            || '</div>'                              current_scn
  , '<div align="center">' || log_mode               || '</div>'                              log_mode
  , '<div align="center">' || open_mode              || '</div>'                              open_mode
  , '<div align="center">' || force_logging          || '</div>'                              force_logging
  , '<div align="center">' || flashback_on           || '</div>'                              flashback_on
  , '<div align="center">' || controlfile_type       || '</div>'                              controlfile_type
  , '<div align="center">' || last_open_incarnation# || '</div>'                              last_open_incarnation_number
FROM v$database;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>







-- +============================================================================+
-- |                                                                            |
-- |                      <<<<<     STORAGE    >>>>>                            |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Storage</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                            - TABLESPACES -                                 |
-- +----------------------------------------------------------------------------+

prompt <a name="tablespaces"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tablespaces</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN status                                  HEADING 'Status'            ENTMAP off
COLUMN name                                    HEADING 'Tablespace Name'   ENTMAP off
COLUMN type        FORMAT a12                  HEADING 'TS Type'           ENTMAP off
COLUMN extent_mgt  FORMAT a10                  HEADING 'Ext. Mgt.'         ENTMAP off
COLUMN segment_mgt FORMAT a9                   HEADING 'Seg. Mgt.'         ENTMAP off
COLUMN ts_size     FORMAT 999,999,999,999,999  HEADING 'Tablespace Size'   ENTMAP off
COLUMN free        FORMAT 999,999,999,999,999  HEADING 'Free (in bytes)'   ENTMAP off
COLUMN used        FORMAT 999,999,999,999,999  HEADING 'Used (in bytes)'   ENTMAP off
COLUMN pct_used                                HEADING 'Pct. Used'         ENTMAP off

BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>'   OF ts_size used free ON report

SELECT
    DECODE(   d.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || d.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>') status
  , '<b><font color="#336699">' || d.tablespace_name || '</font></b>'                               name
  , d.contents                                          type
  , d.extent_management                                 extent_mgt
  , d.segment_space_management                          segment_mgt
  , NVL(a.bytes, 0)                                     ts_size
  , NVL(f.bytes, 0)                                     free
  , NVL(a.bytes - NVL(f.bytes, 0), 0)                   used
  , '<div align="right"><b>' || 
          DECODE (
              (1-SIGN(1-SIGN(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0)) - 90)))
            , 1
            , '<font color="#990000">'   || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>'
            , '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>'
          )
    || '</b> %</div>' pct_used
FROM 
    sys.dba_tablespaces d
  , ( select tablespace_name, sum(bytes) bytes
      from dba_data_files
      group by tablespace_name
    ) a
  , ( select tablespace_name, sum(bytes) bytes
      from dba_free_space
      group by tablespace_name
    ) f
WHERE
      d.tablespace_name = a.tablespace_name(+)
  AND d.tablespace_name = f.tablespace_name(+)
  AND NOT (
    d.extent_management like 'LOCAL'
    AND
    d.contents like 'TEMPORARY'
  )
UNION ALL 
SELECT
    DECODE(   d.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || d.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>') status
  , '<b><font color="#336699">' || d.tablespace_name  || '</font></b>'                              name
  , d.contents                                   type
  , d.extent_management                          extent_mgt
  , d.segment_space_management                   segment_mgt
  , NVL(a.bytes, 0)                              ts_size
  , NVL(a.bytes - NVL(t.bytes,0), 0)             free
  , NVL(t.bytes, 0)                              used
  , '<div align="right"><b>' || 
          DECODE (
              (1-SIGN(1-SIGN(TRUNC(NVL(t.bytes / a.bytes * 100, 0)) - 90)))
            , 1
            , '<font color="#990000">'   || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>'
            , '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>'
          )
    || '</b> %</div>' pct_used
FROM
    sys.dba_tablespaces d
  , ( select tablespace_name, sum(bytes) bytes
      from dba_temp_files
      group by tablespace_name
    ) a
  , ( select tablespace_name, sum(bytes_cached) bytes
      from v$temp_extent_pool
      group by tablespace_name
    ) t
WHERE
      d.tablespace_name = a.tablespace_name(+)
  AND d.tablespace_name = t.tablespace_name(+)
  AND d.extent_management like 'LOCAL'
  AND d.contents like 'TEMPORARY'
ORDER BY 2;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>







-- +============================================================================+
-- |                                                                            |
-- |                    <<<<<     PERFORMANCE     >>>>>                         |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Performance</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                             - SGA INFORMATION -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="sga_information"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SGA Information</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name FORMAT a79                 HEADING 'Instance Name'    ENTMAP off
COLUMN name          FORMAT a150                HEADING 'Pool Name'        ENTMAP off
COLUMN value         FORMAT 999,999,999,999,999 HEADING 'Bytes'            ENTMAP off

BREAK ON report ON instance_name
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF value ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , '<div align="left"><font color="#336699"><b>' || s.name          || '</b></font></div>'  name
  , s.value                                                                                  value
FROM
    gv$sga       s
  , gv$instance  i
WHERE
    s.inst_id = i.inst_id
ORDER BY
    i.instance_name
  , s.value DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - PGA TARGET ADVICE -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="pga_target_advice"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>PGA Target Advice</b></font><hr align="left" width="460">

/*prompt The <b>V$PGA_TARGET_ADVICE</b> view predicts how the statistics cache hit percentage and over
prompt allocation count in V$PGASTAT will be impacted if you change the value of the
prompt initialization parameter PGA_AGGREGATE_TARGET. When you set the PGA_AGGREGATE_TARGET and
prompt WORKAREA_SIZE_POLICY to <b>AUTO</b> then the *_AREA_SIZE parameter are automatically ignored and
prompt Oracle will automatically use the computed value for these parameters. Use the results from
prompt the query below to adequately set the initialization parameter PGA_AGGREGATE_TARGET as to avoid
prompt any over allocation. If column ESTD_OVERALLOCATION_COUNT in the V$PGA_TARGET_ADVICE
prompt view (below) is nonzero, it indicates that PGA_AGGREGATE_TARGET is too small to even
prompt meet the minimum PGA memory needs. If PGA_AGGREGATE_TARGET is set within the over
prompt allocation zone, the memory manager will over-allocate memory and actual PGA memory
prompt consumed will be more than the limit you set. It is therefore meaningless to set a
prompt value of PGA_AGGREGATE_TARGET in that zone. After eliminating over-allocations, the
prompt goal is to maximize the PGA cache hit percentage, based on your response-time requirement
prompt and memory constraints. */

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name FORMAT a79     HEADING 'Instance Name'    ENTMAP off
COLUMN name          FORMAT a79     HEADING 'Parameter Name'   ENTMAP off
COLUMN value         FORMAT a79     HEADING 'Value'            ENTMAP off

BREAK ON report ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , p.name    name
  , (CASE p.name
         WHEN 'pga_aggregate_target' THEN '<div align="right">' || TO_CHAR(p.value, '999,999,999,999,999') || '</div>'
     ELSE
         '<div align="right">' || p.value || '</div>'
     END) value
FROM
    gv$parameter p
  , gv$instance  i
WHERE
      p.inst_id = i.inst_id
  AND p.name IN ('pga_aggregate_target', 'workarea_size_policy')
ORDER BY
    i.instance_name
  , p.name;



CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name                  FORMAT a79                   HEADING 'Instance Name'               ENTMAP off
COLUMN pga_target_for_estimate        FORMAT 999,999,999,999,999   HEADING 'PGA Target for Estimate'     ENTMAP off
COLUMN estd_extra_bytes_rw            FORMAT 999,999,999,999,999   HEADING 'Estimated Extra Bytes R/W'   ENTMAP off
COLUMN estd_pga_cache_hit_percentage  FORMAT 999,999,999,999,999   HEADING 'Estimated PGA Cache Hit %'   ENTMAP off
COLUMN estd_overalloc_count           FORMAT 999,999,999,999,999   HEADING 'ESTD_OVERALLOC_COUNT'        ENTMAP off

BREAK ON report ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , p.pga_target_for_estimate
  , p.estd_extra_bytes_rw
  , p.estd_pga_cache_hit_percentage
  , p.estd_overalloc_count
FROM
    gv$pga_target_advice p
  , gv$instance  i
WHERE
    p.inst_id = i.inst_id
ORDER BY
    i.instance_name
  , p.pga_target_for_estimate;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>





-- +----------------------------------------------------------------------------+
-- |                - SQL STATEMENTS WITH MOST BUFFER GETS -                    |
-- +----------------------------------------------------------------------------+

prompt <a name="sql_statements_with_most_buffer_gets"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SQL Statements With Most Buffer Gets</b></font><hr align="left" width="460">

prompt <b>Top 100 SQL statements with buffer gets greater than 1000</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN username        FORMAT a75                   HEADING 'Username'                 ENTMAP off
COLUMN buffer_gets     FORMAT 999,999,999,999,999   HEADING 'Buffer Gets'              ENTMAP off
COLUMN executions      FORMAT 999,999,999,999,999   HEADING 'Executions'               ENTMAP off
COLUMN gets_per_exec   FORMAT 999,999,999,999,999   HEADING 'Buffer Gets / Execution'  ENTMAP off
COLUMN sql_text                                     HEADING 'SQL Text'                 ENTMAP off

SELECT 
    '<font color="#336699"><b>' || UPPER(b.username) || '</b></font>' username
  , a.buffer_gets              buffer_gets
  , a.executions               executions
  , (a.buffer_gets / decode(a.executions, 0, 1, a.executions))  gets_per_exec
  , a.sql_text                 sql_text
FROM 
    (SELECT ai.buffer_gets, ai.executions, ai.sql_text, ai.parsing_user_id
     FROM sys.v_$sqlarea ai
     ORDER BY ai.buffer_gets
    ) a
  , dba_users b
WHERE
      a.parsing_user_id = b.user_id 
  AND a.buffer_gets > 1000
  AND b.username NOT IN ('SYS','SYSTEM')
  AND rownum < 101
ORDER BY
    a.buffer_gets DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                 - SQL STATEMENTS WITH MOST DISK READS -                    |
-- +----------------------------------------------------------------------------+

prompt <a name="sql_statements_with_most_disk_reads"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SQL Statements With Most Disk Reads</b></font><hr align="left" width="460">

prompt <b>Top 100 SQL statements with disk reads greater than 1000</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN username        FORMAT a75                   HEADING 'Username'           ENTMAP off
COLUMN disk_reads      FORMAT 999,999,999,999,999   HEADING 'Disk Reads'         ENTMAP off
COLUMN executions      FORMAT 999,999,999,999,999   HEADING 'Executions'         ENTMAP off
COLUMN reads_per_exec  FORMAT 999,999,999,999,999   HEADING 'Reads / Execution'  ENTMAP off
COLUMN sql_text                                     HEADING 'SQL Text'           ENTMAP off

SELECT 
    '<font color="#336699"><b>' || UPPER(b.username) || '</b></font>' username
  , a.disk_reads       disk_reads
  , a.executions       executions
  , (a.disk_reads / decode(a.executions, 0, 1, a.executions))  reads_per_exec
  , a.sql_text         sql_text
FROM 
    (SELECT ai.disk_reads, ai.executions, ai.sql_text, ai.parsing_user_id
     FROM sys.v_$sqlarea ai
     ORDER BY ai.buffer_gets
    ) a
  , dba_users b
WHERE
      a.parsing_user_id = b.user_id 
  AND a.disk_reads > 1000
  AND b.username NOT IN ('SYS','SYSTEM')
  AND rownum < 101
ORDER BY
    a.disk_reads DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>











-- +----------------------------------------------------------------------------+
-- |                            - END OF REPORT -                               |
-- +----------------------------------------------------------------------------+

SPOOL OFF

SET MARKUP HTML OFF

SET TERMOUT ON

prompt 
prompt Output written to: &FileName._&_dbname._&_spool_time..html

EXIT;
