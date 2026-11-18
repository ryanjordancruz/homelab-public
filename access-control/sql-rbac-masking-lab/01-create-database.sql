/* =====================================================================
   RBAC + Data Masking Lab : Step 1 : Build the fake casino database
   ---------------------------------------------------------------------
   All data is FAKE:
     - SSNs use the 9xx area range, which the SSA never issues
     - Card numbers are public test numbers (4111..., 5555..., etc.)
   Run this whole file in SSMS (F5) while connected as your admin login.
   ===================================================================== */

USE master;
GO

-- Start clean if you re-run the lab
IF DB_ID('CasinoLab') IS NOT NULL
BEGIN
    ALTER DATABASE CasinoLab SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CasinoLab;
END
GO

CREATE DATABASE CasinoLab;
GO

USE CasinoLab;
GO

/* --- Guests: hotel + loyalty profile (PII lives here) --------------- */
CREATE TABLE dbo.Guests (
    GuestID      INT IDENTITY(1,1) PRIMARY KEY,
    FirstName    NVARCHAR(50)  NOT NULL,
    LastName     NVARCHAR(50)  NOT NULL,
    Email        NVARCHAR(100) NOT NULL,
    Phone        VARCHAR(20)   NOT NULL,
    SSN          CHAR(11)      NOT NULL,   -- needed for W-2G jackpot tax forms
    DateOfBirth  DATE          NOT NULL,
    LoyaltyTier  VARCHAR(10)   NOT NULL    -- Gold / Platinum / Black
);

/* --- Reservations: what the front desk works with ------------------- */
CREATE TABLE dbo.Reservations (
    ReservationID INT IDENTITY(1000,1) PRIMARY KEY,
    GuestID       INT  NOT NULL REFERENCES dbo.Guests(GuestID),
    RoomNumber    INT  NOT NULL,
    CheckIn       DATE NOT NULL,
    CheckOut      DATE NOT NULL,
    Status        VARCHAR(12) NOT NULL     -- Booked / CheckedIn / CheckedOut
);

/* --- Payments: cardholder data (PCI scope) --------------------------- */
CREATE TABLE dbo.Payments (
    PaymentID     INT IDENTITY(5000,1) PRIMARY KEY,
    GuestID       INT           NOT NULL REFERENCES dbo.Guests(GuestID),
    CardNumber    VARCHAR(19)   NOT NULL,
    Amount        DECIMAL(10,2) NOT NULL,
    PaidAt        DATETIME2     NOT NULL
);
GO

INSERT INTO dbo.Guests (FirstName, LastName, Email, Phone, SSN, DateOfBirth, LoyaltyTier) VALUES
 ('Maria',   'Lopez',    'maria.lopez@example.com',   '702-555-0101', '900-12-3456', '1985-03-14', 'Platinum'),
 ('James',   'Carter',   'jcarter@example.com',       '702-555-0102', '901-23-4567', '1972-11-02', 'Black'),
 ('Aiko',    'Tanaka',   'aiko.t@example.com',        '702-555-0103', '902-34-5678', '1990-07-21', 'Gold'),
 ('Derek',   'Nguyen',   'dnguyen@example.com',       '702-555-0104', '903-45-6789', '1968-01-30', 'Platinum'),
 ('Sofia',   'Romano',   'sofia.romano@example.com',  '702-555-0105', '904-56-7890', '1995-09-09', 'Gold'),
 ('Marcus',  'Bell',     'mbell@example.com',         '702-555-0106', '905-67-8901', '1980-05-17', 'Black'),
 ('Priya',   'Shah',     'priya.shah@example.com',    '702-555-0107', '906-78-9012', '1988-12-25', 'Platinum'),
 ('Tom',     'Becker',   'tbecker@example.com',       '702-555-0108', '907-89-0123', '1976-04-08', 'Gold');

INSERT INTO dbo.Reservations (GuestID, RoomNumber, CheckIn, CheckOut, Status) VALUES
 (1, 2104, '2026-11-20', '2026-11-23', 'Booked'),
 (2, 5801, '2026-11-01', '2026-11-05', 'CheckedIn'),
 (3, 1210, '2026-10-28', '2026-10-30', 'CheckedOut'),
 (4, 3307, '2026-11-02', '2026-11-04', 'CheckedIn'),
 (6, 6002, '2026-11-10', '2026-11-14', 'Booked'),
 (7, 2918, '2026-11-03', '2026-11-06', 'CheckedIn');

INSERT INTO dbo.Payments (GuestID, CardNumber, Amount, PaidAt) VALUES
 (1, '4111-1111-1111-1111',  1250.00, '2026-10-15 14:22'),
 (2, '5555-5555-5555-4444',  8900.00, '2026-11-01 16:05'),
 (3, '4012-8888-8888-1881',   480.50, '2026-10-30 11:40'),
 (4, '3782-822463-10005',    2210.00, '2026-11-02 15:10'),
 (6, '6011-1111-1111-1117',  3400.00, '2026-10-20 09:55'),
 (7, '4111-1111-1111-1111',  1675.25, '2026-11-03 13:30');
GO

-- Sanity check: you should see 8 / 6 / 6
SELECT 'Guests' AS TableName, COUNT(*) AS RowsLoaded FROM dbo.Guests
UNION ALL SELECT 'Reservations', COUNT(*) FROM dbo.Reservations
UNION ALL SELECT 'Payments',     COUNT(*) FROM dbo.Payments;
