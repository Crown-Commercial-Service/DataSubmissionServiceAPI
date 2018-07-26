require 'rails_helper'

require './lib/user_import'

RSpec.describe UserImport do
  describe '#initialize' do
    it 'accepts CSV data and an Auth0 client as input' do
      client = instance_double('auth0 client')

      csv = "suppliername,email,personname\n"
      csv += "Vaughan Legal,email@example.com,Jo Bloggs\n"
      csv += "Vaughan Legal,email2@example.com,Francis Bloggs\n"

      expect { UserImport.new(csv, client) }.to_not raise_error
    end
  end

  describe '#run!' do
    it 'calls UserImportRow.import! for each row contained in the CSV' do
      client = instance_double('auth0 client')
      allow(client).to receive(:create_user).and_return('user_id' => 'auth0|user_id')

      csv = "suppliername,email,personname\n"
      csv += "Vaughan Legal,email@example.com,Jo Bloggs\n"
      csv += "Vaughan Legal,email2@example.com,Francis Bloggs\n"
      csv += "Vaughan Legal,email3@example.com,Alex Bloggs\n"

      UserImport.new(csv, client).run!

      expect(client).to have_received(:create_user).exactly(3).times
    end
  end
end
