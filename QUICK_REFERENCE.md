# Quick Reference - SF EC to OGPT Integration

## File Quick Reference

| File | Purpose | When to Use |
|------|---------|-------------|
| `SFECToOGPTMapping.groovy` | Main transformation script | Deploy in SAP CPI Groovy Script step |
| `GROOVY_MAPPING_README.md` | Detailed script documentation | Implementation, customization, troubleshooting |
| `FIELD_MAPPING_SPEC.md` | Complete field mappings (95+ fields) | Understanding data transformation, customization |
| `SAP_CPI_SETUP_GUIDE.md` | Deployment and configuration guide | Initial setup, deployment, maintenance |
| `sample_input.xml` | Test SOAP response | Unit testing, validation |
| `sample_output.json` | Expected JSON output | Validation, verification |
| `README.md` | Repository overview | Getting started, architecture overview |

---

## Common Tasks

### Task 1: Deploy Script to SAP CPI
1. Open SAP CPI Design workspace
2. Create or edit Integration Flow
3. Add Groovy Script step after SF EC SOAP call
4. Copy content from `SFECToOGPTMapping.groovy`
5. Save and deploy
6. **Details:** `SAP_CPI_SETUP_GUIDE.md` Part 2 & 3

### Task 2: Test with Sample Data
1. Use SAP CPI Simulation feature
2. Upload `sample_input.xml` as input
3. Execute flow
4. Compare output with `sample_output.json`
5. **Details:** `SAP_CPI_SETUP_GUIDE.md` Part 5

### Task 3: Add Custom Field Mapping
1. Update `FIELD_MAPPING_SPEC.md` with new field
2. Edit `SFECToOGPTMapping.groovy`:
   - Find `buildOGPTJson()` function
   - Add field mapping in appropriate section
3. Test with sample data
4. **Details:** `GROOVY_MAPPING_README.md` Customization section

### Task 4: Troubleshoot Errors
1. Check SAP CPI Monitor → Message Processing Logs
2. Review attachments: `Error_Details`, `Employee_Processing_Error`
3. Consult troubleshooting sections:
   - `GROOVY_MAPPING_README.md` - Common Issues
   - `SAP_CPI_SETUP_GUIDE.md` - Troubleshooting Guide
4. Fix and redeploy

### Task 5: Schedule Regular Sync
1. Edit Integration Flow Start Event
2. Set Timer schedule (e.g., `0 0 2 * * ?` for 2 AM daily)
3. Configure error handling
4. Set up monitoring alerts
5. **Details:** `SAP_CPI_SETUP_GUIDE.md` Part 7

---

## Key Field Mappings Cheat Sheet

### Essential Employee Fields
```
SF EC Field          → OGPT JSON Path
─────────────────────────────────────────
userId               → employeeId
email                → contactInfo.email
firstName            → personalInfo.firstName
lastName             → personalInfo.lastName
hireDate             → employmentInfo.hireDate
title                → jobInfo.title
department           → jobInfo.department
managerId            → managerInfo.managerId
```

### Pod Information (Custom Fields)
```
SF EC Field          → OGPT JSON Path
─────────────────────────────────────────
custom01             → organizationInfo.currentPod
custom02             → organizationInfo.previousPod
custom03             → organizationInfo.okrPod
custom04             → organizationInfo.localPod
custom05             → organizationInfo.globalPod
custom06             → organizationInfo.podEffectiveDate
```

### Leave Information
```
SF EC Field          → OGPT JSON Path
─────────────────────────────────────────
custom07             → leaveInfo.onPaidLeave
custom08             → leaveInfo.leaveStartDate
custom09             → leaveInfo.leaveEndDate
```

### Quota Information
```
SF EC Field          → OGPT JSON Path
─────────────────────────────────────────
custom10             → quotaInfo.currentPodQuota
custom11             → quotaInfo.okrPodQuota
custom12             → quotaInfo.localPodQuota
custom13             → quotaInfo.globalPodQuota
```

---

## SAP CPI Integration Flow Pattern

```
┌──────────────┐
│ Start        │ Timer or HTTPS Sender
│ (Timer/HTTP) │ Schedule: 0 0 2 * * ? (Daily 2 AM)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Content      │ Build SF EC SOAP query
│ Modifier 1   │ Set query filters, date ranges
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Request      │ Call SF EC SOAP API
│ Reply        │ URL: https://{dc}.successfactors.com/sfapi/v1/soap
│ (SOAP)       │ Auth: OAuth or Basic
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Groovy       │ Transform SOAP to JSON
│ Script       │ Script: SFECToOGPTMapping.groovy
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Content      │ Set output headers
│ Modifier 2   │ Content-Type: application/json
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ End          │ File, HTTP, or both
│ (Receiver)   │ Destination: OGPT system or file
└──────────────┘
```

---

## Script Customization Points

### 1. Add New Employee Field
**Location:** `buildOGPTJson()` function  
**Section:** Choose appropriate category (personalInfo, jobInfo, etc.)

