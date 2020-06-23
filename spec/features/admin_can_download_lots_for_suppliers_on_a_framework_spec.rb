require 'rails_helper'

RSpec.feature 'Admin can download a list of lots and their suppliers on a framework' do
  before do
    sign_in_as_admin
  end

  scenario 'everything is fine' do
    create(:framework, name: 'G-Cloud 42', short_name: 'RM1234')

    travel_to Date.new(2020, 6, 17) do
      visit admin_frameworks_path
      click_link 'G-Cloud 42'
      click_link 'Download suppliers/lots'
    end

    expect(page.response_headers['Content-Type'])
      .to include 'text/csv'
    expect(page.response_headers['Content-Disposition'])
      .to eq 'attachment; filename="framework_rm1234_lots-2020-06-17.csv"'

    expect(page.body).to include 'framework_reference,framework_name,supplier_salesforce_id' \
    ',supplier_name,supplier_active,lot_number'
  end
end
