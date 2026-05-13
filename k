SELECT 
    
    ROW_NUMBER() OVER (ORDER BY d.departmentName) AS "S.No",

    d.departmentName AS "Department Name",

    
    -- BANKER TOTAL USERS
    SUM(
        CASE 
            WHEN u.username REGEXP '^[0-9]'
            THEN 1
            ELSE 0
        END
    ) AS "Banker Total User",

    
    -- BANKER ACTIVE USERS
    SUM(
        CASE 
            WHEN u.username REGEXP '^[0-9]'
                 AND u.disabled = FALSE
            THEN 1
            ELSE 0
        END
    ) AS "Banker Active User",

    
    -- VENDOR TOTAL USERS
    SUM(
        CASE 
            WHEN u.username REGEXP '^[A-Za-z]'
            THEN 1
            ELSE 0
        END
    ) AS "Vendor Total User",

    
    -- VENDOR ACTIVE USERS
    SUM(
        CASE 
            WHEN u.username REGEXP '^[A-Za-z]'
                 AND u.disabled = FALSE
            THEN 1
            ELSE 0
        END
    ) AS "Vendor Active User"

FROM dbuser u

JOIN department d
    ON u.departmentCode = d.departmentCode

GROUP BY d.departmentName

ORDER BY d.departmentName;