SELECT 

    d.departmentCode,

    u.firstName,

    u.lastName,

    u.username,

    COUNT(a.username) AS login_count

FROM dbuser u

LEFT JOIN useractivity a
    ON u.username = a.username
    AND a.action = 'LOGIN'

LEFT JOIN department d
    ON u.departmentCode = d.departmentCode

GROUP BY 

    d.departmentCode,
    u.firstName,
    u.lastName,
    u.username

ORDER BY 

    d.departmentCode,
    login_count DESC;