SELECT 
    
    -- BANKER USERS
    SUM(
        CASE 
            WHEN username REGEXP '^[0-9]'
            THEN 1 
            ELSE 0 
        END
    ) AS banker_total_users,

    SUM(
        CASE 
            WHEN username REGEXP '^[0-9]'
                 AND disabled = FALSE
            THEN 1 
            ELSE 0 
        END
    ) AS banker_active_users,

    
    -- VENDOR USERS
    SUM(
        CASE 
            WHEN username REGEXP '^[A-Za-z]'
            THEN 1 
            ELSE 0 
        END
    ) AS vendor_total_users,

    SUM(
        CASE 
            WHEN username REGEXP '^[A-Za-z]'
                 AND disabled = FALSE
            THEN 1 
            ELSE 0 
        END
    ) AS vendor_active_users

FROM dbuser;