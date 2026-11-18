USE CasinoLab;
SELECT DB_NAME() AS db, USER_NAME() AS [user]; -- expect: CasinoLab, dbo

-- ==== *CAUTION* RESET: drop users, then roles ====
DROP USER IF EXISTS fd_alice;
DROP USER IF EXISTS mkt_bob;
DROP USER IF EXISTS fin_carol;
DROP USER IF EXISTS aud_dave;

DROP ROLE IF EXISTS FrontDesk;
DROP ROLE IF EXISTS Marketing;
DROP ROLE IF EXISTS Finance;
DROP ROLE IF EXISTS SecurityAuditor;

-- ==== FRONT DESK ====
CREATE ROLE FrontDesk;
CREATE USER fd_alice WITHOUT LOGIN;
ALTER ROLE FrontDesk ADD MEMBER fd_alice;

GRANT SELECT ON dbo.Guests (GuestID, FirstName, LastName, LoyaltyTier, Phone) TO FrontDesk;
GRANT SELECT ON dbo.Reservations TO FrontDesk;
GRANT UPDATE ON dbo.Reservations (Status) TO FrontDesk;

-- ==== MARKETING ====
CREATE ROLE Marketing; 
CREATE USER mkt_bob WITHOUT LOGIN;
ALTER ROLE Marketing ADD MEMBER mkt_bob;

GRANT SELECT ON dbo.Guests (GuestID, FirstName, LastName, LoyaltyTier, Email) TO Marketing;

-- ==== FINANCE ====
CREATE ROLE Finance;
CREATE USER fin_carol WITHOUT LOGIN;
ALTER ROLE Finance ADD MEMBER fin_carol;

GRANT SELECT ON dbo.Payments (PaymentID, GuestID, Amount, PaidAt) TO Finance;

EXECUTE AS USER = 'fin_carol';
SELECT USER_NAME();
SELECT PaymentID, Amount FROM dbo.Payments;
-- EXPECTED: Msg 230 (no SELECT on CardNumber)
SELECT * FROM dbo.Payments;
REVERT;
SELECT USER_NAME();

-- ==== SECURITY AUDITOR ====
CREATE ROLE SecurityAuditor;
CREATE USER aud_dave WITHOUT LOGIN;
ALTER ROLE SecurityAuditor ADD MEMBER aud_dave;

GRANT VIEW SECURITY DEFINITION TO SecurityAuditor;

EXECUTE AS USER = 'aud_dave';
SELECT USER_NAME();

SELECT r.name AS role_name, m.name AS member_name
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id;

SELECT FirstName, SSN FROM dbo.Guests;

REVERT;
SELECT USER_NAME(),DB_NAME();