```groovy
// Example: Add middle initial field
personalInfo: [
    firstName: getFieldValue(employee, 'firstName'),
    lastName: getFieldValue(employee, 'lastName'),
    middleInitial: getFieldValue(employee, 'middleInitial', 'midInit'),  // NEW
    // ... rest of fields
]
```

### 2. Modify Date Format
**Location:** Top of script  
**Variable:** `dateFormatter`

```groovy
// Change from YYYY-MM-DD to DD/MM/YYYY
def dateFormatter = new SimpleDateFormat("dd/MM/yyyy")
```

### 3. Add Custom Validation
**Location:** `buildOGPTJson()` function  
**Position:** Inside employee loop, before building ogptEmployee

```groovy
// Example: Skip contractors
if (getFieldValue(employee, 'employeeClass') == 'Contractor') {
    continue  // Skip this employee
}
```

### 4. Filter Employees
**Location:** SAP CPI Content Modifier (SOAP query)  
**Modify:** Query filter in SOAP body

```xml
<!-- Example: Only active employees in Engineering -->
WHERE status = 'Active' AND department = 'Engineering'
```

---

## Monitoring Checklist

### Daily Checks
- [ ] Check execution status in SAP CPI Monitor
- [ ] Verify record count matches expected
- [ ] Review error logs for patterns
- [ ] Confirm output file/API success

### Weekly Checks
- [ ] Review execution time trends
- [ ] Check for increasing error rates
- [ ] Validate data quality spot checks
- [ ] Review message log attachments

### Monthly Checks
- [ ] Analyze error patterns and root causes
- [ ] Review field mapping changes needed
- [ ] Performance optimization review
- [ ] Security credential rotation check

---

## Error Messages and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| "No employees found" | Empty SOAP response | Check SF EC query filter, verify credentials |
| "Date parsing error" | Unexpected date format | Add format to formatDate() function |
| "Field not found" | Missing SF EC field | Add fallback field name in getFieldValue() |
| "Timeout" | Large batch, slow processing | Reduce batch size, add pagination |
| "Authentication failed" | Invalid credentials | Update Security Material in SAP CPI |
| "JSON serialization error" | Invalid data structure | Check for circular references, special characters |

---

## SF EC SOAP Query Templates

### All Active Employees
```xml
<queryString>
  SELECT * FROM User WHERE status = 'Active'
</queryString>
```

### Employees Modified Today
```xml
<queryString>
  SELECT * FROM User 
  WHERE lastModifiedDate &gt; '${date:now-1d:yyyy-MM-dd}T00:00:00'
</queryString>
```

### Specific Departments
```xml
<queryString>
  SELECT * FROM User 
  WHERE status = 'Active' 
    AND department IN ('Engineering', 'Product', 'Sales')
</queryString>
```

### New Hires This Month
```xml
<queryString>
  SELECT * FROM User 
  WHERE hireDate &gt;= '${date:now:yyyy-MM}-01'
</queryString>
```

---

## JSON Output Structure Template

```json
{
  "metadata": {
    "source": "SuccessFactors Employee Central",
    "extractionDate": "YYYY-MM-DDTHH:mm:ssZ",
    "recordCount": 123,
    "version": "1.0"
  },
  "employees": [
    {
      "employeeId": "...",
      "personalInfo": { ... },
      "contactInfo": { ... },
      "employmentInfo": { ... },
      "jobInfo": { ... },
      "managerInfo": { ... },
      "organizationInfo": { ... },
      "leaveInfo": { ... },
      "quotaInfo": { ... },
      "compensationInfo": { ... },
      "systemInfo": { ... },
      "customFields": { ... }
    }
  ]
}
```

---

## Performance Guidelines

| Batch Size | Expected Time | Memory Usage | Recommendation |
|------------|--------------|--------------|----------------|
| 10-50 | 5-10 sec | Low | Good for testing |
| 100-500 | 30-60 sec | Medium | Ideal for daily sync |
| 1000-2000 | 2-5 min | High | Use incremental filters |
| 5000+ | 10+ min | Very High | Implement pagination |

---

## Contact and Support

**For Integration Issues:**
- Check SAP CPI message logs first
- Review documentation sections
- Contact SAP CPI support team

**For Data Mapping Questions:**
- Review `FIELD_MAPPING_SPEC.md`
- Consult SF EC data dictionary
- Contact data architecture team

**For SuccessFactors API:**
- Check SF EC API documentation
- Verify user permissions
- Contact SF administrator

---

## Next Steps After Deployment

1. **Week 1:** Monitor daily, fix immediate issues
2. **Week 2:** Fine-tune error handling, optimize performance
3. **Week 3:** Implement monitoring dashboard
4. **Week 4:** Review and document lessons learned
5. **Month 2:** Optimize based on usage patterns

---

**Document Version:** 1.0  
**Last Updated:** January 2024  
**Quick Reference Owner:** Platform Integration Team
