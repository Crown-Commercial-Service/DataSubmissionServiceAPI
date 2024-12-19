require 'rails_helper'

RSpec.describe '/v1' do
  let(:user) { FactoryBot.create(:user) }

  let(:supplier) do
    supplier = FactoryBot.create(:supplier)
    Membership.create(supplier: supplier, user: user)
    supplier
  end

  describe 'GET /tasks' do
    it 'returns 401 if authentication needed and not provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/tasks', headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }
        expect(response.status).to eq(401)
      end
    end

    it 'returns 500 if X-Auth-Id header missing' do
      expect { get '/v1/tasks' }.to raise_error(ActionController::BadRequest)
    end

    it 'returns ok if authentication needed and provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/tasks', params: {}, headers: {
          HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials('dxw', 'sdfhg'),
          'X-Auth-Id' => JWT.encode(user.auth_id, 'test')
        }
        expect(response).to be_successful
      end
    end

    it 'returns a list of tasks' do
      task2 = FactoryBot.create(:task, status: 'unstarted', supplier: supplier)
      task3 = FactoryBot.create(:task, status: 'in_progress', supplier: supplier)

      get '/v1/tasks', headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful

      expect(json['data'].map { |data| data['id'] }).to contain_exactly(task2.id, task3.id)

      json_task2 = json['data'].find { |data| data['id'] == task2.id }
      expect(json_task2).to have_attribute(:status).with_value('unstarted')

      json_task3 = json['data'].find { |data| data['id'] == task3.id }
      expect(json_task3).to have_attribute(:status).with_value('in_progress')
    end

    it 'does not include tasks that do not belong to the current user' do
      FactoryBot.create(:task, status: 'unstarted', supplier: supplier)
      FactoryBot.create(:task, status: 'in_progress')

      get '/v1/tasks', headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful

      expect(json['data'].size).to eql 1
      expect(json['data'][0]).to have_attribute(:status).with_value('unstarted')
    end

    it 'can optionally include submissions' do
      task = FactoryBot.create(:task, supplier: supplier)
      submission = FactoryBot.create(:submission, task: task, aasm_state: 'pending', supplier: supplier)

      get '/v1/tasks?include=submissions', headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful
      expect(json['data'][0]).to have_id(task.id)
      expect(json['data'][0])
        .to have_relationship(:submissions)
        .with_data([{ 'id' => submission.id, 'type' => 'submissions' }])
      expect(json['included'][0])
        .to have_attribute(:status).with_value('pending')
    end

    it 'can optionally include the active_submission' do
      task = FactoryBot.create(:task, supplier: supplier)
      submission = FactoryBot.create(:submission, task: task, aasm_state: 'pending', supplier: supplier)

      get '/v1/tasks?include=active_submission', headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful
      expect(json['data'][0]).to have_id(task.id)
      expect(json['data'][0])
        .to have_relationship(:active_submission)
        .with_data('id' => submission.id, 'type' => 'submissions')

      expect(json['included'][0])
        .to have_attribute(:status).with_value('pending')
    end
  end

  describe 'GET /tasks?filter[status]=' do
    it 'returns a filtered list of tasks matching the statue value in the URL' do
      FactoryBot.create(:task, status: 'unstarted', supplier: supplier)
      FactoryBot.create(:task, status: 'unstarted', supplier: supplier)
      FactoryBot.create(:task, status: 'completed', supplier: supplier)

      get '/v1/tasks?filter[status]=completed', headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful

      expect(json['data'].size).to eql 1
      expect(json['data'][0]).to have_attribute(:status).with_value('completed')
    end
  end

  describe 'GET /tasks with a sparse fieldset specified' do
    it 'returns a list of tasks with only the attributes specified' do
      task = FactoryBot.create(:task, supplier: supplier, period_year: 1984)
      FactoryBot.create(:completed_submission, task: task, purchase_order_number: 'PO123')

      get '/v1/tasks?include=active_submission&fields[submissions]=status,invoice_count',
          headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful

      expect(json['data'].size).to eql 1
      expect(json['data'][0]).to have_attribute(:period_year).with_value(1984)
      expect(json['included'][0]).to have_attribute(:status).with_value('completed')
      expect(json['included'][0]).to have_attribute(:invoice_count).with_value(2)
      expect(json['included'][0]).not_to have_attribute(:purchase_order_number)
    end
  end

  describe 'GET /v1/tasks/:task_id' do
    it 'returns the details of a given task, without file_key' do
      task = FactoryBot.create(
        :task,
        due_on: '2019-01-07',
        status: 'in_progress',
        description: 'MI submission for December 2018 (cboard6)',
        supplier: supplier
      )

      get "/v1/tasks/#{task.id}", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful

      expect(json['data']).to have_id(task.id)
      expect(json['data'])
        .to have_attribute(:description)
        .with_value('MI submission for December 2018 (cboard6)')
      expect(json['data'])
        .to have_attribute(:due_on)
        .with_value('2019-01-07')
      expect(json['data'])
        .to have_attribute(:status)
        .with_value('in_progress')
      expect(json['data'])
        .to have_attribute(:file_key)
        .with_value(nil)
    end

    describe 'GET /v1/tasks/:task_id?include_file=true' do
      it 'returns the details of a given task, with file_key' do
        task = FactoryBot.create(
          :task,
          due_on: '2019-01-07',
          status: 'in_progress',
          description: 'MI submission for December 2018 (cboard6)',
          supplier: supplier
        )

        get "/v1/tasks/#{task.id}?include_file=true", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

        expect(response).to be_successful

        expect(json['data'])
          .to have_attribute(:file_key)
          .with_value(task.framework.file_key)
      end
    end

    it 'can optionally return included models' do
      task = FactoryBot.create(:task, supplier: supplier)
      submission = FactoryBot.create(:submission, task: task, aasm_state: 'pending', supplier: supplier)

      get "/v1/tasks/#{task.id}?include=submissions", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful
      expect(json['data']).to have_id(task.id)
      expect(json['data'])
        .to have_relationship(:submissions)
      expect(json['included'][0])
        .to have_id(submission.id)
    end

    it "prevents a user seeing someone else's task" do
      task = FactoryBot.create(:task)

      expect do
        get "/v1/tasks/#{task.id}", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'GET /v1/tasks/index_by_supplier' do
    it 'returns a list of tasks grouped by supplier' do
      supplier2 = FactoryBot.create(:supplier)
      Membership.create(supplier: supplier2, user: user)
      FactoryBot.create(:task, status: 'unstarted', supplier: supplier)
      FactoryBot.create(:task, status: 'unstarted', supplier: supplier2)
      FactoryBot.create(:task, status: 'in_progress', supplier: supplier)

      get '/v1/tasks/index_by_supplier', headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful
      expect(json['data'].size).to eql 2

      expect(json['data'].map { |data| data['id'] }).to contain_exactly(supplier.id, supplier2.id)
      expect(json['data'][0]).to have_attribute(:name)

      json_task1 = json['included'][0]
      expect(json_task1).to have_attribute(:status).with_value('unstarted')
    end
  end

  describe 'POST /v1/tasks/:task_id/no_business' do
    let(:task) { FactoryBot.create(:task, supplier: supplier) }

    it 'marks the task as completed' do
      post "/v1/tasks/#{task.id}/no_business", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(task.reload).to be_completed
    end

    it 'creates and returns a completed submission' do
      post "/v1/tasks/#{task.id}/no_business", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to have_http_status(:created)

      submission = task.submissions.last

      expect(json['data']).to have_id submission.id
      expect(json['data']['attributes']['status']).to eq 'completed'
    end

    it 'records the user who created the submission' do
      post "/v1/tasks/#{task.id}/no_business", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      submission = task.submissions.last

      expect(submission.created_by).to eq(user)
    end

    it 'records the user who completed the submission' do
      post "/v1/tasks/#{task.id}/no_business", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      submission = task.submissions.last

      expect(submission.submitted_by).to eq(user)
    end

    it 'records the time of submission' do
      submission_time = Time.zone.local(2018, 2, 10, 12, 13, 14)

      travel_to(submission_time) do
        post "/v1/tasks/#{task.id}/no_business", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

        submission = task.submissions.last

        expect(submission.submitted_at).to eq(submission_time)
      end
    end

    it "prevents a user from reporting no business on someone else's task" do
      task = FactoryBot.create(:task)

      expect do
        post "/v1/tasks/#{task.id}/no_business", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'if task already completed' do
      it 'should do nothing and return the latest submission' do
        FactoryBot.create(:submission, task: task)
        submission = task.file_no_business!(user)

        post "/v1/tasks/#{task.id}/no_business", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

        expect(json['data']).to have_id submission.id
      end
    end

    context 'if correcting an existing completed submission' do
      let!(:submission) { FactoryBot.create(:completed_submission, task: task) }
      let(:body) { { correction: true }.to_json }

      before do
        task.update(status: 'completed')
      end

      it 'updates the old submission to replaced' do
        post "/v1/tasks/#{task.id}/no_business",
             headers: json_headers.merge('X-Auth-Id' => JWT.encode(user.auth_id, 'test')), params: body
        submission.reload
        expect(submission.aasm_state).to eq('replaced')
      end

      it 'creates a new no business submission' do
        expect do
          post "/v1/tasks/#{task.id}/no_business",
               headers: json_headers.merge('X-Auth-Id' => JWT.encode(user.auth_id, 'test')),
               params: body
        end.to change { task.submissions.count }.by(1)
        expect(task.active_submission.report_no_business?).to be true
      end

      it 'returns the completed submission' do
        post "/v1/tasks/#{task.id}/no_business",
             headers: json_headers.merge('X-Auth-Id' => JWT.encode(user.auth_id, 'test')), params: body

        task.reload
        new_submission = task.active_submission

        expect(response).to have_http_status(:created)
        expect(json['data']).to have_id new_submission.id
        expect(json['data']['attributes']['status']).to eq 'completed'
      end

      it 'keeps the task as completed' do
        post "/v1/tasks/#{task.id}/no_business",
             headers: json_headers.merge('X-Auth-Id' => JWT.encode(user.auth_id, 'test')), params: body
        task.reload
        expect(task.status).to eq('completed')
      end
    end
  end

  describe 'POST /v1/tasks/:task_id/complete' do
    it "changes a task's status to completed" do
      task = FactoryBot.create(:task, supplier: supplier)

      post "/v1/tasks/#{task.id}/complete", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }

      expect(response).to be_successful

      task.reload

      expect(task).to be_completed
    end

    it "prevents a user completing someone else's task" do
      task = FactoryBot.create(:task)

      expect do
        post "/v1/tasks/#{task.id}/complete", headers: { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'PATCH /v1/tasks/:task_id' do
    it "updates a task's attributes" do
      task = FactoryBot.create(:task, supplier: supplier)

      params = {
        data: {
          type: 'tasks',
          attributes: {
            status: 'in_progress'
          }
        }
      }

      patch "/v1/tasks/#{task.id}", params: params.to_json,
headers: json_headers.merge('X-Auth-Id' => JWT.encode(user.auth_id, 'test'))

      expect(response).to be_successful

      task.reload

      expect(task).to be_in_progress
    end
  end

  describe 'PATCH /v1/tasks/:task_id/cancel_correction' do
    it 'deletes incomplete correction submissions and updates the task status' do
      task = FactoryBot.create(:task, supplier: supplier, status: 'correcting')
      old_submission_completed = FactoryBot.create(:completed_submission,
                                                   task: task,
                                                   created_at: 3.days.ago,
                                                   aasm_state: 'completed')
      FactoryBot.create(:submission_with_invalid_entries,
                        task: task,
                        created_at: 2.days.ago)
      FactoryBot.create(:submission_with_validated_entries,
                        task: task,
                        created_at: 1.day.ago,
                        aasm_state: 'in_review')

      patch "/v1/tasks/#{task.id}/cancel_correction",
            headers: json_headers.merge('X-Auth-Id' => JWT.encode(user.auth_id, 'test'))

      expect(response).to be_successful

      task.reload

      expect(task).to be_completed
      expect(task.submissions).to eq([old_submission_completed])
    end

    it 'returns an error if attempting to do this on a non correcting task' do
      task = FactoryBot.create(:task, supplier: supplier, status: 'completed')
      expect do
        patch "/v1/tasks/#{task.id}/cancel_correction",
              headers: json_headers.merge('X-Auth-Id' => JWT.encode(user.auth_id, 'test'))
      end.to raise_error(AASM::InvalidTransition)
    end
  end
end
