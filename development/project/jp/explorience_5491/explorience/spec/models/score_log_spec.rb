require 'rails_helper'

RSpec.describe ScoreLog, :type => :model do
  describe 'Associations' do
    describe ScoreLog do
      it { is_expected.to belong_to(:user) }
    end
  end

  describe 'enum' do
    it { is_expected.to define_enum_for :scored_type }
  end

  describe 'validation' do
    before do
      @score_log = ScoreLog.new(scored_type: "login")
    end

    it 'saveできる' do
      expect(@score_log.save).to be_truthy
    end

    describe 'scored_type' do
      it 'nilの場合、saveできない' do
        @score_log.scored_type = nil
        expect(@score_log.save).to be_falsy
      end
    end
  end

  before(:context) do
    @user = User.create!(name: 'test_user1', email: 'test1@test.com', password: 'test1_password')
    @user.score_logs.create!(other_user_id: nil, scored_type: 0, read: 0)
    @user.score_logs.create!(other_user_id: nil, scored_type: 1, read: 0)
    @user.score_logs.create!(other_user_id: nil, scored_type: 2, read: 0)
  end

  describe 'Class methods' do
    describe '.update_read:' do
      context 'When unread score-logs exist,' do
        before do
          @logs = @user.score_logs.where(read: false)
          ScoreLog.update_read(@logs)
        end
        describe 'read column values' do
          it do
            @logs.each { |log| expect(log.read).to be_truthy }
          end
        end
      end
      context 'When unread score-logs do not exist,' do
        before { @logs = nil }
        describe 'method result' do
          it do
            expect(ScoreLog.update_read(@logs)).to be_nil
          end
        end
      end
    end
  end

  describe 'Instance methods' do
    describe '#message:' do
      context 'First log' do
        it { expect(@user.score_logs.first.message).to eq(I18n.t('models.score_log.login')) }
      end
      context 'Second log' do
        it { expect(@user.score_logs[1].message).to eq(I18n.t('models.score_log.click_wish_to_go')) }
      end
      context 'Last log' do
        it { expect(@user.score_logs.last.message).to eq(I18n.t('models.score_log.click_been_there')) }
      end
    end
  end
end
