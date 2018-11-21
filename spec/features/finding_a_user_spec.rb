require 'rails_helper'

RSpec.feature 'Finding a user' do
  before do
    @user1 = FactoryBot.create(:user, name: 'User One', email: 'email_one@ccs.co.uk')
    @user2 = FactoryBot.create(:user, name: 'User Two', email: 'email_two@ccs.co.uk')
    @user3 = FactoryBot.create(:user, name: 'User Three', email: 'email_three@ccs.co.uk')
    @supplier1 = FactoryBot.create(:supplier, name: 'Supplier Alpha')
    @supplier2 = FactoryBot.create(:supplier, name: 'Supplier Beta')
    @user1.suppliers << @supplier1
    @user2.suppliers << @supplier1
    @user2.suppliers << @supplier2
    sign_in_as_admin
  end

  scenario 'viewing all' do
    visit admin_users_path
    expect(page).to have_content 'User One'
    expect(page).to have_content 'User Two'
    expect(page).to have_content 'User Three'
  end

  scenario 'Searching by name' do
    visit admin_users_path
    fill_in 'Search', with: 'ser on'
    click_button 'Search'
    expect(page).to have_content 'User One'
    expect(page).to_not have_content 'User Two'
    expect(page).to_not have_content 'User Three'
  end

  scenario 'Searching by email' do
    visit admin_users_path
    fill_in 'Search', with: 'mail_two@ccs.co.u'
    click_button 'Search'
    expect(page).to_not have_content 'User One'
    expect(page).to have_content 'User Two'
    expect(page).to_not have_content 'User Three'
  end

  scenario 'Searching by supplier name' do
    visit admin_users_path
    fill_in 'Search', with: 'upplier alph'
    click_button 'Search'
    expect(page).to have_content 'User One'
    expect(page).to have_content 'User Two'
    expect(page).to_not have_content 'User Three'
  end
end
