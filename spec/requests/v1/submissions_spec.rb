require 'rails_helper'

RSpec.describe '/v1' do
  let(:user) { FactoryBot.create(:user) }

  let(:supplier) do
    supplier = FactoryBot.create(:supplier)
    supplier.memberships.create(user: user)
    supplier
  end

  describe 'GET /submissions/:submission_id' do
    it 'returns the requested submission' do
      submission = FactoryBot.create(:submission, supplier: supplier)

      get "/v1/submissions/#{submission.id}", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful

      expect(json['data']).to have_id(submission.id)

      expect(json['data']).to have_attributes(
        :framework_id, :supplier_id, :task_id,
        :purchase_order_number, :status,
        :invoice_count, :order_count, :other_count,
        :invoice_total_value, :order_total_value,
        :sheet_errors, :report_no_business?, :submitted_at,
        :submitter, :file_key, :filename
      )
    end

    it 'optionally includes submission files' do
      submission = FactoryBot.create(:submission, supplier: supplier)
      file = FactoryBot.create(:submission_file, submission: submission)

      get "/v1/submissions/#{submission.id}?include=files", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful
      expect(json['data']).to have_id(submission.id)
      expect(json['data'])
        .to have_relationship(:files)
        .with_data([{ 'id' => file.id, 'type' => 'submission_files' }])
    end

    it 'optionally includes submission framework' do
      framework = FactoryBot.create(:framework, short_name: 'RM1234')
      submission = FactoryBot.create(:submission, framework: framework, supplier: supplier)

      get "/v1/submissions/#{submission.id}?include=framework",
          headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }
      expect(response).to be_successful

      expect(json['data']).to have_id(submission.id)
      expect(json['data'])
        .to have_relationship(:framework)
        .with_data('id' => framework.id, 'type' => 'frameworks')
      expect(json['included'][0].dig('attributes', 'short_name')).to eql 'RM1234'
    end

    it 'returns 404 if the submission does not belong to the current user' do
      bad_user = FactoryBot.create(:user)
      submission = FactoryBot.create(:submission, supplier: supplier)

      expect do
        get "/v1/submissions/#{submission.id}", headers: { 'X-Auth-Id' => JWT.encode(bad_user.auth_id, 'test') }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST /submissions' do
    let(:framework) { FactoryBot.create(:framework) }
    let(:task) { FactoryBot.create(:task, framework: framework, supplier: supplier) }
    let(:params) do
      {
        data: {
          type: 'submissions',
          attributes: {
            task_id: task.id,
            purchase_order_number: 'INV-123'
          }
        }
      }
    end

    context 'with no previous completed submission against the task' do
      it 'creates a new submission and returns its id' do
        post "/v1/submissions?task_id=#{task.id}",
             params: params.to_json,
             headers: json_headers.merge('X-Auth-Id' => JWT.encode(user.auth_id, 'test'))

        expect(response).to have_http_status(:created)

        submission = Submission.first

        expect(json['data']).to have_id(submission.id)
        expect(json['data']).to have_attribute(:framework_id).with_value(framework.id)
        expect(json['data']).to have_attribute(:supplier_id).with_value(supplier.id)
        expect(json['data']).to have_attribute(:task_id).with_value(task.id)
        expect(json['data']).to have_attribute(:purchase_order_number).with_value('INV-123')
      end

      it 'records the user who created the submission' do
        post "/v1/submissions?task_id=#{task.id}",
             params: params.to_json,
             headers: json_headers.merge('X-Auth-Id' => JWT.encode(user.auth_id, 'test'))

        submission = Submission.first

        expect(submission.created_by).to eq(user)
      end
    end

    context 'when there is a completed submission against the task' do
      let!(:old_submission) { FactoryBot.create(:submission, task: task, aasm_state: 'completed') }
      before do
        task.completed!
      end

      context 'and it is not a correction' do
        it 'does not create a new submission' do
          expect do
            post "/v1/submissions?task_id=#{task.id}",
                 params: params.to_json,
                 headers: json_headers.merge('X-Auth-Id' => JWT.encode(user.auth_id, 'test'))
          end.to_not change { task.submissions.count }
        end

        it 'responds with an error status' do
          post "/v1/submissions?task_id=#{task.id}",
               params: params.to_json,
               headers: json_headers.merge('X-Auth-Id' => JWT.encode(user.auth_id, 'test'))

          expect(response).to_not be_successful
        end
      end

      context 'and it is a correction' do
        before do
          params[:data][:attributes][:correction] = 'true'
        end

        it 'creates a new submission and returns its id' do
          expect do
            post "/v1/submissions?task_id=#{task.id}",
                 params: params.to_json,
                 headers: json_headers.merge('X-Auth-Id' => JWT.encode(user.auth_id, 'test'))
          end.to change { task.submissions.count }.by(1)
        end
      end
    end
  end

  describe 'POST /submissions/:submission_id/complete' do
    context 'given a valid submission' do
      let(:task) { FactoryBot.create(:task, status: :in_progress) }
      let(:submission) do
        FactoryBot.create(
          :submission_with_validated_entries,
          aasm_state: :in_review,
          task: task
        )
      end

      context 'with no previous completed submission against the task' do
        it 'marks the submission as complete' do
          post "/v1/submissions/#{submission.id}/complete", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

          expect(response).to be_successful

          submission.reload

          expect(submission).to be_completed
          expect(submission.task).to be_completed
        end

        it 'records the user who completed the submission' do
          post "/v1/submissions/#{submission.id}/complete", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

          submission.reload

          expect(submission.submitted_by).to eq(user)
        end

        it 'records the submission completion time' do
          submission_time = Time.zone.local(2018, 2, 10, 12, 13, 14)

          travel_to(submission_time) do
            post "/v1/submissions/#{submission.id}/complete",
                 headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

            submission.reload

            expect(submission.submitted_at).to eq(submission_time)
          end
        end
      end

      context 'when there is a completed submission against the task' do
        let(:task) { FactoryBot.create(:task, status: :completed) }
        let!(:old_submission) do
          FactoryBot.create(
            :submission_with_validated_entries,
            aasm_state: 'completed',
            task: task
          )
        end

        it 'marks the submission as completed AND the old submission is replaced' do
          post "/v1/submissions/#{submission.id}/complete", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

          expect(response).to be_successful

          old_submission.reload
          expect(old_submission).to be_replaced

          submission.reload
          expect(submission).to be_completed
        end
      end
    end
  end
end
