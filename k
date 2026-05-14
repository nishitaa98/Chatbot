SELECT 

    u.departmentCode,

    u.firstName,

    u.lastName,

    u.username,

    COUNT(a.username) AS login_count

FROM dbuser u

LEFT JOIN useractivity a
    ON u.username = a.username
    AND a.action = 'LOGIN'

GROUP BY 

    u.departmentCode,
    u.firstName,
    u.lastName,
    u.username

ORDER BY 

    u.departmentCode,
    login_count DESC;





SELECT 

    departmentCode,

    firstName,

    lastName,

    username,

    (
        SELECT COUNT(*)
        FROM useractivity ua
        WHERE ua.username = dbuser.username
          AND ua.action = 'LOGIN'
    ) AS login_count

FROM dbuser

ORDER BY departmentCode, login_count DESC;