require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /tasks' do
    it 'creates a new task' do
      params = {
        status: 'test'
      }

      headers = {
        'CONTENT_TYPE': 'application/json'
      }

      post '/v1/tasks', params: params.to_json, headers: headers

      expect(response).to have_http_status(:created)

      task = Task.first

      expect(json['id']).to eql task.id
      expect(json['status']).to eql task.status
    end

    it 'returns an error if the status parameter is ommited' do
      params = {}

      headers = {
        'CONTENT_TYPE': 'application/json'
      }
      post '/v1/tasks', params: params.to_json, headers: headers

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'GET /tasks' do
    it 'returns a list of tasks' do
      FactoryBot.create(:task, status: 'test')
      FactoryBot.create(:task, status: 'ready')
      FactoryBot.create(:task, status: 'in progress')

      get '/v1/tasks'

      expect(response).to be_successful
      expect(json['tasks'].size).to eql 3

      expected = {
        tasks: [
          { status: 'test' },
          { status: 'ready'},
          { status: 'in progress'}
        ]
      }

      expect(response.body).to include_json(expected)
    end
  end

  describe 'GET /tasks?status=' do
    it 'returns a filtered list of tasks matching the statue value in the URL' do
      FactoryBot.create(:task, status: 'test')
      FactoryBot.create(:task, status: 'ready')
      FactoryBot.create(:task, status: 'in progress')

      get '/v1/tasks?status=test'

      expect(response).to be_successful
      expect(json['tasks'].size).to eql 1

      expected = {
        tasks: [
          { status: 'test' }
        ]
      }

      expect(response.body).to include_json(expected)
    end
  end
end
