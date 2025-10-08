# Field Mapping Configuration: SuccessFactors EC to OGPT

## Document Information
- **Project**: OGPT Primo Integration
- **Source System**: SAP SuccessFactors Employee Central (SF EC)
- **Target System**: OGPT (Operational Platform)
- **Integration Method**: SAP Cloud Platform Integration (CPI) with Groovy Script
- **API Type**: SF EC SOAP API (Compound Employee API)
- **Date**: January 2024
- **Version**: 1.0

---

## Core Employee Identification

| #  | SF EC Field Name | SF EC Field Type | OGPT JSON Path | OGPT Data Type | Required | Transformation Rules | Notes |
|----|-----------------|------------------|----------------|----------------|----------|---------------------|-------|
| 1  | userId | String | employeeId | String | Yes | Direct mapping, trim whitespace | Primary employee identifier |
| 2  | personIdExternal | String | personId | String | Yes | Direct mapping, fallback to personId | Person record identifier |
| 3  | username | String | username | String | Yes | Direct mapping, lowercase | Login username |

---

## Personal Information Section

| #  | SF EC Field Name | SF EC Field Type | OGPT JSON Path | OGPT Data Type | Required | Transformation Rules | Notes |
|----|-----------------|------------------|----------------|----------------|----------|---------------------|-------|
| 4  | firstName | String | personalInfo.firstName | String | Yes | Trim whitespace, proper case | Employee first name |
| 5  | lastName | String | personalInfo.lastName | String | Yes | Trim whitespace, proper case | Employee last name |
| 6  | middleName | String | personalInfo.middleName | String | No | Trim whitespace | Middle name if available |
| 7  | displayName | String | personalInfo.displayName | String | Yes | Fallback to firstName + lastName | Display name for UI |
| 8  | preferredName | String | personalInfo.preferredName | String | No | Direct mapping | Preferred/nickname |
| 9  | gender | String | personalInfo.gender | String | No | Direct mapping | Gender code |
| 10 | dateOfBirth | Date | personalInfo.dateOfBirth | Date | No | Format: YYYY-MM-DD | Date of birth |
| 11 | nationality | String | personalInfo.nationality | String | No | Direct mapping | Nationality code |

---

## Contact Information Section

| #  | SF EC Field Name | SF EC Field Type | OGPT JSON Path | OGPT Data Type | Required | Transformation Rules | Notes |
|----|-----------------|------------------|----------------|----------------|----------|---------------------|-------|
| 12 | email | String | contactInfo.email | String | Yes | Lowercase, validate format | Primary email address |
| 13 | businessEmail | String | contactInfo.email | String | Yes | Fallback if email is empty | Business email |
| 14 | businessPhone | String | contactInfo.phoneNumber | String | No | Direct mapping | Business phone |
| 15 | cellPhone | String | contactInfo.mobilePhone | String | No | Direct mapping | Mobile/cell phone |
| 16 | address1 | String | contactInfo.addressLine1 | String | No | Trim whitespace | Address line 1 |
| 17 | address2 | String | contactInfo.addressLine2 | String | No | Trim whitespace | Address line 2 |
| 18 | city | String | contactInfo.city | String | No | Trim whitespace | City |
| 19 | state | String | contactInfo.state | String | No | Uppercase | State/Province code |
| 20 | zipCode | String | contactInfo.postalCode | String | No | Trim whitespace | Postal/ZIP code |
| 21 | country | String | contactInfo.country | String | No | Uppercase country code | Country |

---

## Employment Information Section

| #  | SF EC Field Name | SF EC Field Type | OGPT JSON Path | OGPT Data Type | Required | Transformation Rules | Notes |
|----|-----------------|------------------|----------------|----------------|----------|---------------------|-------|
| 22 | hireDate | Date | employmentInfo.hireDate | Date | Yes | Format: YYYY-MM-DD | Original hire date |
| 23 | startDate | Date | employmentInfo.hireDate | Date | Yes | Fallback if hireDate empty | Employment start date |
| 24 | terminationDate | Date | employmentInfo.terminationDate | Date | No | Format: YYYY-MM-DD, null if active | Termination date |
| 25 | endDate | Date | employmentInfo.terminationDate | Date | No | Fallback for termination | End date |
| 26 | status | String | employmentInfo.employmentStatus | String | Yes | Direct mapping | Active/Terminated/On Leave |
| 27 | empStatus | String | employmentInfo.employmentStatus | String | Yes | Fallback status field | Employment status |
| 28 | employeeClass | String | employmentInfo.employeeClass | String | No | Direct mapping | Full-time/Part-time/Contractor |
| 29 | employmentType | String | employmentInfo.employmentType | String | No | Direct mapping | Employment type |
| 30 | seniorityDate | Date | employmentInfo.seniorityDate | Date | No | Format: YYYY-MM-DD | Seniority calculation date |
| 31 | originalStartDate | Date | employmentInfo.originalStartDate | Date | No | Format: YYYY-MM-DD | Original start with company |

