select inst_id,username, status,machine,sql_id, count (*) 
from gv$session 
where TYPE <> 'BACKGROUND'
group by inst_id,username, status, machine,sql_id
order by 1,3,6,2;
