SELECT 
    s.sql_id,
    s.plan_hash_value,
    q.sql_text
FROM 
    dba_hist_sqlstat s
JOIN 
    dba_hist_sqltext q ON s.sql_id = q.sql_id
WHERE 
    s.plan_hash_value = 3355210169;
