FactoryBot.define do
  factory :submission_entries_stage do
    transient do
      row { 1 }
      column { 'Column' }
      sheet_name { 'Some sheet' }
    end

    submission
    entry_type { 'invoice' }
    data { { test_key: 'some data' } }
    source { { sheet: sheet_name, row: row } }

    factory :invoice_entry_stage do
      sheet_name { 'InvoicesRaised' }
    end

    factory :order_entry_stage, aliases: [:contract_entry_stage] do
      entry_type { 'order' }
      sheet_name { 'OrdersReceived' }
    end

    factory :other_entry_stage do
      entry_type { 'other' }
      sheet_name { 'Bid Invitations' }
    end

    trait :valid do
      aasm_state { :validated }
    end

    trait :errored do
      transient { error_message { 'Required value missing' } }

      aasm_state { :errored }
      validation_errors { [{ 'message' => error_message, 'location' => { 'row' => row, 'column' => column } }] }
    end

    trait :legal_framework_invoice_data do
      total_value { -135.98 }
      data do
        {
          'UNSPSC' => '80120001',
          'Quantity' => '-0.9',
          'Matter Name' => 'GITIS Terms and Conditions',
          'Tier Number' => '1',
          'Customer URN' => '10012342',
          'Service Type' => 'Core',
          'Price per Unit' => '151.09',
          'Unit of Purchase' => 'Hourly',
          'Pricing Mechanism' => 'Time and Material',
          'Pro-Bono Quantity' => '0.00',
          'Customer Post Code' => 'SW1P 3Z1',
          'Practitioner Grade' => 'Legal Director/Senior Solicitor',
          'Primary Specialism' => 'Contracts',
          'VAT Amount Charged' => '-27.20',
          'Total Cost (ex VAT)' => '-135.98',
          'Pro-Bono Total Value' => '0.00',
          'Customer Invoice Date' => '31/5/2012',
          'Customer Invoice Number' => '3307951',
          'Pro-Bono Price per Unit' => '0.00',
          'Supplier Reference Number' => 'DEP/0008.00031',
          'Customer Organisation Name' => 'One morning, when Gregor Samsa woke from troubled dreams, '\
          'he found himself transformed in his bed into a horrible vermin. He lay on his armour-like back, '\
          'and if he lifted his head a little he could see his brown belly, slightly domed and divided by arches into',
          'Sub-Contractor Name (If Applicable)' => 'N/A'
        }
      end
    end

    trait :legal_framework_contract_data do
      total_value { 5000 }
      data do
        {
          'Matter Name' => 'DWP - Claim by Mr I Dontexist',
          'Tier Number' => '1',
          'Customer URN' => '10010913',
          'Award Procedure' => 'Further Competition',
          'Contract End Date' => '27/6/2020',
          'Customer Post Code' => 'WC1B 4Z3',
          'Matter Description' => 'Contentious Employment',
          'Contract Start Date' => '27/6/2019',
          'Sub-Contractor Name' => 'N/A',
          'Customer Response Time' => '15',
          'Expected Pro-Bono value' => '0.00',
          'Call Off Managing Entity' => 'Central Government Department',
          'Supplier Reference Number' => '471600.00004',
          'Customer Organisation Name' => 'Government Legal Department',
          'Expected Total Order Value' => '5000.00',
          'Pro-bono work included? (Y/N)' => 'N',
          'Expression Of Interest Used (Y/N)' => 'N'
        }
      end
    end
  end
end
