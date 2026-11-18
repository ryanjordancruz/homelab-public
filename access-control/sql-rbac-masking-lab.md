# RBAC + Data Masking: Who Can See the Card Number? (SQL Server)

## Summary

| Field | Details |
|-------|---------|
| Dates | 2026-11-03 to 2026-11-18 |
| Platform | SQL Server 2025 Developer, SSMS 21 (local Windows PC) |
| Scenario | Fake casino database: Guests (SSN, date of birth), Reservations, Payments (card numbers) |
| Data | All fake: SSNs in the never-issued 9xx range, public test card numbers (4111..., 5555...) |
| Built | 5 roles with least-privilege grants, an access-mapping audit query, Dynamic Data Masking, a last-4 view |
| Key findings | 1) The access map hid db_owner. 2) Masking can be bypassed with a WHERE clause. 3) My mask broke my own view. |

I built role-based access for four casino departments, audited who could see what, then tested Dynamic Data Masking to find out whether it actually protects data. It doesn't, on its own: a user who can see `XXXX-XXXX-XXXX-1111` can still recover the full card number with yes/no queries. The fix was a view that only ever returns the last 4 digits.

The sample database script (`01`) was scaffolded for me. I wrote the roles, grants, access-mapping query, masking, and view myself.

Scripts: [`sql-rbac-masking-lab/`](sql-rbac-masking-lab/)

---

## Step 1: The Database

Three tables, with the sensitive columns marked:

| Table | Sensitive columns |
|-------|-------------------|
| `Guests` | `SSN` (needed for W-2G jackpot tax forms), `DateOfBirth`, `Email`, `Phone` |
| `Reservations` | none |
| `Payments` | `CardNumber` |

---

## Step 2: Roles (Least Privilege)

Each department gets a role, and each role gets only the columns it needs. Test users are created `WITHOUT LOGIN` and tested with `EXECUTE AS`, which lets an admin run queries as that user.

| Role | Test user | Access |
|------|-----------|--------|
| FrontDesk | `fd_alice` | Guests: name, loyalty tier, phone. Reservations: read, and update `Status` only |
| Marketing | `mkt_bob` | Guests: name, loyalty tier, email |
| Finance | `fin_carol` | Payments: everything except `CardNumber` |
| SecurityAuditor | `aud_dave` | `VIEW SECURITY DEFINITION` (can read permissions, not data) |

```sql
CREATE ROLE Finance;
CREATE USER fin_carol WITHOUT LOGIN;
ALTER ROLE Finance ADD MEMBER fin_carol;

GRANT SELECT ON dbo.Payments (PaymentID, GuestID, Amount, PaidAt) TO Finance;
```

Testing it:

```sql
EXECUTE AS USER = 'fin_carol';
SELECT PaymentID, Amount FROM dbo.Payments;   -- works: 6 rows
SELECT * FROM dbo.Payments;                   -- Msg 230: denied on CardNumber
REVERT;
```

Two different errors told me two different things:
- **Msg 229**: no permission on the whole object (the auditor querying `Guests`).
- **Msg 230**: no permission on one column (Finance asking for `CardNumber`).

A few things I learned along the way:
- `GRANT SELECT` grants a *permission named SELECT*. It isn't a query. The user's own SELECT is checked against it later.
- Column-scoped `UPDATE` (FrontDesk can change `Status` and nothing else) is least privilege on writes, not just reads.
- `DENY` beats any `GRANT`, even one inherited from another role. `REVOKE` just removes a grant or deny, which leaves the default (no access).
- The script resets itself (`DROP USER/ROLE IF EXISTS`) so it can be re-run cleanly.

---

## Step 3: Access Mapping (Who Can See What)

An auditor's question: for every user, which permissions do they get through their roles?

```sql
SELECT  m.name AS user_name,
        r.name AS role_name,
        CASE WHEN r.is_fixed_role = 1 THEN 'ALL (fixed role)'
             ELSE p.permission_name END AS permission,
        p.state_desc AS state,
        OBJECT_NAME(p.major_id) AS table_name,
        COL_NAME(p.major_id, p.minor_id) AS column_name
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
LEFT JOIN sys.database_permissions p ON p.grantee_principal_id = r.principal_id
ORDER BY user_name, table_name, column_name;
```

### Finding: the access map that hides db_owner

My first version used `JOIN` and returned 17 rows, every grant I had made. But `dbo`, the most powerful user in the database, **wasn't in it**.

Fixed roles like `db_owner` have their power built in. They don't get rows in `sys.database_permissions`, so an inner join silently drops them. An audit built that way shows the least dangerous accounts and hides the most dangerous one.

Switching to `LEFT JOIN` brought `dbo / db_owner` back (18 rows), and the `CASE` labels it `ALL (fixed role)` instead of showing blanks.

---

## Step 4: Dynamic Data Masking

A mask changes how a column is *displayed* without changing the stored data:

```sql
ALTER TABLE dbo.Payments
ALTER COLUMN CardNumber
ADD MASKED WITH (FUNCTION = 'partial(0, "XXXX-XXXX-XXXX-", 4)');
```

