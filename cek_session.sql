select inst_id, status,username, count (*) 
from gv$session 
where TYPE <> 'BACKGROUND'
group by inst_id,status, username
order by 1,2;
