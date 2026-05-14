SELECT 

    d.departmentCode,

    u.username,

    CONCAT(u.firstName, ' ', u.lastName) AS full_name,

    COUNT(l.username) AS login_count

FROM dbuser u

LEFT JOIN loginattempt l
    ON u.username = l.username
    AND l.success = TRUE

LEFT JOIN department d
    ON u.departmentCode = d.departmentCode

GROUP BY 
    d.departmentCode,
    u.username,
    u.firstName,
    u.lastName

ORDER BY 
    d.departmentCode,
    login_count DESC;