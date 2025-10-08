/*
 * SAP Cloud Platform Integration (CPI) Groovy Script
 * Purpose: Transform SuccessFactors Employee Central SOAP API Response to OGPT JSON Format
 * 
 * This script processes employee data from SF EC Compound Employee API and creates
 * OGPT-compatible JSON output for integration workflows.
 * 
 * Input: SOAP XML Response from SuccessFactors Employee Central API
 * Output: JSON formatted data for OGPT (Operational Platform)
 */

import com.sap.gateway.ip.core.customdev.util.Message
import groovy.xml.XmlSlurper
import groovy.json.JsonBuilder
import groovy.json.JsonOutput
import java.text.SimpleDateFormat

def Message processData(Message message) {
    
    // Get message body as String
    def body = message.getBody(String.class)
    def messageLog = messageLogFactory.getMessageLog(message)
    
    try {
        // Log incoming message
        messageLog.addAttachmentAsString("Input_SOAP_Response", body, "text/xml")
        
        // Parse SOAP XML response
        def soapResponse = new XmlSlurper().parseText(body)
        
        // Navigate to employee data (adjust namespace and path based on actual SOAP structure)
        def employees = soapResponse.'**'.findAll { it.name() == 'User' || it.name() == 'Employee' }
        
        // Create OGPT JSON structure
        def ogptData = buildOGPTJson(employees, messageLog)
        
        // Convert to JSON
        def jsonOutput = JsonOutput.prettyPrint(JsonOutput.toJson(ogptData))
        
        // Log output
        messageLog.addAttachmentAsString("Output_OGPT_JSON", jsonOutput, "application/json")
        
        // Set the transformed JSON as message body
        message.setBody(jsonOutput)
        message.setHeader("Content-Type", "application/json")
        
    } catch (Exception e) {
        messageLog.setLogLevel("ERROR")
        messageLog.addAttachmentAsString("Error_Details", 
            "Error processing SF EC to OGPT transformation: " + e.message + "\n" + 
            "Stack trace: " + e.stackTrace.join("\n"), "text/plain")
        throw e
    }
    
    return message
}

/**
 * Build OGPT JSON structure from employee data
 */
