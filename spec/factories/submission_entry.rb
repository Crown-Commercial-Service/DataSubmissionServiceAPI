FactoryBot.define do
  factory :submission_entry do
    transient do
      row 1
      column 'Column'
      sheet_name 'Some sheet'
    end

    submission
    entry_type 'invoice'
    data { { test_key: 'some data' } }
    source { { sheet: sheet_name, row: row } }

    factory :invoice_entry do
      sheet_name 'InvoicesRaised'
    end

    factory :order_entry, aliases: [:contract_entry] do
      entry_type 'order'
      sheet_name 'OrdersReceived'
    end

    trait :valid do
      aasm_state :validated
    end

    trait :errored do
      transient { error_message 'Required value missing' }

      aasm_state :errored
      validation_errors { [{ 'message' => error_message, 'location' => { 'row' => row, 'column' => column } }] }
    end

    trait :legal_framework_invoice_data do
      total_value(-135.98)
      data do
        {
          'UNSPSC' => '80120000',
          'Quantity' => '-0.9',
          'Matter Name' => 'GITIS Terms and Conditions',
          'Tier Number' => '1',
          'Customer URN' => '10012345',
          'Service Type' => 'Core',
          'Price per Unit' => '151.09',
          'Unit of Purchase' => 'Hourly',
          'Pricing Mechanism' => 'Time and Material',
          'Pro-Bono Quantity' => '0.00',
          'Customer Post Code' => 'SW1P 3ZZ',
          'Practitioner Grade' => 'Legal Director/Senior Solicitor',
          'Primary Specialism' => 'Contracts',
          'VAT Amount Charged' => '-27.20',
          'Total Cost (ex VAT)' => '-135.98',
          'Pro-Bono Total Value' => '0.00',
          'Customer Invoice Date' => '5/31/18',
          'Customer Invoice Number' => '3307957',
          'Pro-Bono Price per Unit' => '0.00',
          'Supplier Reference Number' => 'DEP/0008.00032',
          'Customer Organisation Name' => 'Department for Education',
          'Sub-Contractor Name (If Applicable)' => 'N/A'
        }
      end
    end

    trait :legal_framework_contract_data do
      total_value 5000
      data do
        {
          'Matter Name' => 'DWP - Claim by Mr I Dontexist',
          'Tier Number' => '1',
          'Customer URN' => '10010915',
          'Award Procedure' => 'Further Competition',
          'Contract End Date' => '6/27/20',
          'Customer Post Code' => 'WC1B 4ZZ',
          'Matter Description' => 'Contentious Employment',
          'Contract Start Date' => '6/27/18',
          'Sub-Contractor Name' => 'N/A',
          'Customer Response Time' => '15',
          'Expected Pro-Bono value' => '0.00',
          'Call Off Managing Entity' => 'Central Government Department',
          'Supplier Reference Number' => '471600.00001',
          'Customer Organisation Name' => 'Government Legal Department',
          'Expected Total Order Value' => '5000.00',
          'Pro-bono work included? (Y/N)' => 'N',
          'Expression Of Interest Used (Y/N)' => 'N'
        }
      end
    end
  end
end
