USE CasinoLab;
SELECT DB_NAME() AS CurrentDB, USER_NAME() as CurrentUser;

ALTER TABLE dbo.Payments
ALTER COLUMN CardNumber
ADD MASKED WITH (FUNCTION = 'partial(0, "XXXX-XXXX-XXXX-", 4)');

SELECT OBJECT_NAME(object_id) AS TableName, name AS ColumnName, masking_function
FROM sys.masked_columns;

-- Payment Disputes: full SELECT on Payments, but CardNumber is masked
DROP USER IF EXISTS pd_erin;
DROP ROLE IF EXISTS PaymentDisputes;

CREATE ROLE PaymentDisputes;
CREATE USER pd_erin WITHOUT LOGIN;
ALTER ROLE PaymentDisputes ADD MEMBER pd_erin;
GRANT SELECT ON dbo.Payments TO PaymentDisputes; -- whole table: no column list

EXECUTE AS USER = 'pd_erin';
SELECT PaymentID, CardNumber, Amount FROM dbo.Payments;
REVERT;

EXECUTE AS USER = 'pd_erin';
SELECT PaymentID, CardNumber FROM dbo.Payments
WHERE CardNumber LIKE '4111%';
REVERT;

GO
CREATE OR ALTER VIEW dbo.vw_PaymentsLast4 AS
SELECT PaymentID, GuestID, Amount, PaidAt,
		RIGHT (CardNumber, 4) AS CardLast4
FROM dbo.Payments;
GO

GRANT SELECT ON dbo.vw_PaymentsLast4 TO Finance;

EXECUTE AS USER = 'fin_carol';
SELECT * FROM dbo.vw_PaymentsLast4;
REVERT;

GRANT UNMASK ON dbo.Payments(CardNumber) TO Finance;