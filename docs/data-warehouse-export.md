# Data Warehouse Export

To enable CCS to perform deeper analysis and reporting on submission data, the
RMI application generates an export of various data related to tasks and their
submissions.

There are four export files that are generated: tasks; submissions; invoices;
contracts.

## Tasks export

This export contains information related to supplier tasks. The export
includes the following fields:

  - TaskID:         unique identifier for the task within RMI
  - Month:          date period the task is for, for example: "2018-12"
  - SupplierID:     Salesforce ID for the supplier, for example: "0010N00004FtGMGQA3"
  - FrameworkID:    identifier for the framework, for example: "RM1070"
  - Status:         current status of the task, for example: "completed" or "unstarted"
  - TaskType:       a number representing the type of task. Currently always "1"
  - StartedDate:    timestamp for when the task was started (not yet reported by RMI)
  - CompletedDate:  timestamp for when the task was completed (not yet reported by RMI)

## Submissions export

The export contains information related to all "completed" and
"validation_failed" submissions made by suppliers. The export contains the
following fields:

  - TaskID:                   unique identifier for the task within RMI
  - SubmissionID:             unique identifier for the submission within RMI
  - Status:                   current status of the task, i.e. "completed" or "validation_failed"
  - SubmissionType:           either "no_business" or "file" depending on the type of submission
  - SubmissionFileType:       file extension of the submission, for example "xls"
  - ContractEntryCount:       number of contracts in the submission
  - ContractValue:            total value of contracts in the submission
  - InvoiceEntryCount:        number of invoices in the submission
  - InvoiceValue:             total value of invoices in the submission
  - CCSManagementChargeValue: total management charge for the submission
  - CCSManagementChargeRate:  no longer reported (not possible for all frameworks)
  - CreatedDate:              timestamp for when the submission was created
  - CreatedBy:                name of the user that created the submission
  - SupplierApprovedDate:     timestamp for when the submission was approved
  - SupplierApprovedBy:       name of the user that approved the submission
  - FinanceExportDate:        timestamp the submission was sent to finance system (not yet reported by RMI)
  - PONumber:                 optional purchase order number supplied by the supplier

## Invoices

The export contains information related to all the invoices in the reported
submissions above, i.e. the rows from the worksheet that contains invoice
information. The export contains the following fields.

  - SubmissionID:             unique identifier for the submission for the invoice
  - CustomerURN:              customer URN for the invoice
  - CustomerName:             name for the invoice customer
  - CustomerPostcode:         postcode for the invoice customer
  - InvoiceDate:              invoice date for the invoice
  - InvoiceNumber:            invoice number for the invoice
  - SupplierReferenceNumber:  reference number from the supplier
  - CustomerReferenceNumber:  reference number from the customer
  - LotNumber:                lot number for the invoice
  - ProductDescription:       product description for the invoice
  - ProductGroup:             product group for the invoice
  - ProductClass:             product class for the invoice
  - ProductSubClass:          product sub class for the invoice
  - ProductCode:              product code for the invoice
  - UnitType:                 unit type, for example "hourly", or "fixed"
  - UnitPrice:                unit price for the invoice as a decimal
  - UnitQuantity:             unit quantity for the invoice
  - InvoiceValue:             total invoice value
  - Expenses:                 expenses for the invoice
  - VATCharged:               vat amount on the invoice as a decimal
  - PromotionCode:            promotion code for the invoice
  - ManagementChargeValue:    calculated management charge for the invoice

There are also up to 24 "AdditionalX" rows reported per invoice. These rows
contain framework-specific data. For example, RM3710 reports the "Vehicle
Registration" in "Additional1". The exact data reported in each of these is
defined in the framework definitions.

## Contracts

  - SubmissionID              unique identifier for the submission for the contract
  - CustomerURN:              customer URN for the invoice
  - CustomerName:             name for the invoice customer
  - CustomerPostcode:         postcode for the invoice customer
  - SupplierReferenceNumber:  reference number from the supplier
  - CustomerReferenceNumber:  reference number from the customer
  - LotNumber:                lot number for the invoice
  - ProductDescription:       product description for the invoice
  - ProductGroup:             product group for the invoice
  - ProductClass:             product class for the invoice
  - ProductSubClass:          product sub class for the invoice
  - ProductCode:              product code for the invoice
  - ProductLevel6:            currently blank
  - CustomerContactName:      contact name for the customer
  - CustomerContactNumber:    contact number for the customer
  - CustomerContactEmail      contact email for the customer
  - ContractStartDate:        timestamp for the contract start date
  - ContractEndDate:          timestamp for the contract end date
  - ContractValue:            total value for the contract
  - ContractAwardChannel      award channel for the contract

There are also up to 24 "AdditionalX" rows reported per contract. These rows
contain framework-specific data. For example, RM3756 reports the "Sub-
Contractor Name" in "Additional1". The exact data reported in each of these is
defined in the framework definitions.
