require 'rails_helper'

RSpec.feature 'Admin can download a list of users/suppliers on a framework' do
  before do
    sign_in_as_admin
  end

  scenario 'everything is fine' do
    create(:framework, name: 'G-Cloud 42', short_name: 'RM1234')

    travel_to Date.new(2020, 6, 17) do
      visit admin_frameworks_path
      click_link 'RM1234'
      click_link 'Download users'
    end

    expect(page.response_headers['Content-Type'])
      .to include 'text/csv'
    expect(page.response_headers['Content-Disposition'])
      .to include 'attachment; filename="framework_rm1234_users-2020-06-17.csv"'

    expect(page.body).to include 'framework_reference,framework_name,supplier_salesforce_id' \
    ',supplier_name,supplier_active,user_email,user_name'
  end
end
