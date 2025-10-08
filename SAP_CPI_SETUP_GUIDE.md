# SAP CPI Integration Flow Setup Guide

## Overview
This guide provides step-by-step instructions for deploying the SuccessFactors Employee Central to OGPT mapping Groovy script in SAP Cloud Platform Integration.

---

## Prerequisites

### Required Access
- [ ] SAP Cloud Platform Integration tenant access
- [ ] Design workspace permissions
- [ ] Deploy permissions
- [ ] SuccessFactors Employee Central system access
- [ ] SuccessFactors API credentials (OAuth or Basic Auth)

### Required Information
- [ ] SF EC datacenter URL (e.g., `https://api.successfactors.com`)
- [ ] SF EC Company ID
- [ ] API credentials (Client ID/Secret for OAuth or Username/Password for Basic Auth)
- [ ] Target OGPT system endpoint (if applicable)

---

## Part 1: Setting Up SuccessFactors Connection

### Step 1.1: Create Security Material

1. Navigate to **Monitor → Security Material**
2. Click **Create → User Credentials** (for Basic Auth) or **OAuth2 Client Credentials** (for OAuth)

**For Basic Auth:**
- Name: `SFEC_BasicAuth`
- User: Your SF EC username
- Password: Your SF EC password
- Description: SuccessFactors Employee Central API Credentials

**For OAuth 2.0:**
- Name: `SFEC_OAuth`
- Token Service URL: `https://{datacenter}.successfactors.com/oauth/token`
- Client ID: Your OAuth Client ID
- Client Secret: Your OAuth Client Secret
- Description: SuccessFactors Employee Central OAuth Credentials

### Step 1.2: Test Connectivity

Create a simple test integration flow:
1. Add SOAP Receiver adapter
2. Configure connection to SF EC
3. Test with a simple query
4. Verify response

---

## Part 2: Creating the Integration Flow

### Step 2.1: Create New Integration Flow

1. Navigate to **Design → Integrations**
2. Click **Create**
3. Name: `SF_EC_to_OGPT_Employee_Sync`
4. ID: `SFEC_OGPT_EMP_SYNC`
5. Description: `Synchronize employee data from SuccessFactors to OGPT`

### Step 2.2: Design the Integration Flow

**Flow Structure:**
```
[Timer/HTTPS Sender] → [Content Modifier 1] → [Request Reply - SOAP] → [Groovy Script] → [Content Modifier 2] → [Target System/File]
```

**Detailed Steps:**

#### A. Start Event
- **Type**: Timer or HTTPS Sender
- **Timer Schedule**: `0 0 2 * * ?` (2 AM daily) or as required
- **OR HTTPS Path**: `/employeeSync`

#### B. Content Modifier 1 - Prepare SOAP Request
- **Name**: `Prepare_SF_Query`
- **Action**: Create SOAP envelope for SF EC query

**Message Body:**
```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sfapi="http://www.successfactors.com/sfapi/v1">
   <soapenv:Header/>
   <soapenv:Body>
      <sfapi:query>
         <sfapi:queryString>
            SELECT userId, personIdExternal, username, firstName, lastName, middleName, 
                   displayName, email, businessPhone, cellPhone, address1, address2, 
                   city, state, zipCode, country, hireDate, terminationDate, status, 
                   employeeClass, title, jobCode, department, division, location, 
                   costCenter, company, managerId, managerName, 
                   custom01, custom02, custom03, custom04, custom05, custom06, 
                   custom07, custom08, custom09, custom10, custom11, custom12, 
                   custom13, custom14, custom15, custom16, 
                   payGrade, fte, lastModifiedDate, isActive
            FROM User
            WHERE status = 'Active' 
               OR lastModifiedDate &gt; '${property.lastSyncDate}'
         </sfapi:queryString>
      </sfapi:query>
   </soapenv:Body>
</soapenv:Envelope>
```

**Properties to Set:**
- `lastSyncDate`: `${date:now-24h:yyyy-MM-dd'T'HH:mm:ss}` (for incremental sync)

#### C. Request Reply - SOAP Receiver
- **Name**: `Query_SF_EC_Employees`
- **Adapter Type**: SOAP 1.x
- **Address**: `https://{datacenter}.successfactors.com/sfapi/v1/soap`
- **Credential Name**: Select `SFEC_BasicAuth` or `SFEC_OAuth`
- **Authentication**: Basic or OAuth2
- **SOAP Action**: Leave empty or as per SF documentation
- **Processing**: `Sequential`

