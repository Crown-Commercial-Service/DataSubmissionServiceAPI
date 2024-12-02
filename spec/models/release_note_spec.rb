require 'rails_helper'

RSpec.describe ReleaseNote, type: :model do
  describe 'validations' do
    subject { create(:release_note) }
    it { is_expected.to validate_presence_of(:header) }
    it { is_expected.to validate_presence_of(:body) }
  end

  describe '#publish!' do
    let!(:release_note) {create :release_note}
    
    subject! { release_note.publish! }
    it 'sets published value to true' do
      release_note.reload
      expect(release_note.published).to be_truthy
    end
  end
end
