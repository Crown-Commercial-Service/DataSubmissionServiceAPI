require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /tasks' do
    it 'creates a new task' do
      supplier = FactoryBot.create(:supplier)
      framework = FactoryBot.create(:framework)

      params = {
        data: {
          type: 'tasks',
          attributes: {
            supplier_id: supplier.id,
            framework_id: framework.id,
            due_on: '2020-12-25',
            period_month: 11,
            period_year: 2019,
            description: 'test'
          }
        }
      }

      headers = {
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json'
      }

      post '/v1/tasks', params: params.to_json, headers: headers

      expect(response).to have_http_status(:created)

      task = Task.first

      expect(json['data']).to have_id(task.id)
      expect(json['data']).to have_attribute(:supplier_id).with_value(supplier.id)
      expect(json['data']).to have_attribute(:framework_id).with_value(framework.id)
      expect(json['data']).to have_attribute(:due_on).with_value('2020-12-25')
      expect(json['data']).to have_attribute(:period_month).with_value(11)
      expect(json['data']).to have_attribute(:period_year).with_value(2019)
      expect(json['data']).to have_attribute(:description).with_value('test')
    end
  end

  describe 'GET /tasks' do
    it 'returns a list of tasks' do
      task1 = FactoryBot.create(:task, status: 'draft')
      task2 = FactoryBot.create(:task, status: 'unstarted')
      task3 = FactoryBot.create(:task, status: 'in_progress')

      get '/v1/tasks'

      expect(response).to be_successful

      expect(json['data'][0]).to have_id(task1.id)
      expect(json['data'][0]).to have_attribute(:status).with_value('draft')

      expect(json['data'][1]).to have_id(task2.id)
      expect(json['data'][1]).to have_attribute(:status).with_value('unstarted')

      expect(json['data'][2]).to have_id(task3.id)
      expect(json['data'][2]).to have_attribute(:status).with_value('in_progress')
    end
  end

  describe 'GET /tasks?filter[status]=' do
    it 'returns a filtered list of tasks matching the statue value in the URL' do
      FactoryBot.create(:task, status: 'draft')
      FactoryBot.create(:task, status: 'draft')
      FactoryBot.create(:task, status: 'complete')

      get '/v1/tasks?filter[status]=complete'

      expect(response).to be_successful

      expect(json['data'].size).to eql 1
      expect(json['data'][0]).to have_attribute(:status).with_value('complete')
    end
  end

  describe 'GET /tasks?filter[supplier_id]=' do
    it 'returns a filtered list of tasks for a supplier' do
      current_supplier = FactoryBot.create(:supplier)
      another_supplier = FactoryBot.create(:supplier)

      FactoryBot.create(:task, supplier: current_supplier, description: 'hello')
      FactoryBot.create(:task, supplier: another_supplier)

      get "/v1/tasks?filter[supplier_id]=#{current_supplier.id}"

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
        description: 'MI submission for December 2018 (cboard6)'
      )

      get "/v1/tasks/#{task.id}"

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
  end

  describe 'POST /v1/tasks/:task_id/complete' do
    it "changes a task's status to completed" do
      task = FactoryBot.create(:task)

      post "/v1/tasks/#{task.id}/complete"

      expect(response).to be_successful

      task.reload

      expect(task).to be_complete
    end
  end
end
