require 'rails_helper'

RSpec.describe Reporter, :type => :model do
  describe 'Associations' do
    describe Reporter do
      it { is_expected.to belong_to(:invalid_image) }
    end
  end

  describe 'Enums' do
    it { is_expected.to define_enum_for :invalid_type }
  end

  describe 'Validations' do
    before do
      @reporter = Reporter.new(
        invalid_image_id: 1,
        user_id:          2,
        email:            test_email,
        invalid_type:     test_type,
        reason:           'Some reason.'
      )
    end
    describe 'of presence' do
      describe 'in email:' do
        context 'When nil,' do
          let(:test_email) { nil }
          let(:test_type)  { :copylight }
          it { expect(@reporter).not_to be_valid }
          it { expect { @reporter.save! }.to raise_error }
        end
        context 'When empty,' do
          let(:test_email) { '' }
          let(:test_type)  { :copylight }
          it { expect(@reporter).not_to be_valid }
          it { expect { @reporter.save! }.to raise_error }
        end
        context 'When valid value,' do
          let(:test_email) { 'test@test.com' }
          let(:test_type)  { :copylight }
          it { expect(@reporter).to be_valid }
          it { expect { @reporter.save! }.not_to raise_error }
        end
      end
      describe 'in invalid_type:' do
        context 'When nil,' do
          let(:test_email) { 'test@test.com' }
          let(:test_type)  { nil }
          it { expect(@reporter).not_to be_valid }
          it { expect { @reporter.save! }.to raise_error }
        end
        context 'When empty,' do
          let(:test_email) { 'test@test.com' }
          let(:test_type)  { '' }
          it { expect(@reporter).not_to be_valid }
          it { expect { @reporter.save! }.to raise_error }
        end
        context 'When valid value,' do
          let(:test_email) { 'test@test.com' }
          let(:test_type)  { :copylight }
          it { expect(@reporter).to be_valid }
          it { expect { @reporter.save! }.not_to raise_error }
        end
      end
    end
    describe 'of format' do
      describe 'in email:' do
        context 'When wrong format,' do
          let(:test_email) { 'wrong_format_email' }
          let(:test_type)  { :copylight }
          it { expect(@reporter).not_to be_valid }
          it { expect { @reporter.save! }.to raise_error }
        end
      end
    end
  end
end
