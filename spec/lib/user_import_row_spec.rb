require 'rails_helper'
require './lib/user_import_row'

RSpec.describe UserImportRow do
  describe '#initialize' do
    it 'throws an error if the hash is missing required fields' do
      auth0_client = instance_double('auth0 client')

      data = {
        personname: 'Daffy Duck'
      }

      expect { UserImportRow.new(data, auth0_client) }
        .to raise_error('UserImportRow::MissingKey')
    end
  end

  describe '#import!' do
    it 'creates a new user on Auth0' do
      data = {
        frameworkreference: 'RM3756',
        supplierid: 1234,
        suppliername: 'Bob and Bucket LLP',
        lotid: 5678,
        lotnumber: 1,
        username: 'francis.brown',
        personname: 'Francis Brown',
        jobtitle: 'Big Cheese',
        contacttel: '02088118055',
        contactmobile: '07900111222',
        email: 'francis.brown@example.com',
        usercreationdate: '1/1/1970 18:00',
        lastlogindate: '1/7/2018 12:40'
      }

      auth0_client = instance_double('auth0 client')

      expect(auth0_client)
        .to receive(:create_user)
        .with(
          'Francis Brown',
          a_hash_including(
            email: 'francis.brown@example.com'
          )
        )

      UserImportRow.new(data, auth0_client).import!
    end
  end
end
