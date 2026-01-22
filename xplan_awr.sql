set linesize 500
select * from table (dbms_xplan.display_awr('&sqlid'));
