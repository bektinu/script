select *
      from (select owner, table_name,
               round((blocks * 8), 2) "size (kb)",
               round((num_rows * avg_row_len / 1024), 2) "actual_data (kb)",
               (round((blocks * 8), 2) -
               round((num_rows * avg_row_len / 1024), 2)) "wasted_space (kb)"
          from dba_tables
         where (round((blocks * 8), 2) >
               round((num_rows * avg_row_len / 1024), 2))
         order by 4 desc)
where rownum <= 10;
