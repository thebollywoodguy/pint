# pint

Oracle to SAP HANA Stored Procedure Conversion Project

## Files

- `org_exceptions_validations.prc` - Original Oracle stored procedure
- `org_exceptions_validations_hana.sql` - Converted SAP HANA SQLScript procedure
- `CONVERSION_NOTES.md` - Detailed documentation of the conversion changes

## Description

This repository contains the conversion of the `org_exceptions_validations` stored procedure from Oracle PL/SQL to SAP HANA SQLScript. The procedure validates employee exception data by checking various fields for proper formatting and referential integrity.

## Key Features

- Data validation for employee records
- Support for semicolon-delimited pod values
- Validation of dates and numeric fields
- Referential integrity checks against quota and title tables
- Error logging to `org_exception_errors` table

## Usage

To deploy the SAP HANA version:

1. Review the `CONVERSION_NOTES.md` file to understand the changes
2. Ensure all dependent tables exist (org_exceptions_hold, org_exception_errors, nq_podquota, cs_title)
3. Execute `org_exceptions_validations_hana.sql` in your SAP HANA system
4. Test thoroughly with sample data

## Conversion Highlights

- Replaced Oracle-specific syntax with SAP HANA equivalents
- Converted `CONNECT BY` hierarchical queries to procedural loops
- Implemented exception handling for data validation
- Updated date/time functions and null handling
- Removed dynamic SQL in favor of direct execution

For detailed conversion information, see `CONVERSION_NOTES.md`.