#### D. Groovy Script - Transform Data
- **Name**: `Transform_to_OGPT`
- **Script Type**: Groovy Script
- **Script Source**: Paste the content from `SFECToOGPTMapping.groovy`

#### E. Content Modifier 2 - Add Headers (Optional)
- **Name**: `Set_Output_Headers`
- **Headers**:
  - `Content-Type`: `application/json`
  - `X-Source-System`: `SuccessFactors`
  - `X-Sync-Date`: `${date:now:yyyy-MM-dd'T'HH:mm:ss}`

#### F. End Event - Choose Output Destination

**Option 1: File Output**
- Adapter: SFTP or File
- Directory: `/output/ogpt/employees/`
- File Name: `employees_${date:now:yyyyMMdd_HHmmss}.json`

**Option 2: HTTP/REST API Output**
- Adapter: HTTP Receiver
- Address: OGPT API endpoint
- Method: POST
- Authentication: As required by OGPT

**Option 3: Both (using Multicast)**
- Send to both file and API endpoint

---

## Part 3: Deploying the Groovy Script

### Step 3.1: Add Script to Integration Flow

1. In the Integration Flow editor, add a **Script** step after the SOAP receiver
2. Click on the Script step
3. In Properties, select:
   - **Script Type**: Groovy Script
   - **Script Language**: Groovy
4. Click on **Select** and choose **Create**
5. Name: `SFECToOGPTMapping`
6. Paste the entire content of `SFECToOGPTMapping.groovy`
7. Click **OK**

### Step 3.2: Configure Script Parameters

The script doesn't require external parameters as it processes the message body directly.

### Step 3.3: Validate Script

1. Click **Validate** in the script editor
2. Fix any syntax errors if reported
3. Save the script

---

## Part 4: Error Handling and Monitoring

### Step 4.1: Add Exception Subprocess

1. Add an **Exception Subprocess**
2. Add steps:
   - Content Modifier: Format error message
   - Mail adapter: Send error notification (optional)
   - Write to error log

### Step 4.2: Configure Logging

In the script properties:
- **Log Level**: `INFO` for production, `DEBUG` for testing
- **Log Configuration**: Enable message logging

### Step 4.3: Set Up Alerts

1. Navigate to **Monitor → Alerts**
2. Create alert for integration flow failures
3. Set notification recipients

---

## Part 5: Testing

### Step 5.1: Unit Test with Sample Data

1. Use the **Simulation** feature in Design workspace
2. Upload `sample_input.xml` as test input
3. Execute the flow
4. Verify output matches `sample_output.json` structure
5. Check for errors in message log

### Step 5.2: Integration Test

1. Deploy to test tenant/environment
2. Execute with real SF EC connection
3. Verify data accuracy
4. Check field mappings
5. Validate error handling

### Step 5.3: Performance Test

1. Test with various batch sizes (10, 100, 1000 employees)
2. Monitor execution time
3. Check memory usage
4. Verify no timeout issues

---

## Part 6: Deployment to Production

### Step 6.1: Pre-Deployment Checklist

- [ ] All tests passed
- [ ] Error handling verified
- [ ] Logging configured
- [ ] Alerts set up
- [ ] Documentation updated
- [ ] Backup of current version (if updating)

### Step 6.2: Deploy

1. In Design workspace, select the integration flow
2. Click **Deploy**
3. Select runtime profile (if applicable)
4. Confirm deployment
5. Wait for deployment to complete
6. Verify status in **Monitor → Manage Integration Content**

### Step 6.3: Post-Deployment Verification

1. Monitor first execution
2. Check logs for errors
3. Verify output file/API call
4. Compare record counts
5. Validate data accuracy

---

## Part 7: Scheduling and Automation

### Option 1: Timer-Based Execution

Configure in Start Event:
- **Schedule**: Cron expression
- **Example**: `0 0 2 * * ?` (Daily at 2 AM)
- **Time Zone**: Set appropriate timezone

### Option 2: Event-Based Trigger

- Triggered by SF EC webhook
- Triggered by external scheduler
- On-demand via HTTPS endpoint

### Option 3: Hybrid Approach

