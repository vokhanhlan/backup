require 'rails_helper'

# TODO HACK: レコード生成方法を綺麗にまとめる
RSpec.describe Ranking, :type => :model do
  describe 'Associations' do
    describe Ranking do
      it { is_expected.to belong_to(:experience) }
      it { is_expected.to belong_to(:user) }
    end
  end

  describe 'Scopes' do
    before do
      time = Time.zone.now
      @user = User.create!(name: 'test_user', email: 'test@test.com', password: 'test_password')
      @ranking1 = @user.rankings.create!(experience_id: 1, rank: 1,  updated_at: time + 1.day)
      @ranking2 = @user.rankings.create!(experience_id: 2, rank: 3,  updated_at: time + 2.day)
      @ranking3 = @user.rankings.create!(experience_id: 4, rank: 10, updated_at: time + 3.day, locked: true)
      @ranking4 = @user.rankings.create!(experience_id: 5, rank: 5,  updated_at: time + 4.day, locked: false)
      @ranking5 = @user.rankings.create!(experience_id: 8, rank: 5,  updated_at: time + 5.day, locked: true)
      @ranking4.update_attributes(updated_at: time + 6.day)
    end
    describe 'locked:' do
      describe 'Scoped objects' do
        before { @rankings = Ranking.all.locked.to_a }
        it { expect(@rankings).to eq [@ranking3, @ranking5] }
      end
    end
    describe 'unlocked:' do
      describe 'Scoped objects' do
        before { @rankings = Ranking.all.unlocked.to_a }
        it { expect(@rankings).to eq [@ranking1, @ranking2, @ranking4] }
      end
    end
    describe 'rank_order:' do
      describe 'Scoped objects' do
        before { @rankings = Ranking.all.rank_order.to_a }
        it { expect(@rankings).to eq [@ranking1, @ranking2, @ranking4, @ranking5, @ranking3] }
      end
    end
    describe 'updated_order:' do
      describe 'Scoped objects' do
        before { @rankings = Ranking.all.updated_order.to_a }
        it { expect(@rankings).to eq [@ranking4, @ranking5, @ranking3, @ranking2, @ranking1] }
      end
    end
  end

  describe 'Class methods' do
    describe '.reorder_rank:' do
      before do
        time = Time.zone.now
        @user1 = User.create!(name: 'test_user1', email: 'test1@test.com', password: 'test1_password')
        @user2 = User.create!(name: 'test_user2', email: 'test2@test.com', password: 'test2_password')
        @ranking6  = @user1.rankings.create!(experience_id: 1, rank: 5,  updated_at: time + 1.day)
        @ranking7  = @user1.rankings.create!(experience_id: 2, rank: 3,  updated_at: time + 2.day, locked: true)
        @ranking8  = @user1.rankings.create!(experience_id: 4, rank: 1,  updated_at: time + 3.day, locked: lock)
        @ranking9  = @user1.rankings.create!(experience_id: 5, rank: 5,  updated_at: time + 4.day)
        @ranking10 = @user1.rankings.create!(experience_id: 8, rank: 11, updated_at: time + 5.day, locked: false)
        @result = Ranking.reorder_rank(target_user)
      end
      context 'When user has valid ranking,' do
        let(:target_user) { @user1 }
        describe 'method result' do
          let(:lock) { true }
          it { expect(@result).to be_truthy }
        end
        context '1st ranking had locked.' do
          let(:lock) { true }
          describe 'Reordered ranking' do
            it do
              reordered_ranking = @user1.rankings.pluck(:rank)
              expect(reordered_ranking).to eq [4,3,1,2,5]
            end
          end
        end
        context '1st ranking had not locked.' do
          let(:lock) { false }
          describe 'Reordered ranking' do
            it do
              reordered_ranking = @user1.rankings.pluck(:rank)
              expect(reordered_ranking).to eq [4,3,1,2,5]
            end
          end
        end
      end
      context 'When user has no ranking,' do
        let(:target_user) { @user2 }
        let(:lock)        { true }
        describe 'method result' do
          it { expect(@result).to be_truthy }
        end
      end
      context 'When user is nil,' do
        let(:target_user) { nil }
        let(:lock)        { true }
        describe 'method result' do
          it { expect(@result).to be_falsy }
        end
      end
    end
    describe '.new_rank:' do
      before do
        @user3 = User.create!(name: 'test_user3', email: 'test3@test.com', password: 'test3_password')
        @user3.rankings.create!(experience_id: 8, rank: 1, locked: lock)
        @user3.rankings.create!(experience_id: 7, rank: 3)
        @user3.rankings.create!(experience_id: 6, rank: 2, locked: lock)
        @new_rank = @user3.rankings.new_rank
        @user4 = User.create!(name: 'test_user4', email: 'test4@test.com', password: 'test4_password')
      end
      context 'When all rank had not been loced,' do
        let(:lock) { false }
        describe "user's new rank" do
          it { expect(@new_rank).to eq 1 }
        end
      end
      context 'When 1st, 2nd rank had been locked,' do
        let(:lock) { true }
        describe "user's new rank" do
          it { expect(@new_rank).to eq 3 }
        end
      end
      context 'When user has no ranking,' do
        let(:lock) { false }
        describe "user's new rank" do
          it { expect(@user4.rankings.new_rank).to eq 1 }
        end
      end
    end
  end

  describe 'Instance methods' do
    describe '#toggle_lock:' do
      before do
        @ranking11 = Ranking.create!(experience_id: 1, user_id: 100, rank: 1, locked: lock_value)
        @ranking11.toggle_lock
        @locked = @ranking11.locked
      end
      context 'When unlocked,' do
        let(:lock_value) { false }
        describe 'toggled locked column' do
          it { expect(@locked).to eq !lock_value }
        end
      end
      context 'When locked,' do
        let(:lock_value) { true }
        describe 'toggled locked column' do
          it { expect(@locked).to eq !lock_value }
        end
      end
    end
  end
end
