# SuccessFactors EC to OGPT Mapping - Groovy Script for SAP CPI

## Overview

This Groovy script transforms data from SuccessFactors Employee Central (SF EC) SOAP API responses into OGPT (Operational Platform) JSON format. It's designed to be used within SAP Cloud Platform Integration (CPI) workflows.

## Purpose

The script processes employee data fetched from the SuccessFactors Employee Central Compound Employee API and creates a standardized JSON output compatible with OGPT systems.

## Features

- **Comprehensive Field Mapping**: Maps standard SF EC employee fields to OGPT JSON structure
- **Flexible Field Resolution**: Tries multiple field name variations to handle different SF EC configurations
- **Error Handling**: Graceful handling of missing fields and parsing errors
- **Date Formatting**: Standardizes date formats from various SF EC date representations
- **Logging**: Detailed logging for debugging and troubleshooting
- **Multi-Employee Processing**: Handles batch processing of multiple employees

## Script Components

### Main Function
- `processData(Message message)`: Main entry point that processes the SOAP response

### Helper Functions
- `buildOGPTJson()`: Constructs the OGPT JSON structure from employee data
- `getFieldValue()`: Retrieves field values with fallback options
- `formatDate()`: Standardizes date formats
- `formatDateTime()`: Standardizes datetime formats
- `parseBoolean()`: Converts string values to boolean
- `parseDecimal()`: Converts string values to decimal/double

## Input Format

The script expects a SOAP XML response from SuccessFactors Employee Central API, typically from:
- Compound Employee API
- Employee Export API
- Query API for Employee data

Example input structure:
```xml
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <queryResponse>
      <User>
        <userId>12345</userId>
        <firstName>John</firstName>
        <lastName>Doe</lastName>
        <email>john.doe@example.com</email>
        <!-- Additional employee fields -->
      </User>
      <!-- More employees -->
    </queryResponse>
  </soap:Body>
</soap:Envelope>
```

## Output Format

The script produces a JSON structure with the following sections:

```json
{
  "metadata": {
    "source": "SuccessFactors Employee Central",
    "extractionDate": "2024-01-01T12:00:00Z",
    "recordCount": 100,
    "version": "1.0"
  },
  "employees": [
    {
      "employeeId": "12345",
      "personId": "67890",
      "username": "jdoe",
      "personalInfo": {
        "firstName": "John",
        "lastName": "Doe",
        "displayName": "John Doe",
        "email": "john.doe@example.com"
      },
      "employmentInfo": {
        "hireDate": "2020-01-15",
        "employmentStatus": "Active",
        "employmentType": "Full-time"
      },
      "jobInfo": {
        "title": "Software Engineer",
        "department": "Engineering",
        "location": "San Francisco"
      },
      "managerInfo": {
        "managerId": "54321",
        "managerName": "Jane Smith"
      },
      "organizationInfo": {
        "currentPod": "Engineering Pod A",
        "okrPod": "Product Engineering",
        "localPod": "SF Engineering",
        "globalPod": "Global Tech"
      },
      "leaveInfo": {
        "onLeave": false,
        "onPaidLeave": false
      },
      "quotaInfo": {
        "currentPodQuota": 100.0,
        "okrPodQuota": 50.0
      }
    }
  ]
}
```

## Field Mappings

### Core Identification
| SF EC Field | OGPT Field | Description |
|------------|------------|-------------|
| userId, personIdExternal, employeeId | employeeId | Unique employee identifier |
| personIdExternal, personId | personId | Person ID in the system |
| username, userId | username | Login username |

### Personal Information
| SF EC Field | OGPT Field | Description |
|------------|------------|-------------|
| firstName, defaultFullName | personalInfo.firstName | First name |
| lastName | personalInfo.lastName | Last name |
| middleName | personalInfo.middleName | Middle name |
| email, businessEmail | contactInfo.email | Primary email |

### Employment Information
| SF EC Field | OGPT Field | Description |
|------------|------------|-------------|
| hireDate, startDate | employmentInfo.hireDate | Date of hire |
| terminationDate, endDate | employmentInfo.terminationDate | Termination date |
| status, empStatus | employmentInfo.employmentStatus | Employment status |

### Job Information
| SF EC Field | OGPT Field | Description |
|------------|------------|-------------|
| title, jobTitle | jobInfo.title | Job title |
| department | jobInfo.department | Department |
| location, workLocation | jobInfo.location | Work location |
| costCenter | jobInfo.costCenter | Cost center |

### Organization Structure (Custom Fields)
| SF EC Field | OGPT Field | Description |
|------------|------------|-------------|
| custom01, currentPod | organizationInfo.currentPod | Current Pod assignment |
| custom02, previousPod | organizationInfo.previousPod | Previous Pod |
| custom03, okrPod | organizationInfo.okrPod | OKR Pod |
| custom04, localPod | organizationInfo.localPod | Local Pod |
| custom05, globalPod | organizationInfo.globalPod | Global Pod |
| custom06, podEffectiveDate | organizationInfo.podEffectiveDate | Pod effective date |

### Leave Information
| SF EC Field | OGPT Field | Description |
|------------|------------|-------------|
| custom07, onPaidLeave | leaveInfo.onPaidLeave | On paid leave status |
| custom08, leaveStartDate | leaveInfo.leaveStartDate | Leave start date |
| custom09, leaveEndDate | leaveInfo.leaveEndDate | Leave end date |