def buildOGPTJson(employees, messageLog) {
    def ogptEmployees = []
    def dateFormatter = new SimpleDateFormat("yyyy-MM-dd")
    def dateTimeFormatter = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
    
    employees.each { employee ->
        try {
            def ogptEmployee = [
                // Core Identification Fields
                employeeId: getFieldValue(employee, 'userId', 'personIdExternal', 'employeeId'),
                personId: getFieldValue(employee, 'personIdExternal', 'personId'),
                username: getFieldValue(employee, 'username', 'userId'),
                
                // Personal Information
                personalInfo: [
                    firstName: getFieldValue(employee, 'firstName', 'defaultFullName'),
                    lastName: getFieldValue(employee, 'lastName'),
                    middleName: getFieldValue(employee, 'middleName'),
                    displayName: getFieldValue(employee, 'displayName', 'defaultFullName'),
                    preferredName: getFieldValue(employee, 'preferredName'),
                    gender: getFieldValue(employee, 'gender'),
                    dateOfBirth: formatDate(getFieldValue(employee, 'dateOfBirth'), dateFormatter),
                    nationality: getFieldValue(employee, 'nationality')
                ],
                
                // Contact Information
                contactInfo: [
                    email: getFieldValue(employee, 'email', 'businessEmail', 'emailAddress'),
                    phoneNumber: getFieldValue(employee, 'phoneNumber', 'businessPhone'),
                    mobilePhone: getFieldValue(employee, 'mobilePhone', 'cellPhone'),
                    addressLine1: getFieldValue(employee, 'addressLine1', 'address1'),
                    addressLine2: getFieldValue(employee, 'addressLine2', 'address2'),
                    city: getFieldValue(employee, 'city'),
                    state: getFieldValue(employee, 'state', 'province'),
                    postalCode: getFieldValue(employee, 'postalCode', 'zipCode'),
                    country: getFieldValue(employee, 'country')
                ],
                
                // Employment Information
                employmentInfo: [
                    hireDate: formatDate(getFieldValue(employee, 'hireDate', 'startDate'), dateFormatter),
                    terminationDate: formatDate(getFieldValue(employee, 'terminationDate', 'endDate'), dateFormatter),
                    employmentStatus: getFieldValue(employee, 'status', 'empStatus'),
                    employeeClass: getFieldValue(employee, 'employeeClass', 'empClass'),
                    employmentType: getFieldValue(employee, 'employmentType', 'empType'),
                    seniorityDate: formatDate(getFieldValue(employee, 'seniorityDate'), dateFormatter),
                    originalStartDate: formatDate(getFieldValue(employee, 'originalStartDate'), dateFormatter)
                ],
                
                // Job Information
                jobInfo: [
                    title: getFieldValue(employee, 'title', 'jobTitle', 'businessTitle'),
                    jobCode: getFieldValue(employee, 'jobCode'),
                    jobLevel: getFieldValue(employee, 'jobLevel'),
                    businessUnit: getFieldValue(employee, 'businessUnit'),
                    department: getFieldValue(employee, 'department'),
                    division: getFieldValue(employee, 'division'),
                    location: getFieldValue(employee, 'location', 'workLocation'),
                    costCenter: getFieldValue(employee, 'costCenter'),
                    company: getFieldValue(employee, 'company', 'legalEntity'),
                    effectiveDate: formatDate(getFieldValue(employee, 'effectiveDate', 'startDate'), dateFormatter)
                ],
                
                // Manager Information
                managerInfo: [
                    managerId: getFieldValue(employee, 'managerId', 'manager'),
                    managerName: getFieldValue(employee, 'managerName'),
                    directManager: getFieldValue(employee, 'directManager'),
                    matrixManager: getFieldValue(employee, 'matrixManager')
                ],
                
                // Organization Structure
                organizationInfo: [
                    currentPod: getFieldValue(employee, 'custom01', 'currentPod'),
                    previousPod: getFieldValue(employee, 'custom02', 'previousPod'),
                    okrPod: getFieldValue(employee, 'custom03', 'okrPod'),
                    localPod: getFieldValue(employee, 'custom04', 'localPod'),
                    globalPod: getFieldValue(employee, 'custom05', 'globalPod'),
                    podEffectiveDate: formatDate(getFieldValue(employee, 'custom06', 'podEffectiveDate'), dateFormatter)
                ],
                
                // Leave Information
                leaveInfo: [
                    onLeave: parseBoolean(getFieldValue(employee, 'onLeave', 'isOnLeave')),
                    onPaidLeave: parseBoolean(getFieldValue(employee, 'custom07', 'onPaidLeave')),
                    leaveStartDate: formatDate(getFieldValue(employee, 'custom08', 'leaveStartDate'), dateFormatter),
                    leaveEndDate: formatDate(getFieldValue(employee, 'custom09', 'leaveEndDate'), dateFormatter),
                    leaveType: getFieldValue(employee, 'leaveType')
                ],
                
                // Quota Information (if applicable)
                quotaInfo: [
                    currentPodQuota: parseDecimal(getFieldValue(employee, 'custom10', 'currentPodQuota')),
                    okrPodQuota: parseDecimal(getFieldValue(employee, 'custom11', 'okrPodQuota')),
                    localPodQuota: parseDecimal(getFieldValue(employee, 'custom12', 'localPodQuota')),
                    globalPodQuota: parseDecimal(getFieldValue(employee, 'custom13', 'globalPodQuota'))
                ],
                
                // Compensation Information (if needed)
                compensationInfo: [
                    payGrade: getFieldValue(employee, 'payGrade'),
                    payGroup: getFieldValue(employee, 'payGroup'),
                    fte: parseDecimal(getFieldValue(employee, 'fte', 'fullTimeEquivalent')),
                    standardHours: parseDecimal(getFieldValue(employee, 'standardHours'))
                ],
                
                // System Fields
                systemInfo: [
                    lastModifiedDate: formatDateTime(getFieldValue(employee, 'lastModifiedDate', 'lastModified'), dateTimeFormatter),
                    createdDate: formatDateTime(getFieldValue(employee, 'createdDate', 'createDate'), dateTimeFormatter),
                    status: getFieldValue(employee, 'status'),
                    isActive: parseBoolean(getFieldValue(employee, 'isActive', 'active'))
                ],
                
                // Additional Custom Fields
                customFields: [
                    custom14: getFieldValue(employee, 'custom14'),
                    custom15: getFieldValue(employee, 'custom15'),
                    vcEffectiveDate: formatDate(getFieldValue(employee, 'custom16', 'vcEffectiveDate'), dateFormatter)
                ]
            ]
            
            ogptEmployees.add(ogptEmployee)
            
        } catch (Exception e) {
            messageLog.addAttachmentAsString("Employee_Processing_Error", 
                "Error processing employee: " + getFieldValue(employee, 'userId', 'employeeId') + 
                "\nError: " + e.message, "text/plain")
            // Continue processing other employees
        }
    }
    
    // Create final OGPT structure
    def ogptOutput = [
        metadata: [
            source: "SuccessFactors Employee Central",
            extractionDate: new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(new Date()),
            recordCount: ogptEmployees.size(),
            version: "1.0"
        ],
        employees: ogptEmployees
    ]
    
    return ogptOutput
}

