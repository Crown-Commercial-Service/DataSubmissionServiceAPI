require 'rails_helper'
RSpec.feature 'Viewing a supplier' do
  let!(:supplier) { FactoryBot.create(:supplier, name: 'Test Supplier Ltd') }
  let!(:framework) { FactoryBot.create(:framework, name: 'Test Framework', short_name: 'RM0000') }
  let!(:agreement) { FactoryBot.create(:agreement, supplier: supplier, framework: framework) }

  before { sign_in_as_admin }

  scenario 'lists frameworks the supplier has an agreement for' do
    visit admin_supplier_path(supplier)
    expect(page).to have_content 'Test Supplier Ltd'
    expect(page).to have_content 'RM0000 Test Framework'
  end

  context 'with a task' do
    let!(:task) { FactoryBot.create(:task, supplier: supplier, framework: framework) }

    scenario 'shows tasks and submission with the status unstarted' do
      visit admin_supplier_path(supplier)
      expect(page).to have_content 'Unstarted'
    end

    context 'that is started' do
      scenario 'shows the status pending' do
        FactoryBot.create(
          :submission_with_pending_entries,
          supplier: supplier,
          framework: framework,
          task: task
        )

        visit admin_supplier_path(supplier)

        expect(page).to have_content 'Pending'
      end
    end

    context 'and a submission file processing' do
      scenario 'shows the status in processing' do
        FactoryBot.create(
          :submission_with_unprocessed_entries,
          supplier: supplier,
          framework: framework,
          task: task
        )

        visit admin_supplier_path(supplier)

        expect(page).to have_content 'Processing'
      end
    end

    context 'and a submission file ingested' do
      scenario 'shows the status in review' do
        FactoryBot.create(
          :submission_with_validated_entries,
          supplier: supplier,
          framework: framework,
          task: task,
          aasm_state: 'in_review'
        )
        visit admin_supplier_path(supplier)
        expect(page).to have_content 'In Review'
        expect(page).to have_content 'Download submission file'
      end
    end

    context 'and a submission file with errors' do
      scenario 'shows the status validation failed' do
        FactoryBot.create(
          :submission_with_invalid_entries,
          supplier: supplier,
          framework: framework,
          task: task
        )

        visit admin_supplier_path(supplier)

        expect(page).to have_content 'Validation Failed'
        expect(page).to have_content 'Download submission file'
      end
    end

    context 'that is completed' do
      scenario 'shows the status completed' do
        FactoryBot.create(
          :submission_with_validated_entries,
          supplier: supplier,
          framework: framework,
          task: task,
          aasm_state: 'completed'
        )

        visit admin_supplier_path(supplier)

        expect(page).to have_content 'Completed'
        expect(page).to have_content 'Download submission file'
      end
    end
  end
end
