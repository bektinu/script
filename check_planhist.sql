select begin_interval_time, plan_hash_value
from dba_hist_sqlstat st,
        dba_hist_snapshot sn
where st.snap_id = sn.snap_id
and sql_id = '&sqlid'
order by begin_interval_time desc;
