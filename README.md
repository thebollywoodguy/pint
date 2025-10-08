# PINT - Platform Integration Tools

## Overview
This repository contains integration tools and scripts for data transformation and synchronization between enterprise systems.

## Current Projects

### SuccessFactors Employee Central to OGPT Integration

A comprehensive Groovy-based integration script for SAP Cloud Platform Integration (CPI) that transforms employee data from SAP SuccessFactors Employee Central SOAP API to OGPT (Operational Platform) JSON format.

## Repository Contents

### Integration Scripts

#### 1. **SFECToOGPTMapping.groovy**
Main Groovy script for SAP CPI that transforms SuccessFactors Employee Central SOAP API responses into OGPT-compatible JSON format.

**Features:**
- Comprehensive field mapping (95+ fields)
- Flexible field resolution with fallback options
- Multiple date format support
- Error handling and logging
- Support for custom Pod and Quota information
- Batch processing capabilities

**Use Cases:**
- Daily employee data synchronization
- Incremental updates based on modification date
- On-demand employee data export
- Real-time employee event processing

### Documentation

#### 2. **GROOVY_MAPPING_README.md**
Complete documentation for the Groovy mapping script including:
- Installation instructions for SAP CPI
- Field mapping specifications
- Usage examples
- Customization guide
- Error handling and troubleshooting
- Testing procedures

#### 3. **FIELD_MAPPING_SPEC.md**
Detailed field-by-field mapping specification (replaces the OGPT_primo.xlsx document):
- 95+ field mappings from SF EC to OGPT
- Data type specifications
- Transformation rules
- Required vs optional fields
- Custom field mappings for Pod and Quota information
- Validation rules

#### 4. **SAP_CPI_SETUP_GUIDE.md**
Step-by-step deployment and configuration guide:
- SAP CPI integration flow setup
- SuccessFactors connection configuration
- Script deployment procedures
- Error handling configuration
- Monitoring and alerts setup
- Performance optimization tips
- Troubleshooting guide

### Sample Data

#### 5. **sample_input.xml**
Sample SuccessFactors Employee Central SOAP API response showing:
- Multiple employee records
- Various employment statuses (Active, Terminated)
- Complete field examples
- Leave information
- Pod and quota data

#### 6. **sample_output.json**
Expected JSON output structure showing:
- OGPT-formatted employee data
- Metadata section
- Properly transformed fields
- Null value handling
- Nested data structures

### Legacy Code

#### 7. **org_exceptions_validations.prc**
PL/SQL procedure for organization exceptions validation (legacy code, retained for reference).

## Quick Start

### For SAP CPI Developers

1. **Review Documentation:**
   - Read `GROOVY_MAPPING_README.md` for overview
   - Review `FIELD_MAPPING_SPEC.md` for field mappings
   - Check `SAP_CPI_SETUP_GUIDE.md` for deployment steps

2. **Set Up Integration Flow:**
   - Create new integration flow in SAP CPI
   - Configure SuccessFactors SOAP connection
   - Add Groovy script step
   - Copy content from `SFECToOGPTMapping.groovy`

3. **Test:**
   - Use `sample_input.xml` for unit testing
   - Verify output matches `sample_output.json` structure
   - Deploy to test environment

4. **Deploy:**
   - Follow deployment checklist in setup guide
   - Configure monitoring and alerts
   - Schedule execution (e.g., daily batch)

### For Data Architects

1. **Review Mappings:**
   - Open `FIELD_MAPPING_SPEC.md`
   - Verify field mappings match your requirements
   - Identify any custom fields needed

2. **Customize:**
   - Update field mappings in the spec
   - Modify `SFECToOGPTMapping.groovy` accordingly
   - Update sample files for testing

3. **Validate:**
   - Test with real data
   - Verify data quality
   - Document any deviations

## Integration Architecture

```
┌─────────────────────────────┐
│  SuccessFactors Employee    │
│  Central (SF EC)             │
│  - SOAP API                  │
└──────────────┬──────────────┘
               │
               │ SOAP XML Response
               │
               ▼
┌─────────────────────────────┐
│  SAP Cloud Platform         │
│  Integration (CPI)           │
│  ┌─────────────────────┐   │
│  │ Groovy Script       │   │
│  │ (Transformation)    │   │
│  └─────────────────────┘   │
└──────────────┬──────────────┘
               │
               │ JSON Output
               │
               ▼
┌─────────────────────────────┐
│  OGPT (Operational          │
│  Platform)                   │
│  - REST API / File Import   │
└─────────────────────────────┘
```

## Field Mapping Overview

### Categories
1. **Core Identification** (3 fields): Employee ID, Person ID, Username
2. **Personal Information** (8 fields): Name, gender, DOB, nationality
3. **Contact Information** (10 fields): Email, phone, address
4. **Employment Information** (10 fields): Hire date, status, employment type
5. **Job Information** (14 fields): Title, department, location, cost center
6. **Manager Information** (4 fields): Manager ID and relationships
7. **Organization Structure** (12 fields): Pod assignments (current, previous, OKR, local, global)
8. **Leave Information** (5 fields): Leave status, dates, type
9. **Quota Information** (8 fields): Pod quotas (current, OKR, local, global)
10. **Compensation** (5 fields): Pay grade, FTE, standard hours
11. **System Fields** (6 fields): Timestamps, status, active flag
12. **Custom Fields** (3 fields): Reserved for future use

