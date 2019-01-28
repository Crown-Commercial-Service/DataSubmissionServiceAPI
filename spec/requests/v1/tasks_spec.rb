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
        get '/v1/tasks', headers: { 'X-Auth-Id' => user.auth_id }
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
          'X-Auth-Id' => user.auth_id
        }
        expect(response).to be_successful
      end
    end

    it 'returns a list of tasks' do
      task2 = FactoryBot.create(:task, status: 'unstarted', supplier: supplier)
      task3 = FactoryBot.create(:task, status: 'in_progress', supplier: supplier)

      get '/v1/tasks', headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to be_successful

      expect(json['data'][0]).to have_id(task3.id)
      expect(json['data'][0]).to have_attribute(:status).with_value('in_progress')

      expect(json['data'][1]).to have_id(task2.id)
      expect(json['data'][1]).to have_attribute(:status).with_value('unstarted')
    end

    it 'does not include tasks that do not belong to the current user' do
      FactoryBot.create(:task, status: 'unstarted', supplier: supplier)
      FactoryBot.create(:task, status: 'in_progress')

      get '/v1/tasks', headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to be_successful

      expect(json['data'].size).to eql 1
      expect(json['data'][0]).to have_attribute(:status).with_value('unstarted')
    end

    it 'can optionally include submissions' do
      task = FactoryBot.create(:task, supplier: supplier)
      submission = FactoryBot.create(:submission, task: task, aasm_state: 'pending', supplier: supplier)

      get '/v1/tasks?include=submissions', headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to be_successful
      expect(json['data'][0]).to have_id(task.id)
      expect(json['data'][0])
        .to have_relationship(:submissions)
        .with_data([{ 'id' => submission.id, 'type' => 'submissions' }])
      expect(json['included'][0])
        .to have_attribute(:status).with_value('pending')
    end

    it 'can optionally include the latest_submission' do
      task = FactoryBot.create(:task, supplier: supplier)
      submission = FactoryBot.create(:submission, task: task, aasm_state: 'pending', supplier: supplier)

      get '/v1/tasks?include=latest_submission', headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to be_successful
      expect(json['data'][0]).to have_id(task.id)
      expect(json['data'][0])
        .to have_relationship(:latest_submission)
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

      get '/v1/tasks?filter[status]=completed', headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to be_successful

      expect(json['data'].size).to eql 1
      expect(json['data'][0]).to have_attribute(:status).with_value('completed')
    end
  end

  describe 'GET /tasks?filter[supplier_id]=' do
    it 'returns a filtered list of tasks for a supplier' do
      current_supplier = FactoryBot.create(:supplier)
      another_supplier = FactoryBot.create(:supplier)

      user.memberships.create(supplier: current_supplier)
      user.memberships.create(supplier: another_supplier)

      FactoryBot.create(:task, supplier: current_supplier, description: 'hello')
      FactoryBot.create(:task, supplier: another_supplier)

      get "/v1/tasks?filter[supplier_id]=#{current_supplier.id}", headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to be_successful

      expect(json['data'].size).to eql 1
      expect(json['data'][0]).to have_attribute(:description).with_value('hello')
    end
  end

  describe 'GET /v1/tasks/:task_id' do
    it 'returns the details of a given task' do
      task = FactoryBot.create(
        :task,
        due_on: '2019-01-07',
        status: 'in_progress',
        description: 'MI submission for December 2018 (cboard6)',
        supplier: supplier
      )

      get "/v1/tasks/#{task.id}", headers: { 'X-Auth-Id' => user.auth_id }

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
    end

    it 'can optionally return included models' do
      task = FactoryBot.create(:task, supplier: supplier)
      submission = FactoryBot.create(:submission, task: task, aasm_state: 'pending', supplier: supplier)

      get "/v1/tasks/#{task.id}?include=submissions", headers: { 'X-Auth-Id' => user.auth_id }

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
        get "/v1/tasks/#{task.id}", headers: { 'X-Auth-Id' => user.auth_id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST /v1/tasks/:task_id/no_business' do
    let(:task) { FactoryBot.create(:task, supplier: supplier) }

    it 'marks the task as completed' do
      post "/v1/tasks/#{task.id}/no_business", headers: { 'X-Auth-Id' => user.auth_id }

      expect(task.reload).to be_completed
    end

    it 'creates and returns a completed submission' do
      post "/v1/tasks/#{task.id}/no_business", headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to have_http_status(:created)

      submission = task.submissions.last

      expect(json['data']).to have_id submission.id
      expect(json['data']['attributes']['status']).to eq 'completed'
    end

    it 'records the user who submitted' do
      post "/v1/tasks/#{task.id}/no_business", headers: { 'X-Auth-Id' => user.auth_id }

      submission = task.submissions.last

      expect(submission.created_by).to eq(user)
    end

    it "prevents a user from reporting no business on someone else's task" do
      task = FactoryBot.create(:task)

      expect do
        post "/v1/tasks/#{task.id}/no_business", headers: { 'X-Auth-Id' => user.auth_id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'if task already completed' do
      it 'should do nothing and return succesfully' do
        task.file_no_business!(user)

        post "/v1/tasks/#{task.id}/no_business", headers: { 'X-Auth-Id' => user.auth_id }

        submission = task.submissions.last

        expect(json['data']).to have_id submission.id
      end
    end
  end

  describe 'POST /v1/tasks/:task_id/complete' do
    it "changes a task's status to completed" do
      task = FactoryBot.create(:task, supplier: supplier)

      post "/v1/tasks/#{task.id}/complete", headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to be_successful

      task.reload

      expect(task).to be_completed
    end

    it "prevents a user completing someone else's task" do
      task = FactoryBot.create(:task)

      expect do
        post "/v1/tasks/#{task.id}/complete", headers: { 'X-Auth-Id' => user.auth_id }
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

      patch "/v1/tasks/#{task.id}", params: params.to_json, headers: json_headers.merge('X-Auth-Id' => user.auth_id)

      expect(response).to be_successful

      task.reload

      expect(task).to be_in_progress
    end
  end
end
