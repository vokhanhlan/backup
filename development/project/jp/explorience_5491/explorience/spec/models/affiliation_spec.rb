require 'rails_helper'

RSpec.describe Affiliation, :type => :model do
  describe 'Associations' do
    describe Affiliation do
      it { is_expected.to belong_to(:experience) }
    end
  end

  describe 'Enums' do
    it { is_expected.to define_enum_for :action_type }
  end

  describe 'Validations' do
    before do
      @affiliation = Affiliation.new(
        experience_id: 1,
        user_id:       1,
        action_type:   test_type
      )
    end
    describe 'of presence' do
      describe 'in action_type:' do
        context 'When nil,' do
          let(:test_type) { nil }
          it { expect(@affiliation).not_to be_valid }
          it { expect { @affiliation.save! }.to raise_error }
        end
        context 'When empty,' do
          let(:test_type) { '' }
          it { expect(@affiliation).not_to be_valid }
          it { expect { @affiliation.save! }.to raise_error }
        end
        context 'When valid value,' do
          let(:test_type) { :impression }
          it { expect(@affiliation).to be_valid }
          it { expect { @affiliation.save! }.not_to raise_error }
        end
      end
    end
  end
end
