select inst_id, status,username, count (*), machine 
from gv$session 
where TYPE <> 'BACKGROUND'
group by inst_id,status, username,machine
order by 1,2;
