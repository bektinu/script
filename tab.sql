/*
	tab.sql by Randy P. Joeandy Oracle RTB BMI
	Desc  : To show detail of table
	Usage : tab.sql {TABLE_NAME}
	Dependency index.sql & lob.sql
*/

prompt ===========================================================================Table Details===========================================================================
set lines 190 pages 1000
col owner for a18
col table_name for a25
col tablespace_name for a26
col part_key_col for a50
col position for a5
col sizemb for 999g999g999
col status for a8
col last_analyzed for a12
set feed off verify off
col degree for a5
col p_cnt for a5

break on report
compute sum of sizemb on report

select a.owner, a.table_name,nvl(a.tablespace_name,b.tablespace_name) tablespace_name, status, partitioned, last_analyzed , degree , nvl(part_key_col,'-') part_key_col, decode(count(partition_name),0,'-',count(partition_name)) p_cnt,sum(bytes/1024/1024) sizemb from
(
select a.owner, a.table_name,partitioned,status,decode(last_analyzed,'','-',last_analyzed) last_analyzed,degree,tablespace_name, 
listagg(column_name,',') within group (order by column_position) part_key_col
from dba_tables a, DBA_PART_KEY_COLUMNS b where a.table_name=b.name(+) and a.table_name = upper('&1') and a.owner=b.owner(+)
group by a.owner, a.table_name, status,decode(last_analyzed,'','-',last_analyzed) ,degree,tablespace_name,partitioned
) a , dba_segments b where a.owner=b.owner(+) and a.table_name = b.segment_name(+) group by a.owner, a.table_name,nvl(a.tablespace_name,b.tablespace_name), status, partitioned, last_analyzed , degree , nvl(part_key_col,'-');
prompt
prompt ===========================================================================Index Details===========================================================================
@/opt/dba/scripts/SqlScript/index.sql &&1
prompt
prompt ============================================================================Lob Details============================================================================
@/opt/dba/scripts/SqlScript/lob.sql &&1
