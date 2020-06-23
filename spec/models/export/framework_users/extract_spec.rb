require 'rails_helper'

RSpec.describe Export::FrameworkUsers::Extract do
  describe '#all_relevant' do
    let(:all_relevant) { Export::FrameworkUsers::Extract.all_relevant(framework) }

    context 'with suppliers that have both active and inactive agreements on a framework' do
      let!(:framework) do
        create(:framework, name: 'G-Cloud 42', short_name: 'RM5678.42')
      end

      let!(:active_supplier) do
        create(:supplier, name: 'Active Technologies', salesforce_id: 'ACT123') do |supplier|
          create(:agreement, supplier: supplier, framework: framework, active: true)

          create_list(:user, 2) do |user|
            create(:membership, user: user, supplier: supplier)
          end
        end
      end

      let!(:inactive_supplier) do
        create(:supplier, name: 'Inactive Ltd', salesforce_id: 'INACT456') do |supplier|
          create(:agreement, supplier: supplier, framework: framework, active: false)

          create_list(:user, 3) do |user|
            create(:membership, user: user, supplier: supplier)
          end
        end
      end

      let!(:other_framework) do
        create(:framework, name: 'Other Framework') do |framework|
          create(:agreement, supplier: active_supplier, framework: framework)
        end
      end

      it 'includes both suppliers and their users for a given framework' do
        expect(all_relevant.size).to eql(5)
      end

      describe '#_framework_reference as a projection on the User model' do
        it 'is included in every result' do
          all_relevant.map(&:_framework_reference).each do |relevant|
            expect(relevant).to eql framework.short_name
          end
        end
      end

      describe '#_framework_name as a projection on the User model' do
        it 'is included in every result' do
          all_relevant.map(&:_framework_name).each do |relevant|
            expect(relevant).to eql framework.name
          end
        end
      end

      describe '#_supplier_name as a projection on the User model' do
        it 'contains both the active and inactive supplier the correct number of times' do
          extracted_supplier_names = all_relevant.map(&:_supplier_name)

          expect(extracted_supplier_names).to match_array(
            [
              active_supplier.name,
              active_supplier.name,
              inactive_supplier.name,
              inactive_supplier.name,
              inactive_supplier.name
            ]
          )
        end
      end

      describe '#_supplier_salesforce_id as a projection on the User model' do
        it 'contains both the active and inactive supplier the correct number of times' do
          extracted_supplier_salesforce_ids = all_relevant.map(&:_supplier_salesforce_id)

          expect(extracted_supplier_salesforce_ids).to match_array(
            [
              active_supplier.salesforce_id,
              active_supplier.salesforce_id,
              inactive_supplier.salesforce_id,
              inactive_supplier.salesforce_id,
              inactive_supplier.salesforce_id
            ]
          )
        end
      end

      describe '#_supplier_active as a projection on the User model' do
        it 'contains both the active and inactive supplier the correct number of times' do
          extracted_supplier_statuses = all_relevant.map(&:_supplier_active)

          expect(extracted_supplier_statuses).to match_array(
            [
              true,
              true,
              false,
              false,
              false
            ]
          )
        end
      end

      describe '#_user_name as a projection on the User model' do
        it 'is included in every result' do
          user_names = User.all.pluck(:name)
          extracted_user_names = all_relevant.map(&:_user_name)

          expect(extracted_user_names).to match_array(user_names)
        end
      end

      describe '#_user_email as a projection on the User model' do
        it 'is included in every result' do
          user_emails = User.all.pluck(:email)
          extracted_user_emails = all_relevant.map(&:_user_email)

          expect(extracted_user_emails). to match_array(user_emails)
        end
      end

      it 'excludes frameworks that were not requested' do
        expect(all_relevant.map(&:_framework_name)).not_to include 'Other Framework'
      end
    end
  end
end
