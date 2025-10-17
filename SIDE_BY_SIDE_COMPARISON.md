# Side-by-Side Example: String Splitting Logic

This document shows a detailed side-by-side comparison of how the string splitting logic was converted from Oracle's CONNECT BY to SAP HANA's procedural approach.

## Oracle Version (Lines 97-123)

```sql
if nvl(trim(validate_rec.current_pod),'0') <> '0' then 

begin 
v_sql :='select case when val <> ''0'' then 0 else 1 end  from (
    select nvl( (select nvl(current_pod,0) val from (
       select * from (SELECT distinct employee_id, trim(regexp_substr(current_pod, ''[^;]+'', 1, level)) current_pod
                                                                                      FROM (SELECT employee_id,nvl(trim(current_pod),''x'') current_pod,nvl(trim(okr_pod),''x''),nvl(trim(local_pod),''x''),nvl(trim(global_pod),''x'') FROM org_exceptions_hold 
                                                                                      where employee_id =   '||validate_rec.employee_id ||'  ) t
                                                                                    CONNECT BY instr(current_pod, '';'', 1, level - 1) > 0) o                                                                                    
            where  o.employee_id =   '||validate_rec.employee_id ||'   and not exists (select 1 from nq_podquota n where ( N.NEXTQUARTERCHANNEL = o.current_pod or N.NEXTQUARTERSUBCHANNEL = o.current_pod or N.NEXTQUARTERSECTOR = o.current_pod 
                                                                                        or N.NEXTQUARTERSUBSECTOR = o.current_pod or N.NEXTQUARTERMANAGERTEAM = o.current_pod or N.NEXTQUARTERTEAMNAME = o.current_pod))
)),0) val from dual)';

insert into test1 values (v_sql);

commit;

execute immediate v_sql into v_currentpod;

if v_currentpod <> 0 then v_currentpod:=1; else v_currentpod:=0; end if;
end ;

else v_currentpod:=2;
end if;
```

**Key Oracle Features Used:**
- `REGEXP_SUBSTR` with `level` parameter for string splitting
- `CONNECT BY` hierarchical query for generating rows
- `INSTR` for finding delimiter positions
- Dynamic SQL with `EXECUTE IMMEDIATE`
- String concatenation to build SQL query
- Debug insert to `test1` table
- Explicit `COMMIT`

## SAP HANA Version (Lines 209-248)

```sql
    IF IFNULL(TRIM(validate_rec.current_pod), '0') <> '0' THEN 

      BEGIN
        DECLARE v_pod_string NVARCHAR(5000);
        DECLARE v_pod_token NVARCHAR(500);
        DECLARE v_pos INTEGER;
        DECLARE v_found INTEGER DEFAULT 0;
        
        v_pod_string := IFNULL(TRIM(validate_rec.current_pod), 'x');
        v_currentpod := 1; -- Assume valid initially
        
        -- Loop through semicolon-separated values
        WHILE LENGTH(v_pod_string) > 0 DO
          v_pos := LOCATE(';', v_pod_string);
          
          IF v_pos > 0 THEN
            v_pod_token := TRIM(SUBSTRING(v_pod_string, 1, v_pos - 1));
            v_pod_string := SUBSTRING(v_pod_string, v_pos + 1);
          ELSE
            v_pod_token := TRIM(v_pod_string);
            v_pod_string := '';
          END IF;
          
          -- Check if token exists in nq_podquota
          IF v_pod_token <> '' AND v_pod_token <> 'x' THEN
            SELECT COUNT(*) INTO v_found
            FROM nq_podquota n
            WHERE N.NEXTQUARTERCHANNEL = v_pod_token 
               OR N.NEXTQUARTERSUBCHANNEL = v_pod_token 
               OR N.NEXTQUARTERSECTOR = v_pod_token 
               OR N.NEXTQUARTERSUBSECTOR = v_pod_token 
               OR N.NEXTQUARTERMANAGERTEAM = v_pod_token 
               OR N.NEXTQUARTERTEAMNAME = v_pod_token;
            
            IF v_found = 0 THEN
              v_currentpod := 0; -- Invalid pod found
              v_pod_string := ''; -- Exit loop
            END IF;
          END IF;
        END WHILE;
      END;

    ELSE 
      v_currentpod := 2;
    END IF;
```

**Key SAP HANA Features Used:**
- `WHILE` loop for iteration instead of hierarchical query
- `LOCATE` function to find delimiter position
- `SUBSTRING` for extracting tokens
- Local variable declarations for string manipulation
- Direct SQL query (no dynamic SQL needed)
- Early exit optimization when invalid pod found
- No debug statements
- No explicit commit (auto-commit)

## Comparison Summary

| Aspect | Oracle | SAP HANA |
|--------|--------|----------|
| **Lines of Code** | ~27 | ~40 |
| **Approach** | Declarative (SQL-based) | Procedural (loop-based) |
| **String Splitting** | `CONNECT BY` + `REGEXP_SUBSTR` | `WHILE` + `LOCATE` + `SUBSTRING` |
| **SQL Execution** | Dynamic (`EXECUTE IMMEDIATE`) | Static (direct SELECT) |
| **Readability** | Complex, nested subqueries | Linear, step-by-step |
| **Performance** | Set-based (potentially faster) | Row-by-row (may be slower for large datasets) |
| **Maintainability** | Difficult to debug | Easier to debug and modify |
| **Dependencies** | Regular expressions | String functions |

## Performance Considerations

### Oracle CONNECT BY Approach:
- **Pros:**
  - Set-based operation, can be optimized by query planner
  - Minimal row-by-row processing
  - Native support for hierarchical queries
  
- **Cons:**
  - Complex execution plan
  - May generate unnecessary intermediate results
  - Difficult to add custom logic during splitting

### SAP HANA Procedural Approach:
- **Pros:**
  - Clear control flow, easy to optimize specific cases
  - Can short-circuit on first invalid pod
  - No complex subqueries or temporary tables
  
- **Cons:**
  - Row-by-row processing overhead
  - May not benefit from parallel execution
  - More lines of code

## Optimization Suggestions

For the SAP HANA version, consider:

1. **Caching**: If the same pods are validated frequently, consider caching valid pods
2. **Batch Processing**: If validating multiple employees, consider batch validation
3. **Indexing**: Ensure indexes exist on nq_podquota lookup columns
4. **Table Function**: For heavy usage, consider creating a table function for string splitting

## Alternative SAP HANA Approaches

### Using APPLY_FILTER (SAP HANA 2.0 SPS 03+)
```sql
-- Could use table function for string splitting if available
-- or UNNEST with custom splitting logic
```

### Using Table Functions
```sql
-- Create reusable table function:
CREATE FUNCTION SPLIT_STRING(IN str NVARCHAR(5000), IN delim NVARCHAR(10))
RETURNS TABLE (token NVARCHAR(500))
LANGUAGE SQLSCRIPT AS
BEGIN
  -- Implementation here
END;
```

This would make the code more modular and reusable across procedures.
