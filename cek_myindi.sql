!date
set timing on
select count(*)"JML", username,machine,status,inst_id from gv$session 
where 
username like 'MYINDIHOME%'
group by username,machine,status,inst_id order by 5,4;

select count(*)"JML", username,machine,status,inst_id from gv$session
where
username like 'MYINDIHOME%' and machine like 'myindihom%'
group by username,machine,status,inst_id order by 5,4;
