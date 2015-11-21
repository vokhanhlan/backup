require 'rails_helper'

RSpec.describe Advertiser, :type => :model do
  describe 'Associations' do
    describe Advertiser do
      it { is_expected.to have_many(:experiences) }
    end
  end

  describe 'Enums' do
    it { is_expected.to define_enum_for :ad_type }
  end

  describe 'Validations' do
    before do
      @advertiser = Advertiser.new(
        name:    test_name,
        ad_type: test_type
      )
    end
    describe 'of presence' do
      describe 'in name:' do
        context 'When nil,' do
          let(:test_name) { nil }
          let(:test_type) { :pure_ad }
          it { expect(@advertiser).not_to be_valid }
          it { expect { @advertiser.save! }.to raise_error }
        end
        context 'When empty,' do
          let(:test_name) { '' }
          let(:test_type) { :pure_ad }
          it { expect(@advertiser).not_to be_valid }
          it { expect { @advertiser.save! }.to raise_error }
        end
        context 'When valid value,' do
          let(:test_name) { 'tomareru' }
          let(:test_type) { :pure_ad }
          it { expect(@advertiser).to be_valid }
          it { expect { @advertiser.save! }.not_to raise_error }
        end
      end
      describe 'in ad_type:' do
        context 'When nil,' do
          let(:test_name) { 'tomareru' }
          let(:test_type) { nil }
          it { expect(@advertiser).not_to be_valid }
          it { expect { @advertiser.save! }.to raise_error }
        end
        context 'When empty,' do
          let(:test_name) { 'tomareru' }
          let(:test_type) { '' }
          it { expect(@advertiser).not_to be_valid }
          it { expect { @advertiser.save! }.to raise_error }
        end
        context 'When valid value,' do
          let(:test_name) { 'tomareru' }
          let(:test_type) { :pure_ad }
          it { expect(@advertiser).to be_valid }
          it { expect { @advertiser.save! }.not_to raise_error }
        end
      end
    end
  end
end