- Daily batch at night (all active employees)
- Real-time updates during day (modified employees only)

---

## Part 8: Maintenance and Optimization

### Regular Maintenance Tasks

**Weekly:**
- Review execution logs
- Check success rate
- Monitor performance metrics

**Monthly:**
- Review error patterns
- Update field mappings if needed
- Optimize query filters
- Clean up old logs

**Quarterly:**
- Review and update custom fields
- Performance tuning
- Security credential rotation

### Optimization Tips

1. **Batch Processing**: Process employees in batches of 500-1000
2. **Incremental Sync**: Use `lastModifiedDate` filter for daily runs
3. **Parallel Processing**: Use parallel multicast for independent operations
4. **Caching**: Cache reference data (departments, locations) if needed

---

## Troubleshooting Guide

### Issue: No Data Returned from SF EC

**Possible Causes:**
- Incorrect credentials
- Wrong datacenter URL
- Query filter too restrictive
- API permissions issue

**Solution:**
1. Verify credentials in Security Material
2. Test SF EC connection separately
3. Check query filter
4. Verify API user permissions in SF EC

### Issue: Script Execution Error

**Possible Causes:**
- Syntax error in script
- Memory limit exceeded
- Timeout

**Solution:**
1. Check message log for error details
2. Validate script syntax
3. Reduce batch size
4. Increase timeout settings

### Issue: Missing Fields in Output

**Possible Causes:**
- Field not present in SF EC response
- Field name mismatch
- Null value handling

**Solution:**
1. Check `Input_SOAP_Response` attachment in logs
2. Verify field names in SF EC
3. Add field name variants in script
4. Review null handling logic

### Issue: Date Formatting Errors

**Possible Causes:**
- Unexpected date format from SF EC
- Timezone issues

**Solution:**
1. Add SF EC date format to `formatDate()` function
2. Check SF EC date format settings
3. Add error logging for date parsing

### Issue: Performance Degradation

**Possible Causes:**
- Large employee count
- Complex transformations
- Network latency

**Solution:**
1. Implement pagination
2. Filter by modified date
3. Optimize script loops
4. Use parallel processing

---

## Monitoring Dashboard

### Key Metrics to Track

1. **Execution Status**: Success/Failure rate
2. **Record Count**: Number of employees processed
3. **Execution Time**: Total duration
4. **Error Count**: Number of processing errors
5. **Data Quality**: Missing required fields

### Creating Custom Dashboard

1. Navigate to **Monitor → Integration Content**
2. Select your integration flow
3. View execution logs
4. Export metrics for analysis
5. Set up custom monitoring (if available)

---

## Security Best Practices

1. **Credentials Management**:
   - Rotate credentials quarterly
   - Use OAuth instead of Basic Auth when possible
   - Never hardcode credentials in scripts

2. **Data Security**:
   - Enable encryption in transit (HTTPS/SFTP)
   - Mask sensitive data in logs
   - Implement access controls

3. **Audit Trail**:
   - Enable detailed logging
   - Retain logs per compliance requirements
   - Regular security audits

---

## Appendix

### A. SF EC API Query Examples

**Get all active employees:**
```sql
SELECT * FROM User WHERE status = 'Active'
```

**Get employees modified in last 24 hours:**
```sql
SELECT * FROM User WHERE lastModifiedDate > '2024-01-01T00:00:00'
```

**Get specific employee:**
```sql
SELECT * FROM User WHERE userId = 'EMP001'
```

### B. Useful Groovy Script Snippets

**Add custom validation:**
```groovy
// In buildOGPTJson function
if (ogptEmployee.employeeId == null || ogptEmployee.employeeId.isEmpty()) {
    messageLog.addAttachmentAsString("Validation_Error", 
        "Employee missing ID, skipping", "text/plain")
    return // Skip this employee
}
```

**Add custom field:**
```groovy
// Add to ogptEmployee map
customNewField: getFieldValue(employee, 'customXX', 'alternativeName')
```

### C. Contact Information

- **SAP CPI Support**: [Link to support portal]
- **SuccessFactors Support**: [Link to SF support]
- **Integration Team**: [Team contact]

---

## Document Version

- **Version**: 1.0
- **Last Updated**: January 2024
- **Next Review**: April 2024

---

## Change Log

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| Jan 2024 | 1.0 | Initial setup guide | Integration Team |
