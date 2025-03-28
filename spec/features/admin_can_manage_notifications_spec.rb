require 'rails_helper'
RSpec.feature 'Managing notifications' do
  before do
    sign_in_as_admin
  end

  scenario 'create a new notification' do
    visit admin_notifications_path

    expect(page).to have_text('No notification currently published')

    click_link 'Create a new notification'

    expect(page).to have_text('Create a new notification')

    fill_in 'notification_summary', with: 'Urgent update!'
    fill_in 'notification_notification_message', with: 'Oh never mind.'
    click_button 'Publish Notification'

    expect(page).to have_text('Notification created successfully.')
    expect(page).to have_content('Urgent update!')
    expect(page).to have_content('Oh never mind.')
  end

  scenario 'summary or notification message is empty' do
    visit new_admin_notification_path
    click_button 'Publish Notification'

    expect(page).to have_text('Summary cannot be blank')
    expect(page).to have_text('Notification message cannot be blank')
  end

  scenario 'unpublish current notification' do
    visit new_admin_notification_path
    fill_in 'notification_summary', with: 'Urgent update!'
    fill_in 'notification_notification_message', with: 'Oh never mind.'
    click_button 'Publish Notification'

    expect(page).to have_text('Current notification')
    expect(page).not_to have_text('No notification currently published')

    click_link 'Unpublish'

    expect(page).not_to have_text('Current notification')
    expect(page).to have_text('Notification was successfully unpublished.')
    expect(page).to have_text('No notification currently published')
  end

  scenario 'edit current notification but keep a record' do
    visit new_admin_notification_path
    fill_in 'notification_summary', with: 'Just FYI'
    fill_in 'notification_notification_message', with: 'You should wear sunscreen'
    click_button 'Publish Notification'

    expect(page).to have_text('Current notification')
    expect(page).to have_text('Edit')

    click_link 'Edit'

    expect(page).to have_text('Just FYI')
    expect(page).to have_text('sunscreen')

    fill_in 'notification_summary', with: 'Just FYI2'
    fill_in 'notification_notification_message', with: 'Drink water'
    click_button 'Publish Notification'

    expect(page).to have_text('Notification created successfully.')
    expect(page).to have_text('Just FYI')
    expect(page).to have_text('Just FYI 2')
    expect(page).to have_text('Drink water')
  end

  scenario 'view past notifications' do
    number = 0
    2.times do
      visit new_admin_notification_path
      fill_in 'notification_summary', with: "Testy McTestface #{number += 1}"
      fill_in 'notification_notification_message', with: "I'm number #{number}"
      click_button 'Publish Notification'
    end

    visit admin_notifications_path

    expect(page).to have_text('Testy McTestface 1')
    expect(page).to have_text('Testy McTestface 2')

    click_link 'Testy McTestface 1'

    expect(page).to have_text('Testy McTestface 1')
    expect(page).to have_text('I\'m number 1')
  end
end
