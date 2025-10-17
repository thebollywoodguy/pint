# Deployment Checklist for SAP HANA Stored Procedure

Use this checklist when deploying the converted `org_exceptions_validations` procedure to SAP HANA.

## Pre-Deployment Checklist

### Environment Verification
- [ ] SAP HANA database is accessible and operational
- [ ] Appropriate user credentials available with required permissions
- [ ] Schema `PINTEXT` exists in SAP HANA
- [ ] Database version supports SQLScript features used (recommended: SAP HANA 2.0 or later)

### Table Verification
Verify all dependent tables exist and have correct structure:

- [ ] **org_exceptions_hold** (source table)
  - [ ] Table exists
  - [ ] Contains columns: employee_id, previous_pod, current_pod, termination_date, leave_start_date, leave_end_date, on_paid_leave, okr_pod, local_pod, global_pod, title_name, pod_eff_startdate, vc_eff_startdate, localpod_quota, globalpod_quota, currentpod_quota, okrpod_quota

- [ ] **org_exception_errors** (error logging table)
  - [ ] Table exists
  - [ ] Can be written to (INSERT permission)
  - [ ] Can be cleared (DELETE permission)
  - [ ] Contains matching columns for error records plus status and error message columns

- [ ] **nq_podquota** (pod validation reference table)
  - [ ] Table exists
  - [ ] Contains columns: NEXTQUARTERCHANNEL, NEXTQUARTERSUBCHANNEL, NEXTQUARTERSECTOR, NEXTQUARTERSUBSECTOR, NEXTQUARTERMANAGERTEAM, NEXTQUARTERTEAMNAME
  - [ ] Has appropriate indexes for lookup performance

- [ ] **cs_title** (title validation reference table)
  - [ ] Table exists
  - [ ] Contains columns: name, removedate
  - [ ] Has appropriate indexes

### Permission Verification
- [ ] User has CREATE PROCEDURE permission on schema PINTEXT
- [ ] User has SELECT permission on org_exceptions_hold
- [ ] User has SELECT, INSERT, DELETE permission on org_exception_errors
- [ ] User has SELECT permission on nq_podquota
- [ ] User has SELECT permission on cs_title

### Backup
- [ ] Current database state backed up (if applicable)
- [ ] Existing procedure backed up (if replacing existing version)
- [ ] Documentation of current validation logic preserved

## Deployment Steps

### Step 1: Review Documentation
- [ ] Read `SUMMARY.md` for overview
- [ ] Review `CONVERSION_NOTES.md` for technical changes
- [ ] Understand `SIDE_BY_SIDE_COMPARISON.md` for key differences

### Step 2: Deploy Procedure
- [ ] Connect to SAP HANA database
- [ ] Execute `org_exceptions_validations_hana.sql`
- [ ] Verify procedure created successfully: `SELECT * FROM PROCEDURES WHERE SCHEMA_NAME = 'PINTEXT' AND PROCEDURE_NAME = 'ORG_EXCEPTIONS_VALIDATIONS'`
- [ ] Check for any syntax errors or warnings

### Step 3: Grant Permissions
- [ ] Grant EXECUTE permission to required users/roles:
  ```sql
  GRANT EXECUTE ON PROCEDURE PINTEXT.ORG_EXCEPTIONS_VALIDATIONS TO <user_or_role>;
  ```
- [ ] Verify permissions: `SELECT * FROM GRANTED_PRIVILEGES WHERE OBJECT_NAME = 'ORG_EXCEPTIONS_VALIDATIONS'`

### Step 4: Initial Testing
- [ ] Prepare test data in org_exceptions_hold table
- [ ] Clear org_exception_errors: `DELETE FROM org_exception_errors;`
- [ ] Execute procedure: `CALL PINTEXT.ORG_EXCEPTIONS_VALIDATIONS();`
- [ ] Check execution completed without errors
- [ ] Verify results in org_exception_errors table
- [ ] Compare results with expected output

## Post-Deployment Testing

