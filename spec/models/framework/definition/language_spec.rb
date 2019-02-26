require 'rails_helper'

RSpec.describe Framework::Definition::Language do
  describe '.generate_framework_definition' do
    subject(:definition) { Framework::Definition::Language.generate_framework_definition(source) }

    context 'we have some valid FDL' do
      let(:source) do
        <<~FDL.strip
          Framework CM/05/3769 {
            Name 'Laundry Services - Wave 2'
            ManagementCharge 0.0%

            InvoiceFields {
              TotalValue from 'Total Spend'
            }
          }
        FDL
      end

      it 'is a Framework::Definition::Base' do
        expect(definition.ancestors).to include(Framework::Definition::Base)
      end

      it 'has the expected framework_short_name' do
        expect(definition.framework_short_name).to eq('CM/05/3769')
      end

      it 'has the expected framework name' do
        expect(definition.framework_name).to eq('Laundry Services - Wave 2')
      end

      it 'has the expected management charge percentage' do
        expect(definition.management_charge_rate.percentage).to eq(BigDecimal(0))
      end

      describe 'the Invoice fields class' do
        subject(:invoice_class) { definition::Invoice }

        it 'is a Framework::EntryData' do
          expect(invoice_class.ancestors).to include(Framework::EntryData)
        end


        describe 'Total Value – a known numeric field' do
          it 'tells the class where the total_value_field is' do
            expect(invoice_class.total_value_field).to eql('Total Spend')
          end

          it 'knows where the data is coming from in the spreadsheet' do
            expect(invoice_class.export_mappings['TotalValue']).to eq('Total Spend')
          end

          it 'has the expected validators' do
            ingested_numericality_validator = invoice_class.validators.find do |v|
              v.class == IngestedNumericalityValidator &&
                v.attributes == ['Total Spend']
            end
            presence_validator = invoice_class.validators.find do |v|
              v.class == ActiveModel::Validations::PresenceValidator &&
                v.attributes == ['Total Spend']
            end

            expect(ingested_numericality_validator).not_to be_nil
            expect(presence_validator).not_to be_nil
          end
        end
      end
    end
  end
end
