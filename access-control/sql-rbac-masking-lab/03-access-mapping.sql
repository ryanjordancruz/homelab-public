USE CasinoLab;

SELECT	m.name								AS user_name, 
		r.name								AS role_name,
		CASE WHEN r.is_fixed_role = 1 THEN 'ALL (fixed role)'
			ELSE p.permission_name END		AS permission,
		p.state_desc						AS state,
		OBJECT_NAME(p.major_id)				AS table_name,
		COL_NAME(p.major_id, p.minor_id)	AS column_name
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
LEFT JOIN sys.database_permissions p ON p.grantee_principal_id = r.principal_id
ORDER BY user_name, table_name, column_name;

