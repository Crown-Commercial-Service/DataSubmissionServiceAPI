require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /tasks' do
    it 'creates a new task' do
      params = {
        data: {
          type: 'tasks',
          attributes: {
            status: 'test'
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
    end

    it 'returns an error if the status parameter is omitted' do
      params = {
        data: {
          type: 'tasks',
          attributes: {}
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

  describe 'POST /v1/tasks/:task_id/complete' do
    it "changes a task's status to completed" do
      task = FactoryBot.create(:task, status: 'in progress')

      post "/v1/tasks/#{task.id}/complete"

      expect(response).to be_successful

      task.reload

      expect(task.status).to eql 'completed'
    end
  end
end