### Quota Information
| SF EC Field | OGPT Field | Description |
|------------|------------|-------------|
| custom10, currentPodQuota | quotaInfo.currentPodQuota | Current Pod quota |
| custom11, okrPodQuota | quotaInfo.okrPodQuota | OKR Pod quota |
| custom12, localPodQuota | quotaInfo.localPodQuota | Local Pod quota |
| custom13, globalPodQuota | quotaInfo.globalPodQuota | Global Pod quota |

## Installation in SAP CPI

### Step 1: Create Integration Flow
1. Log in to SAP Cloud Platform Integration tenant
2. Navigate to Design workspace
3. Create a new Integration Flow or edit an existing one

### Step 2: Add Script Step
1. Add a "Script" step in your integration flow (after the SOAP API call)
2. Select "Groovy Script" as the script type
3. Copy and paste the content of `SFECToOGPTMapping.groovy`

### Step 3: Configure Flow
```
[SOAP Sender/Receiver] → [SF EC API Call] → [Groovy Script] → [Target System/File]
```

### Step 4: Deploy and Test
1. Save the integration flow
2. Deploy to runtime
3. Test with sample SF EC SOAP responses

## Usage Example

### In SAP CPI Integration Flow

1. **Configure SF EC Connection**:
   - Set up SOAP adapter for SuccessFactors Employee Central
   - Configure authentication (OAuth 2.0 or Basic Auth)
   - Define the query or export parameters

2. **Add Groovy Script**:
   - Insert the Groovy script after the SF EC API response
   - The script automatically processes the SOAP XML response

3. **Route Output**:
   - Send the JSON output to target system
   - Save to file system
   - Send via REST API to OGPT system

## Customization

### Adding Custom Fields

To add additional custom fields to the mapping:

```groovy
// In the buildOGPTJson function, add to ogptEmployee map:
customFields: [
    custom14: getFieldValue(employee, 'custom14'),
    custom15: getFieldValue(employee, 'custom15'),
    myNewField: getFieldValue(employee, 'customFieldName')
]
```

### Modifying Field Names

Update the field name arrays in `getFieldValue()` calls:

```groovy
// Original
employeeId: getFieldValue(employee, 'userId', 'personIdExternal', 'employeeId'),

// Modified to include additional variants
employeeId: getFieldValue(employee, 'userId', 'personIdExternal', 'employeeId', 'empId'),
```

### Changing Date Formats

Modify the date formatters:

```groovy
// Change output format
def dateFormatter = new SimpleDateFormat("dd-MM-yyyy")  // European format
def dateTimeFormatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")  // Without timezone
```

## Error Handling

The script includes comprehensive error handling:

1. **Individual Employee Errors**: If processing one employee fails, others continue
2. **Field Parsing Errors**: Missing or invalid fields are set to null
3. **Date Parsing**: Falls back to original string if parsing fails
4. **Logging**: All errors are logged in message log attachments

## Monitoring and Debugging

### View Logs in SAP CPI

1. Navigate to Monitor → Integrations
2. Find your integration flow execution
3. Check Message Processing Logs
4. Review attachments:
   - `Input_SOAP_Response`: Original SOAP XML
   - `Output_OGPT_JSON`: Generated JSON
   - `Error_Details`: Any processing errors
   - `Employee_Processing_Error`: Individual employee errors

### Common Issues

1. **No employees found**:
   - Check XML structure and element names
   - Verify namespace handling
   - Review SOAP response format

2. **Missing fields**:
   - Verify field names match SF EC configuration
   - Add field name variants in `getFieldValue()` calls
   - Check custom field mappings

3. **Date format errors**:
   - Add additional date formats to `formatDate()` function
   - Check SF EC date format settings

## Testing

### Test with Sample Data

Create a test SOAP response:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <queryResponse>
      <User>
        <userId>12345</userId>
        <firstName>John</firstName>
        <lastName>Doe</lastName>
        <email>john.doe@example.com</email>
        <hireDate>2020-01-15</hireDate>
        <title>Software Engineer</title>
        <department>Engineering</department>
        <custom01>Engineering Pod A</custom01>
        <custom03>Product Engineering</custom03>
      </User>
    </queryResponse>
  </soap:Body>
</soap:Envelope>
```

## Version History

- **v1.0** (Initial Release)
  - Basic SF EC to OGPT mapping
  - Support for standard employee fields
  - Custom field mapping for Pod and Quota information
  - Comprehensive error handling and logging

## Support and Maintenance

### Updating Field Mappings

When SuccessFactors configuration changes:
1. Review the new field names in SF EC
2. Update `getFieldValue()` parameters
3. Test with sample data
4. Deploy updated version

### Performance Considerations

- Script processes employees sequentially
- For large batches (>1000 employees), consider:
  - Implementing pagination in SF EC query
  - Processing in smaller batches
  - Using parallel processing if supported

## License

This script is provided as-is for integration purposes within SAP CPI environments.

## Authors

- Created for OGPT-Primo Integration Project
- Based on SuccessFactors Employee Central API specifications

## References

- [SAP SuccessFactors Employee Central Documentation](https://help.sap.com/viewer/product/SAP_SUCCESSFACTORS_EMPLOYEE_CENTRAL/)
- [SAP Cloud Platform Integration Documentation](https://help.sap.com/viewer/product/CLOUD_INTEGRATION/)
- [Groovy Documentation](https://groovy-lang.org/documentation.html)

## Contact

For questions or issues related to this mapping script, please refer to the project repository or contact your SAP CPI administrator.
