select index_name, column_name, column_position from dba_ind_columns where table_owner='&OWNER' and table_name='&TNAME' and column_name='&COLNAME';