---

## Job Information Section

| #  | SF EC Field Name | SF EC Field Type | OGPT JSON Path | OGPT Data Type | Required | Transformation Rules | Notes |
|----|-----------------|------------------|----------------|----------------|----------|---------------------|-------|
| 32 | title | String | jobInfo.title | String | Yes | Trim whitespace | Job title |
| 33 | jobTitle | String | jobInfo.title | String | Yes | Fallback if title empty | Job title alternate |
| 34 | businessTitle | String | jobInfo.title | String | Yes | Second fallback | Business title |
| 35 | jobCode | String | jobInfo.jobCode | String | No | Uppercase | Job classification code |
| 36 | jobLevel | String | jobInfo.jobLevel | String | No | Direct mapping | Job level/grade |
| 37 | businessUnit | String | jobInfo.businessUnit | String | No | Trim whitespace | Business unit |
| 38 | department | String | jobInfo.department | String | Yes | Trim whitespace | Department name |
| 39 | division | String | jobInfo.division | String | No | Trim whitespace | Division name |
| 40 | location | String | jobInfo.location | String | Yes | Trim whitespace | Work location |
| 41 | workLocation | String | jobInfo.location | String | Yes | Fallback location | Work location alternate |
| 42 | costCenter | String | jobInfo.costCenter | String | No | Trim whitespace | Cost center code |
| 43 | company | String | jobInfo.company | String | Yes | Trim whitespace | Legal entity/company |
| 44 | legalEntity | String | jobInfo.company | String | Yes | Fallback company | Legal entity alternate |
| 45 | effectiveDate | Date | jobInfo.effectiveDate | Date | No | Format: YYYY-MM-DD | Job info effective date |

---

## Manager Information Section

| #  | SF EC Field Name | SF EC Field Type | OGPT JSON Path | OGPT Data Type | Required | Transformation Rules | Notes |
|----|-----------------|------------------|----------------|----------------|----------|---------------------|-------|
| 46 | managerId | String | managerInfo.managerId | String | No | Direct mapping | Manager employee ID |
| 47 | manager | String | managerInfo.managerId | String | No | Fallback manager ID | Manager alternate field |
| 48 | managerName | String | managerInfo.managerName | String | No | Trim whitespace | Manager display name |
| 49 | directManager | String | managerInfo.directManager | String | No | Direct mapping | Direct manager ID |
| 50 | matrixManager | String | managerInfo.matrixManager | String | No | Direct mapping | Matrix/dotted line manager |

---

## Organization Structure (Custom Fields - Pod Information)

| #  | SF EC Field Name | SF EC Field Type | OGPT JSON Path | OGPT Data Type | Required | Transformation Rules | Notes |
|----|-----------------|------------------|----------------|----------------|----------|---------------------|-------|
| 51 | custom01 | String | organizationInfo.currentPod | String | No | Trim whitespace | Current Pod assignment |
| 52 | currentPod | String | organizationInfo.currentPod | String | No | Fallback custom01 | Current Pod alternate |
| 53 | custom02 | String | organizationInfo.previousPod | String | No | Trim whitespace | Previous Pod |
| 54 | previousPod | String | organizationInfo.previousPod | String | No | Fallback custom02 | Previous Pod alternate |
| 55 | custom03 | String | organizationInfo.okrPod | String | No | Trim whitespace | OKR Pod assignment |
| 56 | okrPod | String | organizationInfo.okrPod | String | No | Fallback custom03 | OKR Pod alternate |
| 57 | custom04 | String | organizationInfo.localPod | String | No | Trim whitespace | Local Pod |
| 58 | localPod | String | organizationInfo.localPod | String | No | Fallback custom04 | Local Pod alternate |
| 59 | custom05 | String | organizationInfo.globalPod | String | No | Trim whitespace | Global Pod |
| 60 | globalPod | String | organizationInfo.globalPod | String | No | Fallback custom05 | Global Pod alternate |
| 61 | custom06 | Date | organizationInfo.podEffectiveDate | Date | No | Format: YYYY-MM-DD | Pod assignment effective date |
| 62 | podEffectiveDate | String | organizationInfo.podEffectiveDate | Date | No | Fallback custom06 | Pod effective date alternate |