### Functional Testing
- [ ] **Test 1: Valid Data**
  - [ ] Insert valid employee record
  - [ ] Execute procedure
  - [ ] Verify no errors logged

- [ ] **Test 2: Invalid Employee ID**
  - [ ] Insert record with non-numeric employee_id
  - [ ] Execute procedure
  - [ ] Verify error logged with "EmpID" in message

- [ ] **Test 3: Invalid Date**
  - [ ] Insert record with invalid date format
  - [ ] Execute procedure
  - [ ] Verify error logged with date field name in message

- [ ] **Test 4: Invalid Pod**
  - [ ] Insert record with pod not in nq_podquota
  - [ ] Execute procedure
  - [ ] Verify error logged with appropriate pod field name

- [ ] **Test 5: Duplicate Employee**
  - [ ] Insert two records with same employee_id
  - [ ] Execute procedure
  - [ ] Verify error "Employee repeated multiple times"

- [ ] **Test 6: Semicolon-Delimited Pods**
  - [ ] Insert record with multiple pods (e.g., "pod1;pod2;pod3")
  - [ ] Execute procedure
  - [ ] Verify all pods validated correctly

- [ ] **Test 7: NULL Values**
  - [ ] Insert record with NULL in optional fields
  - [ ] Execute procedure
  - [ ] Verify NULLs handled correctly

### Performance Testing
- [ ] **Small Dataset (< 100 records)**
  - [ ] Load test data
  - [ ] Record execution time: _______ seconds
  - [ ] Verify acceptable performance

- [ ] **Medium Dataset (100-1000 records)**
  - [ ] Load test data
  - [ ] Record execution time: _______ seconds
  - [ ] Verify acceptable performance

- [ ] **Large Dataset (> 1000 records)** (if applicable)
  - [ ] Load test data
  - [ ] Record execution time: _______ seconds
  - [ ] Compare with Oracle version (if available)

### Integration Testing
- [ ] Test procedure as part of existing data pipeline
- [ ] Verify no impact on downstream processes
- [ ] Check data quality in org_exception_errors
- [ ] Verify error notifications work (if applicable)

## Monitoring & Validation

### First 24 Hours
- [ ] Monitor procedure execution logs
- [ ] Check for any errors or warnings
- [ ] Verify data quality in error logs
- [ ] Compare results with previous Oracle version (if running in parallel)

### First Week
- [ ] Review performance metrics
- [ ] Collect user feedback
- [ ] Monitor memory usage
- [ ] Check for any locking or blocking issues

### First Month
- [ ] Analyze execution patterns
- [ ] Identify optimization opportunities
- [ ] Document any issues or workarounds
- [ ] Update documentation if needed

## Rollback Procedure

If critical issues are discovered:

1. [ ] Document the issue clearly
2. [ ] Drop the procedure: `DROP PROCEDURE PINTEXT.ORG_EXCEPTIONS_VALIDATIONS;`
3. [ ] Restore previous version (if applicable)
4. [ ] Notify stakeholders
5. [ ] Plan remediation steps

## Sign-off

### Deployment Team
- **Deployed By**: ___________________
- **Deployment Date**: ___________________
- **Deployment Time**: ___________________
- **Environment**: ☐ Development ☐ Testing ☐ Staging ☐ Production

### Testing Team
- **Tested By**: ___________________
- **Test Date**: ___________________
- **Test Result**: ☐ Passed ☐ Failed (see notes)
- **Notes**: ___________________

### Approval
- **Approved By**: ___________________
- **Approval Date**: ___________________
- **Comments**: ___________________

## Issue Tracking

| Issue # | Description | Severity | Status | Resolution |
|---------|-------------|----------|--------|------------|
| | | | | |
| | | | | |
| | | | | |

## Notes & Observations

Use this space for any additional notes, observations, or lessons learned during deployment:

```
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
```

---

**Document Version**: 1.0  
**Last Updated**: October 17, 2025  
**Next Review Date**: _________________
