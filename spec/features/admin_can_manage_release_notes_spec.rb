require 'rails_helper'
RSpec.feature 'Managing release notes' do
  before do
    sign_in_as_admin
  end

  scenario 'create, edit and publish a new notification' do
    visit admin_release_notes_path

    expect(page).to have_text('No release notes')

    click_link 'New release note'

    expect(page).to have_text('Create a new release note')

    fill_in 'release_note_header', with: 'New feature'
    fill_in 'release_note_body', with: 'Have fun'
    click_button 'Save release note'

    expect(page).to have_text('Release note created successfully.')

    click_link 'New feature'
    click_link 'Edit'

    fill_in 'release_note_body', with: 'Don\'t do anything I wouldn\'t do'

    click_button 'Save release note'

    expect(page).to have_text('Release note updated successfully.')
    expect(page).to have_text('Don\'t do anything I wouldn\'t do')
    expect(page).not_to have_text('Have fun')

    click_link 'Publish'

    expect(page).to have_text('Release note published successfully.')
  end

  scenario 'header or body is empty' do
    visit new_admin_release_note_path
    click_button 'Save release note'

    expect(page).to have_text('Could not save release note')
    expect(page).to have_text('Header cannot be blank')
    expect(page).to have_text('Body cannot be blank')
  end

  scenario 'view past notifications' do
    number = 0
    2.times do
      visit new_admin_release_note_path
      fill_in 'release_note_header', with: "Testy McTestface #{number += 1}"
      fill_in 'release_note_body', with: "I'm number #{number}"
      click_button 'Save release note'
    end

    visit admin_release_notes_path

    expect(page).to have_text('Testy McTestface 1')
    expect(page).to have_text('Testy McTestface 2')

    click_link 'Testy McTestface 1'

    expect(page).to have_text('Testy McTestface 1')
    expect(page).to have_text('I\'m number 1')
  end
end