---

## Leave Information (Custom Fields)

| #  | SF EC Field Name | SF EC Field Type | OGPT JSON Path | OGPT Data Type | Required | Transformation Rules | Notes |
|----|-----------------|------------------|----------------|----------------|----------|---------------------|-------|
| 63 | onLeave | Boolean | leaveInfo.onLeave | Boolean | No | Convert to true/false | On leave flag |
| 64 | isOnLeave | Boolean | leaveInfo.onLeave | Boolean | No | Fallback on leave | On leave alternate |
| 65 | custom07 | String | leaveInfo.onPaidLeave | Boolean | No | Convert to boolean | On paid leave flag |
| 66 | onPaidLeave | Boolean | leaveInfo.onPaidLeave | Boolean | No | Fallback custom07 | Paid leave alternate |
| 67 | custom08 | Date | leaveInfo.leaveStartDate | Date | No | Format: YYYY-MM-DD | Leave start date |
| 68 | leaveStartDate | Date | leaveInfo.leaveStartDate | Date | No | Fallback custom08 | Leave start alternate |
| 69 | custom09 | Date | leaveInfo.leaveEndDate | Date | No | Format: YYYY-MM-DD | Leave end date |
| 70 | leaveEndDate | Date | leaveInfo.leaveEndDate | Date | No | Fallback custom09 | Leave end alternate |
| 71 | leaveType | String | leaveInfo.leaveType | String | No | Direct mapping | Type of leave |

---

## Quota Information (Custom Fields)

| #  | SF EC Field Name | SF EC Field Type | OGPT JSON Path | OGPT Data Type | Required | Transformation Rules | Notes |
|----|-----------------|------------------|----------------|----------------|----------|---------------------|-------|
| 72 | custom10 | Number | quotaInfo.currentPodQuota | Number | No | Convert to decimal | Current Pod quota value |
| 73 | currentPodQuota | Number | quotaInfo.currentPodQuota | Number | No | Fallback custom10 | Current Pod quota alternate |
| 74 | custom11 | Number | quotaInfo.okrPodQuota | Number | No | Convert to decimal | OKR Pod quota |
| 75 | okrPodQuota | Number | quotaInfo.okrPodQuota | Number | No | Fallback custom11 | OKR Pod quota alternate |
| 76 | custom12 | Number | quotaInfo.localPodQuota | Number | No | Convert to decimal | Local Pod quota |
| 77 | localPodQuota | Number | quotaInfo.localPodQuota | Number | No | Fallback custom12 | Local Pod quota alternate |
| 78 | custom13 | Number | quotaInfo.globalPodQuota | Number | No | Convert to decimal | Global Pod quota |
| 79 | globalPodQuota | Number | quotaInfo.globalPodQuota | Number | No | Fallback custom13 | Global Pod quota alternate |

---

## Compensation Information

| #  | SF EC Field Name | SF EC Field Type | OGPT JSON Path | OGPT Data Type | Required | Transformation Rules | Notes |
|----|-----------------|------------------|----------------|----------------|----------|---------------------|-------|
| 80 | payGrade | String | compensationInfo.payGrade | String | No | Direct mapping | Pay grade level |
| 81 | payGroup | String | compensationInfo.payGroup | String | No | Direct mapping | Payroll group |
| 82 | fte | Number | compensationInfo.fte | Number | No | Convert to decimal (0.0-1.0) | Full-time equivalent |
| 83 | fullTimeEquivalent | Number | compensationInfo.fte | Number | No | Fallback FTE | FTE alternate |
| 84 | standardHours | Number | compensationInfo.standardHours | Number | No | Convert to decimal | Standard working hours |

---

## System/Metadata Fields

