select to_char(startup_time, 'HH24:MI:SS DD-MON-YY') "Startup time" , instance_name
from gv$instance;
