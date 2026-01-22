col column_name for a30
col index_name for a30
col column_position for 99
select index_name, column_name, column_position from dba_ind_columns where table_owner='&OWNER' and index_name='&IDXNAME';
