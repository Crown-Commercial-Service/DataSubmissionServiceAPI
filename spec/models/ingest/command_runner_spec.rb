require 'rails_helper'

RSpec.describe Ingest::CommandRunner do
  describe '#run!' do
    it 'executes the command given' do
      filename = "/tmp/#{SecureRandom.uuid}"

      command = "touch #{filename}"
      Ingest::CommandRunner.new(command).run!

      expect(File.exist?(filename)).to be_truthy
    ensure
      FileUtils.rm_f(filename)
    end

    it 'returns a Result object' do
      command = "echo 'hello world'"
      response = Ingest::CommandRunner.new(command).run!

      expect(response).to be_a(Ingest::CommandRunner::Result)
      expect(response).to be_successful
      expect(response.stdout).to include 'hello world'
      expect(response.stderr).to eql []
    end

    it 'returns a non-successful Result for a command that fails to execute' do
      command = 'nonexistent-command'
      response = Ingest::CommandRunner.new(command).run!

      expect(response).to_not be_successful
    end

    it 'returns a non-successful Result for a command that exits non-zero' do
      command = 'bash -c "exit 42"'
      response = Ingest::CommandRunner.new(command).run!

      expect(response).to_not be_successful
    end
  end
end
