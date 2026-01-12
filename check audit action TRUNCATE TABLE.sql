SELECT 
    username, 
    action_name, 
    obj_name, 
    timestamp, 
    sql_text 
FROM 
    dba_audit_trail 
WHERE 
    action_name = 'TRUNCATE TABLE'
ORDER BY 
    timestamp DESC;

    SELECT 
    USERNAME,
    ACTION_NAME,
    OBJ_NAME,
    TIMESTAMP,
    SQL_TEXT
FROM DBA_AUDIT_TRAIL
WHERE 
    ACTION_NAME = 'TRUNCATE TABLE'
    AND USERNAME = 'APP_JFS'
    AND OBJ_NAME IN (
        'LG_DATA_BATCH_STATUS',
        'DPD_CONTRACT_ACTIVE',
        'ST_FIDUCIARY_CONTRACT',
        'MS_TOWN',
        'MS_SUBDISTRICT'
    )
ORDER BY TIMESTAMP DESC;
