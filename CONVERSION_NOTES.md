# Oracle to SAP HANA Stored Procedure Conversion

## Overview
This document outlines the conversion of the Oracle stored procedure `PINTEXT.org_exceptions_validations` to SAP HANA SQLScript.

## Key Changes Made

### 1. Procedure Declaration
**Oracle:**
```sql
CREATE OR REPLACE PROCEDURE PINTEXT.org_exceptions_validations  
as 
```

**SAP HANA:**
```sql
CREATE PROCEDURE PINTEXT.ORG_EXCEPTIONS_VALIDATIONS
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS 
BEGIN
...
END;
```

### 2. Data Type Conversions
- `NUMBER` → `INTEGER` (for numeric fields)
- `VARCHAR2(n)` → `NVARCHAR(n)` (for string fields)

### 3. Function Replacements

#### NVL → IFNULL
**Oracle:** `NVL(column, 'default')`  
**SAP HANA:** `IFNULL(column, 'default')`

#### SYSDATE → CURRENT_DATE
**Oracle:** `tl.removedate > sysdate`  
**SAP HANA:** `tl.removedate > CURRENT_DATE`

#### VALIDATE_CONVERSION
Oracle's `VALIDATE_CONVERSION` function doesn't exist in SAP HANA. Replaced with:
- Exception handling blocks with `DECLARE EXIT HANDLER FOR SQLEXCEPTION`
- Direct validation using `TO_NUMBER()` and `TO_DATE()` with NULL checks

**Oracle:**
```sql
SELECT VALIDATE_CONVERSION(employee_id as number) FROM ...
```

**SAP HANA:**
```sql
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
  BEGIN
    v_employeeid := 0;
  END;
  SELECT CASE WHEN TO_NUMBER(employee_id) IS NOT NULL THEN 1 ELSE 0 END 
  INTO v_employeeid
  FROM org_exceptions_hold WHERE employee_id = validate_rec.employee_id;
END;
```

### 4. DUAL Table
SAP HANA uses `DUMMY` instead of Oracle's `DUAL` table.

**Oracle:** `FROM dual`  
**SAP HANA:** `FROM DUMMY`

### 5. EXECUTE IMMEDIATE Replacement
Dynamic SQL with `EXECUTE IMMEDIATE` has been replaced with direct SQL statements in SAP HANA, as the queries can be executed directly without dynamic construction.

### 6. Hierarchical Queries (CONNECT BY)
Oracle's `CONNECT BY` for string splitting has been replaced with a procedural WHILE loop approach using `LOCATE` and `SUBSTRING` functions.

**Oracle:**
```sql
SELECT trim(regexp_substr(current_pod, '[^;]+', 1, level)) current_pod
FROM (SELECT ...) t
CONNECT BY instr(current_pod, ';', 1, level - 1) > 0
```

**SAP HANA:**
```sql
DECLARE v_pod_string NVARCHAR(5000);
DECLARE v_pod_token NVARCHAR(500);
DECLARE v_pos INTEGER;

v_pod_string := IFNULL(TRIM(validate_rec.current_pod), 'x');

WHILE LENGTH(v_pod_string) > 0 DO
  v_pos := LOCATE(v_pod_string, ';');
  
  IF v_pos > 0 THEN
    v_pod_token := TRIM(SUBSTRING(v_pod_string, 1, v_pos - 1));
    v_pod_string := SUBSTRING(v_pod_string, v_pos + 1);
  ELSE
    v_pod_token := TRIM(v_pod_string);
    v_pod_string := '';
  END IF;
  
  -- Process v_pod_token...
END WHILE;
```

### 7. Transaction Control
- Removed explicit `COMMIT` statements within the loop as SAP HANA procedures use auto-commit by default
- The DELETE statement at the beginning remains

### 8. String Concatenation
Oracle's `||` operator is retained in SAP HANA as it's also supported.

### 9. Cursor Syntax
**Oracle:**
```sql
cursor c1 is
select * from org_exceptions_hold;
FOR validate_rec IN c1
```

**SAP HANA:**
```sql
DECLARE CURSOR c1 FOR
SELECT * FROM org_exceptions_hold;
FOR validate_rec AS c1
```

### 10. Variable References in SELECT
In SAP HANA, when using variables in SELECT statements within FROM DUMMY, no special syntax is needed - variables are referenced directly without the colon prefix in most contexts.

## Removed Elements
1. `insert into test1 values (v_sql);` - Debug statements were removed
2. Dynamic SQL construction - Converted to direct SQL statements

## Testing Recommendations
1. Verify data type compatibility with existing tables
2. Test exception handling for invalid data conversions
3. Validate string splitting logic with semicolon-delimited values
4. Test with duplicate employee records
5. Verify validation logic for all pod types (current, okr, local, global)
6. Test date and number validation edge cases

## Notes
- SAP HANA SQLScript has stricter type checking than Oracle PL/SQL
- Exception handling is more explicit in SAP HANA
- The procedural string splitting approach is more maintainable than complex CTEs or table functions
- Performance may differ; monitor and optimize as needed
