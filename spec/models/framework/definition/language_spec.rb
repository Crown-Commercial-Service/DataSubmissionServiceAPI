require 'rails_helper'

RSpec.describe Framework::Definition::Language do
  describe '.generate_framework_definition' do
    let(:logger)         { spy('Logger') }
    subject(:definition) { Framework::Definition::Language.generate_framework_definition(source, logger) }

    context 'Laundry framework language features (CM_OSG_05_3565)' do
      let(:source) do
        File.read('app/models/framework/definition/CM_OSG_05_3565.fdl')
      end

      it 'is a Framework::Definition::Base' do
        expect(definition).to be < Framework::Definition::Base
      end

      it 'has the expected framework_short_name' do
        expect(definition.framework_short_name).to eq('CM/OSG/05/3565')
      end

      it 'has the expected framework name' do
        expect(definition.framework_name).to eq('Laundry Services - Wave 2')
      end

      it 'has the expected management charge percentage' do
        expect(definition.management_charge.percentage).to eq(BigDecimal(0))
      end

      describe 'the Invoice fields class' do
        subject(:invoice_class) { definition::Invoice }

        it 'is a Framework::EntryData' do
          expect(invoice_class).to be < Framework::EntryData
        end

        describe 'Invoice Value – a known numeric field' do
          it 'tells the class where the total_value_field is' do
            expect(invoice_class.total_value_field).to eql('Total Spend')
          end

          it 'knows where the data is coming from in the spreadsheet' do
            expect(invoice_class.export_mappings['InvoiceValue']).to eq('Total Spend')
          end

          it 'validates numericality and presence' do
            expect(invoice_class).to have_field('Total Spend').validated_by(:presence, :ingested_numericality)
          end

          it 'is a string validate as a number' do
            expect(invoice_class).to have_field('Total Spend')
              .with_activemodel_type(:string)
              .validated_by(:ingested_numericality)
          end
        end

        describe 'Customer Postcode – a known string field' do
          it 'knows where it’s coming from/going to in the data warehouse' do
            expect(invoice_class.export_mappings['CustomerPostCode']).to eq('Customer Postcode')
          end

          it 'is optional' do
            expect(invoice_class).to have_field('Customer Postcode')
              .not_validated_by(:presence)
          end
        end

        describe 'Customer Name - a known string field' do
          it 'knows where it’s coming from/going to in the data warehouse' do
            expect(invoice_class.export_mappings['CustomerName']).to eq('Customer Organisation')
          end

          it 'is assumed present but not numeric' do
            expect(invoice_class).to have_field('Customer Organisation')
              .validated_by(:presence)
              .not_validated_by(:ingested_numericality)
          end
        end

        describe 'Item Code - an optional known string field' do
          it 'is optional' do
            expect(invoice_class).to have_field('Item Code')
              .not_validated_by(:presence)
          end
        end

        describe 'CustomerURN - a known field with a custom validator' do
          it 'knows where it’s coming from/going to in the data warehouse' do
            expect(invoice_class.export_mappings['CustomerURN']).to eq('Customer URN')
          end

          it 'is a valid URN' do
            expect(invoice_class).to have_field('Customer URN')
              .with_activemodel_type(:integer)
              .validated_by(:urn)
              .not_validated_by(:presence)
          end
        end

        describe 'InvoiceDate - a known field with a date validator' do
          it 'knows where it’s coming from/going to in the data warehouse' do
            expect(invoice_class.export_mappings['InvoiceDate']).to eq('Customer Invoice Date')
          end

          it 'is assumed to be present and a valid date' do
            expect(invoice_class).to have_field('Customer Invoice Date')
              .validated_by(:presence, :ingested_date)
          end
        end

        describe 'Additional String field' do
          it {
            is_expected.to have_field('Manufacturers Product Code')
          }
        end

        describe 'VATIncluded - a known field with a yesno validator' do
          it 'knows where it’s coming from/going to in the data warehouse' do
            expect(invoice_class.export_mappings['VATIncluded']).to eq('Vat Included')
          end

          it 'is optional and implemented as a yesno field' do
            expect(invoice_class).to have_field('Vat Included')
              .validated_by(case_insensitive_inclusion: { in: %w[Y N], message: "must be 'Y' or 'N'", allow_nil: true })
          end
        end

        describe 'Unknown fields - fields which are not validated and do not go to the data warehouse' do
          it { is_expected.to have_field('Cost Centre').not_validated_by(:presence) }
          it { is_expected.to have_field('Contract Number').not_validated_by(:presence) }
        end
      end
    end

    context 'Vehicle Telematics framework features' do
      let(:source) do
        File.read('app/models/framework/definition/RM3754.fdl')
      end

      describe 'the Invoice fields class' do
        subject(:invoice_class) { definition::Invoice }
        let(:expected_lookups) do
          { 'PaymentProfile' => %w[Monthly Quarterly Annual One-off] }
        end

        it {
          is_expected.to have_field('UNSPSC')
            .with_activemodel_type(:integer)
            .validated_by(ingested_numericality: { only_integer: true })
        }

        describe '.lookups' do
          subject { invoice_class.lookups }
          it { is_expected.to eq(expected_lookups) }
        end

        it {
          is_expected.to have_field('Payment Profile')
            .with_activemodel_type(:string)
            .validated_by(case_insensitive_inclusion: { in: expected_lookups['PaymentProfile'] })
        }
      end
    end

    context 'Vehicle Leasing framework features' do
      let(:source) do
        File.read('app/models/framework/definition/RM858.fdl')
      end

      describe 'the Management Charge' do
        subject(:management_charge) { definition.management_charge }

        it {
          is_expected.to match(
            an_object_having_attributes(
              varies_by: 'Spend Code',
              value_to_percentage: {
                # ManagementChargeCalculator::ColumnBased downcases its keys
                'lease rental' => BigDecimal('0.5'),
                'fleet management fee' => BigDecimal('0.5'),
                'damage' => 0,
                'other re-charges' => 0
              }
            )
          )
        }
      end
    end

    context 'our FDL isn\'t valid' do
      let(:source) { 'any old rubbish' }

      it 'logs the error and re-raises' do
        expect { definition }.to raise_error(Parslet::ParseFailed)
        expect(logger).to have_received(:error).with(/Expected "Framework"/)
      end
    end
  end
end