| #  | SF EC Field Name | SF EC Field Type | OGPT JSON Path | OGPT Data Type | Required | Transformation Rules | Notes |
|----|-----------------|------------------|----------------|----------------|----------|---------------------|-------|
| 85 | lastModifiedDate | DateTime | systemInfo.lastModifiedDate | DateTime | No | Format: YYYY-MM-DDTHH:mm:ssZ | Last modification timestamp |
| 86 | lastModified | DateTime | systemInfo.lastModifiedDate | DateTime | No | Fallback last modified | Last modified alternate |
| 87 | createdDate | DateTime | systemInfo.createdDate | DateTime | No | Format: YYYY-MM-DDTHH:mm:ssZ | Record creation date |
| 88 | createDate | DateTime | systemInfo.createdDate | DateTime | No | Fallback created | Created date alternate |
| 89 | status | String | systemInfo.status | String | Yes | Direct mapping | Record status |
| 90 | isActive | Boolean | systemInfo.isActive | Boolean | No | Convert to true/false | Active flag |
| 91 | active | Boolean | systemInfo.isActive | Boolean | No | Fallback active | Active alternate |

---

## Additional Custom Fields

| #  | SF EC Field Name | SF EC Field Type | OGPT JSON Path | OGPT Data Type | Required | Transformation Rules | Notes |
|----|-----------------|------------------|----------------|----------------|----------|---------------------|-------|
| 92 | custom14 | String | customFields.custom14 | String | No | Direct mapping | Reserved for future use |
| 93 | custom15 | String | customFields.custom15 | String | No | Direct mapping | Reserved for future use |
| 94 | custom16 | Date | customFields.vcEffectiveDate | Date | No | Format: YYYY-MM-DD | VC effective date |
| 95 | vcEffectiveDate | Date | customFields.vcEffectiveDate | Date | No | Fallback custom16 | VC effective date alternate |

---

## Data Transformation Rules

### Date Formatting
- **Input Formats Supported**: 
  - `YYYY-MM-DD`
  - `MM/DD/YYYY`
  - `DD/MM/YYYY`
  - `YYYY-MM-DDTHH:mm:ss`
  - `YYYY-MM-DDTHH:mm:ssZ`
- **Output Format**: `YYYY-MM-DD` for dates, `YYYY-MM-DDTHH:mm:ssZ` for datetimes

### Boolean Conversion
- **True values**: `true`, `1`, `yes`, `y`, `t` (case-insensitive)
- **False values**: `false`, `0`, `no`, `n`, `f` (case-insensitive)
- **Null handling**: Empty or null values remain null

### Number Conversion
- **Decimal precision**: 2 decimal places for currency/quota values
- **FTE range**: 0.0 to 1.0
- **Null handling**: Invalid numbers convert to null

### String Handling
- **Trimming**: All strings trimmed of leading/trailing whitespace
- **Case**: Preserved unless specified (e.g., email lowercase)
- **Null handling**: Empty strings convert to null

---

## API Configuration

### SF EC SOAP API Endpoint
```
https://{datacenter}.successfactors.com/sfapi/v1/soap
```

### Authentication
- **Method**: OAuth 2.0 or Basic Authentication
- **Required Scopes**: Employee data read access

### Query Filter Examples
```xml
<!-- All active employees -->
<filter>status eq 'Active'</filter>

<!-- Employees modified after date -->
<filter>lastModifiedDate gt '2024-01-01T00:00:00'</filter>

<!-- Specific employee by ID -->
<filter>userId eq 'EMP001'</filter>
```

---

## OGPT JSON Output Structure

```json
{
  "metadata": {
    "source": "SuccessFactors Employee Central",
    "extractionDate": "YYYY-MM-DDTHH:mm:ssZ",
    "recordCount": <number>,
    "version": "1.0"
  },
  "employees": [
    {
      "employeeId": "<string>",
      "personId": "<string>",
      "username": "<string>",
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

## Error Handling

### Missing Required Fields
- If a required field is missing, set to null and log warning
- Continue processing other employees

### Invalid Data Types
- Log conversion error
- Set field to null
- Continue processing

### Parsing Errors
- Log error with employee ID
- Skip problematic employee
- Continue with next employee

---

## Validation Rules

1. **Employee ID**: Must be present and non-empty
2. **Email**: Must be valid email format
3. **Dates**: Must be valid dates, hire date <= termination date
4. **Status**: Must be one of: Active, Terminated, On Leave
5. **FTE**: Must be between 0.0 and 1.0

---

## Notes

- Custom fields (custom01-custom16) are organization-specific and map to Pod and Quota information
- Field names are case-insensitive during lookup
- Multiple fallback options ensure data capture from various SF EC configurations
- All null values are explicitly preserved in JSON output
- Metadata section provides audit trail and record count

---

## Version Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | January 2024 | Integration Team | Initial mapping specification |

---

## References

- SAP SuccessFactors Employee Central API Documentation
- OGPT Data Integration Specifications
- SAP CPI Groovy Script Development Guide
