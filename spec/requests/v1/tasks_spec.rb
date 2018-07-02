require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /tasks' do
    it 'creates a new task' do
      supplier = FactoryBot.create(:supplier)

      params = {
        data: {
          type: 'tasks',
          attributes: {
            status: 'test',
            supplier_id: supplier.id
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
      expect(json['data']).to have_attribute(:status).with_value('test')
      expect(json['data']).to have_attribute(:supplier_id).with_value(supplier.id)
    end

    it 'returns an error if the status parameter is omitted' do
      supplier = FactoryBot.create(:supplier)

      params = {
        data: {
          type: 'tasks',
          attributes: {
            supplier_id: supplier.id
          }
        }
      }

      headers = {
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json'
      }

      post '/v1/tasks', params: params.to_json, headers: headers

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'GET /tasks' do
    it 'returns a list of tasks' do
      task1 = FactoryBot.create(:task, status: 'test')
      task2 = FactoryBot.create(:task, status: 'ready')
      task3 = FactoryBot.create(:task, status: 'in progress')

      get '/v1/tasks'

      expect(response).to be_successful

      expect(json['data'][0]).to have_id(task1.id)
      expect(json['data'][0]).to have_attribute(:status).with_value('test')

      expect(json['data'][1]).to have_id(task2.id)
      expect(json['data'][1]).to have_attribute(:status).with_value('ready')

      expect(json['data'][2]).to have_id(task3.id)
      expect(json['data'][2]).to have_attribute(:status).with_value('in progress')
    end
  end

  describe 'GET /tasks?filter[status]=' do
    it 'returns a filtered list of tasks matching the statue value in the URL' do
      FactoryBot.create(:task, status: 'test')
      FactoryBot.create(:task, status: 'ready')
      FactoryBot.create(:task, status: 'in progress')

      get '/v1/tasks?filter[status]=ready'

      expect(response).to be_successful

      expect(json['data'].size).to eql 1
      expect(json['data'][0]).to have_attribute(:status).with_value('ready')
    end
  end

  describe 'GET /v1/tasks/:task_id' do
    it 'returns the details of a given task' do
      task = FactoryBot.create(
        :task,
        due_on: '2019-01-07',
        status: 'in progress',
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
        .with_value('in progress')
    end
  end

  describe 'POST /v1/tasks/:task_id/complete' do
    it "changes a task's status to completed" do
      task = FactoryBot.create(:task)

      post "/v1/tasks/#{task.id}/complete"

      expect(response).to be_successful

      task.reload

      expect(task.status).to eql 'completed'
    end
  end
end
