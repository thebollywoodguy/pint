# Quick Reference: Oracle to SAP HANA Conversion Patterns

## Syntax Comparison Table

| Feature | Oracle PL/SQL | SAP HANA SQLScript |
|---------|---------------|-------------------|
| **Procedure Header** | `CREATE OR REPLACE PROCEDURE name AS` | `CREATE PROCEDURE name LANGUAGE SQLSCRIPT SQL SECURITY INVOKER AS BEGIN ... END;` |
| **Data Types** | `NUMBER` | `INTEGER` or `DECIMAL` |
| | `VARCHAR2(n)` | `NVARCHAR(n)` or `VARCHAR(n)` |
| **NULL Handling** | `NVL(col, default)` | `IFNULL(col, default)` or `COALESCE(col, default)` |
| **Current Date** | `SYSDATE` | `CURRENT_DATE` or `CURRENT_TIMESTAMP` |
| **Dummy Table** | `FROM dual` | `FROM DUMMY` |
| **String Position** | `INSTR(str, substr)` | `LOCATE(str, substr)` |
| **Substring** | `SUBSTR(str, pos, len)` | `SUBSTRING(str, pos, len)` |
| **Cursor Loop** | `FOR rec IN cursor` | `FOR rec AS cursor DO ... END FOR;` |
| **IF Statement** | `IF condition THEN ... END IF;` | `IF condition THEN ... END IF;` |
| **WHILE Loop** | `WHILE condition LOOP ... END LOOP;` | `WHILE condition DO ... END WHILE;` |
| **Exit Handler** | N/A (use exceptions) | `DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ... END;` |

## String Splitting Pattern

### Oracle (CONNECT BY)
```sql
SELECT trim(regexp_substr(field, '[^;]+', 1, level)) AS token
FROM table_name
CONNECT BY instr(field, ';', 1, level - 1) > 0
```

### SAP HANA (Procedural Loop)
```sql
DECLARE v_string NVARCHAR(5000);
DECLARE v_token NVARCHAR(500);
DECLARE v_pos INTEGER;

v_string := field;

WHILE LENGTH(v_string) > 0 DO
  v_pos := LOCATE(v_string, ';');
  
  IF v_pos > 0 THEN
    v_token := TRIM(SUBSTRING(v_string, 1, v_pos - 1));
    v_string := SUBSTRING(v_string, v_pos + 1);
  ELSE
    v_token := TRIM(v_string);
    v_string := '';
  END IF;
  
  -- Process v_token here
END WHILE;
```

## Data Validation Pattern

### Oracle (VALIDATE_CONVERSION)
```sql
SELECT VALIDATE_CONVERSION(column AS datatype, 'format') 
FROM table_name;
```

### SAP HANA (Exception Handling)
```sql
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
  BEGIN
    v_result := 0;  -- Invalid
  END;
  
  SELECT CASE WHEN TO_NUMBER(column) IS NOT NULL THEN 1 ELSE 0 END
  INTO v_result
  FROM table_name;
END;
```

## Dynamic SQL Pattern

### Oracle (EXECUTE IMMEDIATE)
```sql
v_sql := 'SELECT COUNT(*) FROM table WHERE id = ' || var_id;
EXECUTE IMMEDIATE v_sql INTO v_count;
```

### SAP HANA (Direct SQL)
```sql
SELECT COUNT(*) INTO v_count 
FROM table 
WHERE id = var_id;
```

## Common Gotchas

1. **Case Sensitivity**: SAP HANA is case-sensitive by default for object names
2. **Auto-commit**: SAP HANA procedures auto-commit by default unless in transaction
3. **Variable Scope**: Variables declared in BEGIN...END blocks have local scope
4. **LIMIT Clause**: Use `LIMIT 1` instead of `ROWNUM = 1`
5. **String Concatenation**: Both support `||` operator
6. **Date Formats**: SAP HANA may require explicit format masks in TO_DATE
7. **Exception Handling**: Must explicitly declare handlers in SAP HANA

## Best Practices

1. **Use Exception Handlers**: Wrap conversion functions in exception handlers
2. **Avoid Dynamic SQL**: Use parameterized queries instead when possible
3. **Test Data Types**: Verify implicit conversions work as expected
4. **Use Table Variables**: For complex operations, declare intermediate result tables
5. **Comment Your Code**: Explain SAP HANA-specific workarounds
6. **Performance**: Monitor and optimize - execution plans differ between platforms

## Testing Checklist

- [ ] Verify all data type conversions
- [ ] Test NULL handling edge cases
- [ ] Validate date format conversions
- [ ] Test string splitting with various delimiters
- [ ] Verify exception handling works correctly
- [ ] Test with empty/NULL input values
- [ ] Validate referential integrity checks
- [ ] Performance test with production-like data volumes
- [ ] Test transaction behavior
- [ ] Verify error logging functionality