/**
 * Get field value from employee XML node
 * Tries multiple field names and returns the first non-empty value
 */
def getFieldValue(employee, String... fieldNames) {
    for (String fieldName : fieldNames) {
        try {
            def value = employee."${fieldName}".text()
            if (value != null && !value.trim().isEmpty()) {
                return value.trim()
            }
            
            // Try with different case variations
            def lowerFieldName = fieldName.toLowerCase()
            value = employee."${lowerFieldName}".text()
            if (value != null && !value.trim().isEmpty()) {
                return value.trim()
            }
            
            // Try navigating through potential nested structures
            value = employee.'**'.find { it.name().toLowerCase() == lowerFieldName }?.text()
            if (value != null && !value.trim().isEmpty()) {
                return value.trim()
            }
        } catch (Exception e) {
            // Continue to next field name
        }
    }
    return null
}

/**
 * Format date string to standard format
 */
def formatDate(String dateStr, SimpleDateFormat formatter) {
    if (dateStr == null || dateStr.trim().isEmpty()) {
        return null
    }
    
    try {
        // Try multiple date formats commonly used in SF EC
        def inputFormats = [
            new SimpleDateFormat("yyyy-MM-dd"),
            new SimpleDateFormat("MM/dd/yyyy"),
            new SimpleDateFormat("dd/MM/yyyy"),
            new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss"),
            new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
        ]
        
        for (def inputFormat : inputFormats) {
            try {
                def date = inputFormat.parse(dateStr)
                return formatter.format(date)
            } catch (Exception e) {
                // Try next format
            }
        }
        
        // If no format matches, return original string
        return dateStr
        
    } catch (Exception e) {
        return dateStr
    }
}

/**
 * Format datetime string to standard format
 */
def formatDateTime(String dateStr, SimpleDateFormat formatter) {
    return formatDate(dateStr, formatter)
}

/**
 * Parse string to boolean
 */
def parseBoolean(String value) {
    if (value == null || value.trim().isEmpty()) {
        return null
    }
    
    def lowerValue = value.trim().toLowerCase()
    if (lowerValue in ['true', '1', 'yes', 'y', 't']) {
        return true
    } else if (lowerValue in ['false', '0', 'no', 'n', 'f']) {
        return false
    }
    
    return null
}

/**
 * Parse string to decimal/double
 */
def parseDecimal(String value) {
    if (value == null || value.trim().isEmpty()) {
        return null
    }
    
    try {
        return Double.parseDouble(value.trim())
    } catch (Exception e) {
        return null
    }
}
