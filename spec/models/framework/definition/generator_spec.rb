require 'rails_helper'

RSpec.describe Framework::Definition::Generator do
  describe '.generate_framework_definition' do
    let(:logger)        { spy('Logger') }
    subject(:generator) { Framework::Definition::Generator.new(source, logger) }

    let!(:definition) { generator.definition }

    context 'Laundry framework language features (CM_OSG_05_3565)' do
      let(:source) do
        File.read('spec/fixtures/cm_osg_05_3565.fdl')
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

          it 'validates numericality' do
            expect(invoice_class).to have_field('Total Spend').validated_by(:numericality)
          end

          it 'is a string validated as a number' do
            expect(invoice_class).to have_field('Total Spend')
              .with_activemodel_type(:string)
              .validated_by(:numericality)
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
              .not_validated_by(:numericality)
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
              .with_activemodel_type(:string)
              .validated_by(:urn)
              .not_validated_by(:presence)
          end
        end

        describe 'InvoiceDate - a known field with a date validator' do
          it 'knows where it’s coming from/going to in the data warehouse' do
            expect(invoice_class.export_mappings['InvoiceDate']).to eq('Customer Invoice Date')
          end

          it 'is assumed to be a valid date' do
            expect(invoice_class).to have_field('Customer Invoice Date')
              .validated_by(:ingested_date)
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
        File.read('spec/fixtures/rm3754.fdl')
      end

      describe 'the Invoice fields class' do
        subject(:invoice_class) { definition::Invoice }
        let(:expected_lookups) do
          { 'PaymentProfile' => %w[Monthly Quarterly Annual One-off] }
        end

        it {
          is_expected.to have_field('UNSPSC')
            .with_activemodel_type(:string)
            .validated_by(numericality: { only_integer: true })
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
        File.read('spec/fixtures/rm858.fdl')
      end

      describe 'the Management Charge' do
        subject(:management_charge) { definition.management_charge }

        it {
          is_expected.to match(
            an_object_having_attributes(
              varies_by: 'Spend Code',
              value_to_percentage: {
                # ManagementChargeCalculator::ColumnBased downcases its keys
                ['lease rental'] => { percentage: BigDecimal('0.5') },
                ['fleet management fee'] => { percentage: BigDecimal('0.5') },
                ['damage'] => { percentage: 0 },
                ['other re-charges'] => { percentage: 0 }
              }
            )
          )
        }
      end

      describe 'the Invoice fields class' do
        subject(:invoice_class) { definition::Invoice }

        it {
          is_expected.to have_field('Lease Start Date')
            .with_activemodel_type(:string)
            .validated_by(:ingested_date)
        }

        let(:expected_promotion_code_values) do
          [
            'Lease Rental',
            'Fleet Management Fee',
            'Damage',
            'Other Re-charges'
          ]
        end

        it {
          is_expected.to have_field('Spend Code')
            .with_activemodel_type(:string)
            .validated_by(case_insensitive_inclusion: { in: expected_promotion_code_values })
        }
      end
    end

    describe '#management_charge types' do
      subject(:management_charge) { definition.management_charge }

      context 'an RM6060-like framework (so we can vary a flat-rate management charge by column)' do
        let(:source) do
          <<~FDL
            Framework RM6060 {
              Name 'Fake framework'
              ManagementCharge 0.5% of 'Supplier Price'
              Lots { '99' -> 'Fake' }

              InvoiceFields {
                InvoiceValue from 'Supplier Price'
              }
            }
          FDL
        end

        it {
          is_expected.to match(
            an_object_having_attributes(
              column: 'Supplier Price',
              percentage: BigDecimal('0.5')
            )
          )
        }
      end
      context 'an RM3774-like framework (so we can use a sector-based management charge)' do
        let(:source) do
          <<~FDL
            Framework RM3774 {
              Name 'Fake framework'
              ManagementCharge sector_based {
                CentralGovernment -> 0.5%
                WiderPublicSector -> 1.2%
              }
              Lots { '99' -> 'Fake' }

              InvoiceFields {
                InvoiceValue from 'Supplier Price'
              }
            }
          FDL
        end

        it {
          is_expected.to match(
            an_object_having_attributes(
              central_government:  BigDecimal('0.5'),
              wider_public_sector: BigDecimal('1.2'),
            )
          )
        }
      end
    end

    context 'an RM6060-like framework (so we can test min/max field lengths)' do
      let(:source) do
        <<~FDL
          Framework RM6060 {
            Name 'Fake framework'
            ManagementCharge 0.5%
            Lots { '99' -> 'Fake' }

             InvoiceFields {
              InvoiceValue from 'Somewhere'
              String(..6) from 'Up to 6 chars'
              String(3..) from 'Over 3 chars'
              String(5) from 'Exactly 5 chars'
              String(4..8) from 'Between 4 and 8 chars'
            }
          }
        FDL
      end

      describe 'the invoice fields' do
        subject { definition::Invoice }

        it {
          is_expected.to have_field('Over 3 chars')
            .with_activemodel_type(:string)
            .validated_by(length: { minimum: 3 })
        }
        it {
          is_expected.to have_field('Up to 6 chars')
            .with_activemodel_type(:string)
            .validated_by(length: { maximum: 6 })
        }
        it {
          is_expected.to have_field('Exactly 5 chars')
            .with_activemodel_type(:string)
            .validated_by(length: { is: 5 })
        }
        it {
          is_expected.to have_field('Between 4 and 8 chars')
            .with_activemodel_type(:string)
            .validated_by(length: { minimum: 4, maximum: 8 })
        }
      end
    end

    context 'RM3772 – first ContractFields-using framework' do
      let(:source) do
        File.read('spec/fixtures/rm3772.fdl')
      end

      describe 'the invoice fields' do
        subject { definition::Invoice }

        it {
          is_expected.to have_field('Customer Organisation').validated_by(:presence)
        }
      end

      describe 'the contract fields' do
        subject { definition::Order }

        it {
          is_expected.to have_field('Customer PostCode').not_validated_by(:presence)
        }
      end
    end

    context 'RM6060 - Vehicle Purchase' do
      let(:source) do
        File.read('spec/fixtures/rm6060.fdl')
      end

      describe 'the Invoice fields class' do
        subject(:invoice_class) { definition::Invoice }
        let(:mappings) do
          {
            ['1'] => invoice_class.lookups['Lot1Segment'],
            ['2'] => invoice_class.lookups['Lot2Segment'],
            ['3'] => invoice_class.lookups['Lot3Segment'],
            ['4'] => invoice_class.lookups['Lot4Segment'],
            ['5'] => invoice_class.lookups['Lot5Segment'],
            ['6'] => invoice_class.lookups['Lot6Segment'],
            ['7'] => invoice_class.lookups['Lot7Segment']
          }
        end

        it {
          is_expected.to have_field('Vehicle Segment')
            .validated_by(dependent_field_inclusion: { parents: ['Lot Number'], in: mappings })
        }

        it {
          is_expected.to have_field('Additional Support Terms')
            .validated_by(:numericality)
        }
      end
    end

    context 'RM3767 - Supply and Fit of Tyres' do
      let(:source) do
        File.read('spec/fixtures/rm3767.fdl')
      end

      describe '.lots' do
        subject { definition.lots }

        it {
          is_expected.to eq(
            '1' => 'The supply and fit of tyres and associated services to the Police and emergency services',
            '2' => 'The supply and fit of tyres and associated services to central Government and '\
                   'the wider public sector'
          )
        }
      end
    end

    context 'RM3774 - Campaign Solutions, first OtherFields-using framework' do
      context 'The OtherFields block is correctly paired with another block' do
        let(:source) do
          <<~FDL
            Framework RM3774 {
              Name 'Campaign Solutions'
              ManagementCharge 0.5%

              Lots {
                '1' -> 'Fake'
              }

              InvoiceFields {
                InvoiceValue from 'Somewhere'
              }

              OtherFields {
                String Additional1 from 'Somewhere'
              }
            }
          FDL
        end

        it { is_expected.to be_success }

        describe 'The ::Other class' do
          subject(:other_class) { definition::Other }

          it do
            is_expected.to have_field('Somewhere').with_activemodel_type(:string)
          end
          it 'does not define a total_value_field' do
            expect(other_class.total_value_field).to be_nil
          end
        end
      end

      context 'The OtherFields block references a lookup that does not exist' do
        let(:source) do
          <<~FDL
            Framework RM3774 {
              Name 'Campaign Solutions'
              ManagementCharge 0.5%

              Lots {
                '1' -> 'Fake'
              }

              InvoiceFields {
                InvoiceValue from 'Somewhere'
              }

              OtherFields {
                ProductDescription from 'Somewhere' depends_on 'NonExistent' {
                  'foo' -> 'bar'
                }
              }
            }
          FDL
        end

        it { is_expected.to be_error }

        it 'has the error' do
          expect(generator.error).to eql("'Somewhere' depends on 'NonExistent', which does not exist")
        end
      end
    end

    context 'with multi column management charge calculations' do
      subject(:calculator) { generator.definition.management_charge }

      let(:source) { valid_source }
      let(:valid_source) do
        <<~FDL
          Framework 3787 {
            Name 'Fake framework'
            ManagementCharge varies_by 'Lot Number', 'Spend Code' {
              '1', 'Lease Rental' -> 0.5%
              '1', 'Damage' -> 0%
              '2', 'Lease Rental' -> 1.5% of 'Other Price'
            }

            Lots {
              '1' -> 'Lease of passenger motor vehicles and light commercial vehicles up to 3.5 tonnes'
              '2' -> 'Lease of commercial vehicles 3.5 tonnes and above, including buses, coaches, tra'
              '3' -> 'Provision of Fleet Management Services, including the management, sourcing and s'
            }

            InvoiceFields {
              LotNumber from 'Lot Number'
              PromotionCode from 'Spend Code'
              InvoiceValue from 'Supplier Price'
              Decimal Additional1 from 'Other Price'
            }
          }
        FDL
      end

      it 'does not have any errors' do
        expect(generator.error).to eq(nil)
      end

      it do
        expect(calculator.value_to_percentage).to eql(
          ['1', 'lease rental'] => { percentage: 0.5e0 },
          ['1', 'damage']       => { percentage: 0 },
          ['2', 'lease rental'] => { percentage: 0.15e1, column: 'Other Price' }
        )
      end

      context 'a field has an invalid reference' do
        let(:invalid_source) { valid_source.sub("1.5% of 'Other Price'", "1.5% of 'Evil Field'") }
        let(:source)         { invalid_source }

        it 'has an error' do
          expect(generator.error).to eql(
            "Management charge references 'Evil Field' which does not exist"
          )
        end
      end

      context 'a field should not be optional' do
        let(:invalid_source) { valid_source.sub('Decimal Additional1', 'optional Decimal Additional1') }
        let(:source)         { invalid_source }

        it 'has an error' do
          expect(generator.error).to eql(
            "Management charge references 'Other Price' so it cannot be optional"
          )
        end
      end

      context 'a field begins with a wildcard' do
        let(:invalid_source) { valid_source.sub('\'1\', \'Damage\' -> 0%', '*, \'Damage\' -> 0%') }
        let(:source)         { invalid_source }

        it 'has an error' do
          expect(generator.error).to eql(
            'The first criterion in a multiple depends-on validation cannot be a wildcard.'
          )
        end
      end

      context 'only one column field given' do
        let(:invalid_source) { valid_source.sub("'1', 'Lease Rental'", "*") }        
        let(:source)         { invalid_source }

        it 'has an error' do
          expect(generator.error).to eql(
            'This framework definition contains an incorrect or incomplete depends_on rule'
          )
        end
      end
    end

    context 'Composing lookups from other lookups - RM3787' do
      let(:source) do
        <<~FDL
          Framework 3787 {
            Name 'Fake framework'
            ManagementCharge 1%

            Lots {
              '99' -> 'Fake'
            }

            InvoiceFields {
              InvoiceValue from 'Supplier Price'
            }

            Lookups {
              CoreSpecialisms [
                'One'
                'Two'
              ]

              NonCoreSpecialisms [
                'Three'
                'Four'
              ]

              PrimarySpecialism [
                CoreSpecialisms
                NonCoreSpecialisms
                'Five'
              ]
            }
          }
        FDL
      end

      describe 'the Invoice fields class' do
        subject(:invoice_class) { definition::Invoice }

        describe '.lookups' do
          subject { invoice_class.lookups }
          it {
            is_expected.to eql(
              'CoreSpecialisms'    => %w[One Two],
              'NonCoreSpecialisms' => %w[Three Four],
              'PrimarySpecialism'  => %w[One Two Three Four Five]
            )
          }
        end
      end
    end
    context 'Roman numerals in the short_name' do
      let(:source) do
        <<~FDL
          Framework RM1043iii {
            Name 'DOS-like'
            ManagementCharge 1%
            Lots { '99' -> 'Fake' }

            InvoiceFields {
              InvoiceValue from 'Supplier Price'
            }
          }
        FDL
      end

      it "doesn't grumble" do
        expect(definition.framework_short_name).to eql('RM1043iii')
      end
    end

    context 'Dependent field validation on a non-existent field' do
      let(:source) do
        <<~FDL
          Framework RM3786 {
            Name 'General Legal Advice Services'
            ManagementCharge 1.5%
            Lots { '99' -> 'Fake' }
            InvoiceFields {
              ProductDescription from 'Primary Specialism' depends_on 'Non-existent field' {
                'Core' -> CoreSpecialisms
              }
              InvoiceValue from 'Supplier Price'
            }
          }
        FDL
      end

      it 'has the error' do
        expect(generator.error).to eql("'Primary Specialism' depends on 'Non-existent field', which does not exist")
      end
    end

    context 'Valid depends_on fields' do
      let(:source) do
        <<~FDL
          Framework RM3786 {
            Name 'General Legal Advice Services'
            ManagementCharge 1.5%
            Lots { '99' -> 'Fake' }
            InvoiceFields {
              ProductGroup from 'Service Type'
              ProductDescription from 'Primary Specialism' depends_on 'Service Type' {
                'Core'     -> SomeLookup
                'Non-core' -> SomeOtherLookup
                'Mixture'  -> SomeCombinationOfLookups
              }
              InvoiceValue from 'Supplier Price'
              ProductClass from 'Product Class'
              String Additional1 from 'Going to Additional1' depends_on 'Service Type', 'Product Class' {
                'Core', '1' -> SomeLookup
                'Mixture', '2' -> SomeOtherLookup
                'Non-core', * -> SomeCombinationOfLookups
              }
            }

            Lookups {
              ProductGroup [
                'Core'
                'Non-core'
                'Mixture'
              ]

              ProductClass [
                '1'
                '2'
              ]

              SomeLookup [
                'Hi'
              ]
              SomeOtherLookup [
                'There'
              ]
              SomeCombinationOfLookups [
                SomeLookup
                SomeOtherLookup
              ]
            }
          }
        FDL
      end

      describe 'the invoice fields class' do
        subject(:invoice_class) { definition::Invoice }

        it {
          is_expected.to have_field('Primary Specialism').validated_by(
            dependent_field_inclusion: {
              parents: ['Service Type'],
              in: {
                ['core'] => %w[Hi], ['non-core'] => %w[There], ['mixture'] => %w[Hi There]
              }
            }
          )
        }

        it {
          is_expected.to have_field('Going to Additional1').validated_by(
            dependent_field_inclusion: {
              parents: ['Service Type', 'Product Class'],
              in: {
                ['core', '1'] => ['Hi'],
                ['mixture', '2'] => ['There'],
                ['non-core', Framework::Definition::AST::Any] => ['Hi', 'There']
              }
            }
          )
        }
      end
    end

    context 'field mapping will not be exported' do
      let(:source) do
        <<~FDL
          Framework RM6060 {
            Name 'Fake framework'
            ManagementCharge 0.5% of 'Supplier Price'
            Lots { '99' -> 'Fake' }

            InvoiceFields {
              InvoiceValue from 'Supplier Price'
              ContractStartDate from 'Contract Start Date'
            }
          }
        FDL
      end

      it 'has the error' do
        expect(generator.error).to eql(
          'ContractStartDate is not an exported field in the InvoiceFields block'
        )
      end
    end

    context 'mismatched depends_on fields and values' do
      let(:source) do
        <<~FDL
          Framework RM3786 {
            Name 'General Legal Advice Services'
            ManagementCharge 1.5%
            Lots { '99' -> 'Fake' }
            InvoiceFields {
              ProductClass from 'Product Class'
              ProductDescription from 'Description'
              ProductGroup from 'Product Group' depends_on 'Product Class', 'Description' {
                'a', *, 'c' -> ProductGroup
              }
              InvoiceValue from 'Supplier Price'
            }
            Lookups {
              ProductGroup [
                'Core'
              ]
            }
          }
        FDL
      end

      it 'has the error' do
        expect(generator.error).to eql(
          "'Product Group' depends on 2 fields ('Product Class', 'Description') " \
          "but contains a match on 3 values ('a', *, 'c')"
        )
      end
    end

    context 'invalid depends_on fields' do
      let(:source) do
        <<~FDL
          Framework RM3786 {
            Name 'General Legal Advice Services'
            ManagementCharge 1.5%
            Lots { '99' -> 'Fake' }
            InvoiceFields {
              ProductGroup from 'Service Type'
              ProductDescription from 'Primary Specialism' depends_on 'Service Type' {
                'Oh no' -> ThisLookupDoesNotExist
              }
              InvoiceValue from 'Supplier Price'
            }
          }
        FDL
      end

      it 'has the error' do
        expect(generator.error).to eql("'ThisLookupDoesNotExist' is not a valid lookup reference")
      end
    end

    context 'Blank strings' do
      let(:source) do
        <<~FDL
          Framework RMTEST {
            Name ''
            ManagementCharge 0%
            Lots { '99' -> 'Fake' }
             InvoiceFields {
              InvoiceValue from 'Supplier Price'
            }
          }
        FDL
      end

      describe 'the name' do
        subject(:name) { definition.framework_name }

        it { is_expected.to be_blank }
      end
    end

    context 'our FDL\'s meaning is invalid' do
      context 'There is no InvoiceValue for InvoiceFields' do
        let(:source) do
          <<~FDL
            Framework RM1234 {
              Name 'x'
              ManagementCharge 0%
              Lots { '99' -> 'fake' }

              InvoiceFields {
                String from 'x'
              }
            }
          FDL
        end

        example { expect(definition).to be_nil }
        it      { is_expected.not_to be_success }
        it      { is_expected.to be_error }

        it 'has the error' do
          expect(generator.error).to eql('InvoiceFields is missing an InvoiceValue field')
        end
      end
      context 'There is a bad reference to a known field' do
        let(:source) do
          <<~FDL
            Framework RM1234 {
              Name 'x'
              ManagementCharge 0%
              Lots { '99' -> 'fake' }

              InvoiceFields {
                InvoiceValue from 'x'
                MisspelledField from 'somwhere'
              }
            }
          FDL
        end

        example { expect(definition).to be_nil }
        it      { is_expected.not_to be_success }
        it      { is_expected.to be_error }

        it 'has the error' do
          expect(generator.error).to eql("known field not found: 'MisspelledField'")
        end
      end
    end

    context 'our FDL isn\'t valid' do
      let(:source) { 'any old rubbish' }

      example { expect(definition).to be_nil }
      it { is_expected.to be_error }
      it { is_expected.not_to be_success }

      it 'logs the error' do
        expect(logger).to have_received(:error).with(/Expected "Framework"/)
      end

      it 'has the parse failure' do
        expect(generator.error).to match(/Failed to match sequence/)
      end
    end

    context 'an unknown type is used on an additional field' do
      let(:source) do
        <<~FDL
          Framework RM1234 {
            Name 'x'
            ManagementCharge 0%
            Lots { '1' -> 'a' }

            InvoiceFields {
              InvoiceValue from 'x'
              Dcemial Additional1 from 'somewhere'
            }
          }
        FDL
      end

      it 'tells us an unknown type has been used' do
        expect(generator.error).to eql("unknown type 'Dcemial' (neither primitive nor lookup) for Additional1")
      end
    end

    context 'management charge reference is invalid' do
      context 'it references a non-existent field' do
        context 'with a flat-rate calculation' do
          let(:source) do
            <<~FDL
              Framework RM5678 {
                Name 'x'
                ManagementCharge 0.5% of 'non-existent field'

                Lots { '99' -> 'Fake' }

                InvoiceFields {
                  InvoiceValue from 'Supplier Price'
                }
              }
            FDL
          end

          it 'has the parse failure' do
            expect(generator.error)
              .to match(/Management charge references 'non-existent field' which does not exist/)
          end
        end

        context 'with a column-based calculation' do
          let(:source) do
            <<~FDL
              Framework RM5678 {
                Name 'x'

                ManagementCharge varies_by 'non-existent field' {
                  'Lease Rental'     -> 0.5%
                  'Other Re-charges' -> 0%
                }

                Lots { '99' -> 'Fake' }

                InvoiceFields {
                  InvoiceValue from 'Supplier Price'
                }
              }
            FDL
          end

          it 'has the parse failure' do
            expect(generator.error)
              .to match(/Management charge references 'non-existent field' which does not exist/)
          end
        end
      end

      context 'it references an optional field' do
        context 'with a flat-rate calculation' do
          let(:source) do
            <<~FDL
              Framework RM5678 {
                Name 'x'
                ManagementCharge 0.5% of 'optionalfield'

                Lots { '99' -> 'Fake' }

                InvoiceFields {
                  optional String from 'optionalfield'
                  InvoiceValue from 'Supplier Price'
                }
              }
            FDL
          end

          it 'has the parse failure' do
            expect(generator.error)
              .to match(/Management charge references 'optionalfield' so it cannot be optional/)
          end
        end

        context 'with a column-based calculation' do
          let(:source) do
            <<~FDL
              Framework RM5678 {
                Name 'x'

                ManagementCharge varies_by 'Spend Code' {
                  'Lease Rental'                 -> 0.5%
                  'Other Re-charges'             -> 0%
                }

                Lots { '99' -> 'Fake' }

                InvoiceFields {
                  optional PromotionCode from 'Spend Code'
                  InvoiceValue from 'Supplier Price'
                }
              }
            FDL
          end

          it 'has the parse failure' do
            expect(generator.error)
              .to match(/Management charge references 'Spend Code' so it cannot be optional/)
          end
        end
      end
    end
  end
end