`partial(prefix, "padding", suffix)` shows 0 characters from the start, the padding in the middle, and the last 4 at the end.

**Masks only apply after the permission check.** Finance still got Msg 230, because Finance has no SELECT on `CardNumber` at all. To see a mask you need someone who *can* read the column, so I added a **PaymentDisputes** role (`pd_erin`) with SELECT on the whole table:

```
PaymentID  CardNumber           Amount
5000       XXXX-XXXX-XXXX-1111  1250.00
5001       XXXX-XXXX-XXXX-4444  8900.00
```

### Finding: the WHERE-clause bypass

The mask only changes the *results*. The `WHERE` clause still runs against the real data:

```sql
EXECUTE AS USER = 'pd_erin';
SELECT PaymentID, CardNumber FROM dbo.Payments
WHERE CardNumber LIKE '4111%';
REVERT;
```

This returned **2 rows**. The display still said `XXXX-XXXX-XXXX-1111`, but pd_erin now knew those two cards start with `4111`. Repeating it one position at a time (`'4111-0%'`, `'4111-1%'`, ...) recovers the full number in about 160 queries, which is trivial to script. The same works on SSNs, and on dates with `>` and `<`.

**Masking is a display convenience, not a security boundary.** Anyone with SELECT on a masked column can infer its real values.

---

## Step 5: The Fix, a Last-4 View

Finance's real need was the last 4 digits of the card. Instead of giving them the column, I gave them a view:

```sql
CREATE OR ALTER VIEW dbo.vw_PaymentsLast4 AS
SELECT PaymentID, GuestID, Amount, PaidAt,
       RIGHT(CardNumber, 4) AS CardLast4
FROM dbo.Payments;
GO

GRANT SELECT ON dbo.vw_PaymentsLast4 TO Finance;
```

Finance has SELECT on the view only, not on `CardNumber`. Because `dbo` owns both the view and the table, SQL Server doesn't re-check permissions on the table underneath (**ownership chaining**). The full number never leaves the server, so there's nothing to run the bypass against.

(`CREATE VIEW` must be the only statement in its batch, which is why the `GO` lines are there.)

### Finding: my mask broke my view

The first test returned:

```
PaymentID  ...  CardLast4
5000       ...  xxxx
```

Masking carries through expressions. `RIGHT(CardNumber, 4)` is built from a masked column, so Finance got the default mask instead of the digits. The two layers I had added, a mask and a view, were working against each other.

The fix was a column-level UNMASK (SQL Server 2022+):

```sql
GRANT UNMASK ON dbo.Payments(CardNumber) TO Finance;
```

Result: `1111`, `4444`, `1881`, ...

This is safe because **UNMASK is not SELECT**. Finance still can't query the column directly:

```
SELECT CardNumber FROM dbo.Payments
Msg 230: The SELECT permission was denied on the column 'CardNumber'
```

The view is Finance's only path to card data, and it only returns 4 digits.

| Layer | What it does for Finance |
|-------|--------------------------|
| No SELECT on `CardNumber` | Can't read or filter on the full number (no bypass) |
| SELECT on the view | Can see the last 4 |
| UNMASK on `CardNumber` | Stops the mask from turning the last 4 into `xxxx` |

---

## Step 6: What None of This Stops

`db_owner` and `sysadmin` get past all of it. DENY doesn't apply to the owner, masks don't apply to them, and (from Step 3) they don't even show up in a basic permission audit. A curious or compromised DBA account can read every card number.

The control for that is **Always Encrypted**. The encryption keys live *outside* SQL Server (certificate store, Azure Key Vault, or an HSM), and the client driver encrypts and decrypts the data. The database only stores ciphertext, so a DBA, a stolen backup, or an attacker on the server sees scrambled bytes. It also enforces separation of duties: the people who run the database are not the people who hold the keys. The trade-off is querying. Deterministic encryption allows equality lookups, randomized allows almost nothing, and range or `LIKE` searches need secure enclaves.

I didn't implement Always Encrypted in this lab.

---

## Takeaways: Giving Someone Partial Access to Sensitive Data

1. **Don't grant the column.** Least privilege first.
2. **Need part of it? Use a view** that returns only that part. The full value never leaves the server.
3. **Dynamic Data Masking is for convenience, not protection.** It can be bypassed through WHERE clauses. And check how it interacts with your other controls: it masked my view's output.
4. **Need protection from privileged insiders? Use Always Encrypted** (or tokenization), so the keys aren't on the database server at all.
5. **Audit your audit.** A permission map that inner-joins `sys.database_permissions` hides `db_owner`.

## Skills Demonstrated

- Role-based access control in SQL Server: roles, column-level GRANT, DENY vs REVOKE, `EXECUTE AS` testing
- Permission auditing with system catalog views (`sys.database_principals`, `sys.database_role_members`, `sys.database_permissions`, `sys.masked_columns`)
- Dynamic Data Masking, and demonstrating its inference bypass
- Views and ownership chaining as an access boundary
- Column-level UNMASK (SQL Server 2022+)
- Data protection layers: access control vs masking vs encryption
