require 'rails_helper'

RSpec.describe Export::FrameworkSuppliersLots::Extract do
  describe '#all_relevant' do
    let(:all_relevant) { Export::FrameworkSuppliersLots::Extract.all_relevant(framework) }

    context 'with suppliers that have both active and inactive lots on a framework' do
      let!(:framework) do
        create(:framework, name: 'G-Cloud 42', short_name: 'RM5678.42')
      end

      let!(:active_supplier) do
        create(:supplier, name: 'Active Technologies', salesforce_id: 'ACT123') do |supplier|
          create(:agreement, supplier: supplier, framework: framework, active: true) do |agreement|
            create(:agreement_framework_lot, agreement: agreement, framework_lot: lot_1a)
            create(:agreement_framework_lot, agreement: agreement, framework_lot: lot_2b)
          end
        end
      end

      let!(:inactive_supplier) do
        create(:supplier, name: 'Inactive Ltd', salesforce_id: 'INACT456') do |supplier|
          create(:agreement, supplier: supplier, framework: framework, active: false) do |agreement|
            create(:agreement_framework_lot, agreement: agreement, framework_lot: lot_3)
          end
        end
      end

      let!(:supplier_not_on_lots) do
        create(:supplier, name: 'Forget Me Lots Ltd', salesforce_id: 'NOT000') do |supplier|
          create(:agreement, supplier: supplier, framework: framework, active: false)
        end
      end

      let!(:lot_1a) { create(:framework_lot, framework: framework, number: '1a') }

      let!(:lot_2b) { create(:framework_lot, framework: framework, number: '2b') }

      let!(:lot_3) { create(:framework_lot, framework: framework, number: '3') }

      let!(:other_framework) do
        create(:framework, name: 'Other Framework') do |framework|
          create(:agreement, supplier: active_supplier, framework: framework)
        end
      end

      it 'includes all suppliers and their lots for a given framework' do
        expect(all_relevant.size).to eql(3)
      end

      describe '#_framework_reference as a projection on the AgreementFrameworkLot model' do
        it 'is included in every result' do
          all_relevant.map(&:_framework_reference).each do |relevant|
            expect(relevant).to eql framework.short_name
          end
        end
      end

      describe '#_framework_name as a projection on the AgreementFrameworkLot model' do
        it 'is included in every result' do
          all_relevant.map(&:_framework_name).each do |relevant|
            expect(relevant).to eql framework.name
          end
        end
      end

      describe '#_supplier_name as a projection on the AgreementFrameworkLot model' do
        it 'contains the suppliers the correct number of times' do
          extracted_supplier_names = all_relevant.map(&:_supplier_name)

          expect(extracted_supplier_names).to match_array(
            [
              active_supplier.name,
              active_supplier.name,
              inactive_supplier.name
            ]
          )
        end
      end

      describe '#_supplier_salesforce_id as a projection on the AgreementFrameworkLot model' do
        it 'contains the suppliers the correct number of times' do
          extracted_supplier_salesforce_ids = all_relevant.map(&:_supplier_salesforce_id)

          expect(extracted_supplier_salesforce_ids).to match_array(
            [
              active_supplier.salesforce_id,
              active_supplier.salesforce_id,
              inactive_supplier.salesforce_id
            ]
          )
        end
      end

      describe '#_supplier_active as a projection on the AgreementFrameworkLot model' do
        it 'contains the suppliers on one or more lots' do
          extracted_supplier_statuses = all_relevant.map(&:_supplier_active)

          expect(extracted_supplier_statuses).to match_array(
            [
              true,
              true,
              false
            ]
          )
        end
      end

      describe '#_lot_number as a projection on the AgreementFrameworkLot model' do
        it 'contains the lot numbers of frameworks the suppliers belongs to' do
          extracted_lot_numbers = all_relevant.map(&:_lot_number)

          expect(extracted_lot_numbers).to match_array(
            [
              '1a',
              '2b',
              '3'
            ]
          )
        end
      end

      it 'excludes frameworks that were not requested' do
        expect(all_relevant.map(&:_framework_name)).not_to include 'Other Framework'
      end

      it 'excludes suppliers not on any lots' do
        expect(all_relevant.map(&:_supplier_name)).not_to include 'Forget Me Lots Ltd'
      end
    end
  end
end