**Total: 95+ fields mapped**

## Key Features

### 1. Flexible Field Resolution
The script tries multiple field name variations to handle different SF EC configurations:
```groovy
employeeId: getFieldValue(employee, 'userId', 'personIdExternal', 'employeeId')
```

### 2. Comprehensive Error Handling
- Individual employee processing errors don't halt entire batch
- Missing fields gracefully handled with null values
- Detailed error logging for troubleshooting

### 3. Date Format Flexibility
Supports multiple input date formats:
- `YYYY-MM-DD`
- `MM/DD/YYYY`
- `DD/MM/YYYY`
- ISO 8601 formats with time and timezone

### 4. Pod and Quota Support
Special handling for organization structure:
- Current Pod, Previous Pod, OKR Pod, Local Pod, Global Pod
- Pod effective dates
- Quota values for each pod level

### 5. Audit Trail
Metadata section in output includes:
- Source system identification
- Extraction timestamp
- Record count
- Version information

## Customization

### Adding New Fields

1. **Update Field Mapping Spec** (`FIELD_MAPPING_SPEC.md`):
   - Add new row with field details
   - Specify transformation rules

2. **Modify Groovy Script** (`SFECToOGPTMapping.groovy`):
   - Add field to appropriate section in `buildOGPTJson()`
   - Include fallback field names if needed

3. **Update Sample Files**:
   - Add field to `sample_input.xml`
   - Add expected output to `sample_output.json`

4. **Test**:
   - Validate with test data
   - Update documentation

### Changing Output Structure

Modify the `ogptOutput` structure in `buildOGPTJson()` function to match your OGPT system requirements.

## Testing

### Unit Testing
Use provided sample files:
```bash
Input: sample_input.xml (SF EC SOAP response)
Expected Output: sample_output.json (OGPT JSON)
```

### Integration Testing
1. Deploy to SAP CPI test tenant
2. Connect to SF EC test environment
3. Execute with real data subset
4. Validate output structure and data accuracy

### Performance Testing
Test with various batch sizes:
- Small: 10-50 employees
- Medium: 100-500 employees  
- Large: 1000+ employees

## Monitoring and Support

### Logging
The script logs to SAP CPI message log:
- `Input_SOAP_Response`: Original SF EC XML
- `Output_OGPT_JSON`: Generated JSON
- `Error_Details`: Processing errors
- `Employee_Processing_Error`: Individual employee errors

### Metrics to Monitor
1. Success/failure rate
2. Number of employees processed
3. Execution duration
4. Error patterns
5. Data quality issues

## Prerequisites

### SAP CPI Environment
- SAP Cloud Platform Integration tenant
- Design and deployment permissions
- Groovy script support enabled

### SuccessFactors Access
- SF Employee Central instance
- API user credentials (OAuth or Basic Auth)
- Required permissions:
  - Read employee data
  - Execute SOAP queries

### OGPT System
- Target endpoint (REST API or file location)
- Authentication credentials (if applicable)
- JSON schema validation (optional)

## Security Considerations

1. **Credentials**: Use SAP CPI Security Material for storing credentials
2. **Data Privacy**: Mask sensitive fields in logs if required
3. **Encryption**: Use HTTPS for all API communications
4. **Access Control**: Limit integration flow access to authorized users
5. **Audit**: Enable comprehensive logging for compliance

## Troubleshooting

Common issues and solutions documented in:
- `GROOVY_MAPPING_README.md` - Section: "Monitoring and Debugging"
- `SAP_CPI_SETUP_GUIDE.md` - Section: "Troubleshooting Guide"

Quick tips:
- Check message logs in SAP CPI Monitor
- Verify SF EC connection and credentials
- Validate SOAP response structure
- Review field name mappings
- Check date format compatibility

## Contributing

When updating this integration:
1. Update field mapping specification first
2. Modify Groovy script accordingly
3. Update sample files
4. Test thoroughly
5. Update documentation
6. Version control all changes

## Version History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | January 2024 | Initial release with 95+ field mappings |

## License

This integration code is provided for use within SAP CPI environments for SuccessFactors to OGPT data synchronization.

## Authors

- Integration Team
- Based on OGPT Primo mapping specification

## References

- [SAP SuccessFactors Employee Central Documentation](https://help.sap.com/viewer/product/SAP_SUCCESSFACTORS_EMPLOYEE_CENTRAL/)
- [SAP Cloud Platform Integration Documentation](https://help.sap.com/viewer/product/CLOUD_INTEGRATION/)
- [Groovy Language Documentation](https://groovy-lang.org/documentation.html)

## Support

For questions or issues:
1. Check documentation in this repository
2. Review SAP CPI message logs
3. Consult SAP CPI support
4. Contact your SuccessFactors administrator

---

**Last Updated:** January 2024  
**Maintained By:** Platform Integration Team