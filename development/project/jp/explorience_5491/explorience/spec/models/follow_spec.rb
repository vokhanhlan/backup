require 'rails_helper'

RSpec.describe Follow, :type => :model do
  describe 'Associations' do
    describe Follow do
      it { is_expected.to belong_to(:user) }
    end
  end
  
  describe 'Class methods' do
    # TODO: update_readの引数をletでまとめる
    describe '.update_read' do
      before do
        @user1 = User.create!(name: 'test_user1', email: 'test1@test.com', password: 'test1_password')
        @user2 = User.create!(name: 'test_user2', email: 'test2@test.com', password: 'test2_password')
        @user3 = User.create!(name: 'test_user3', email: 'test3@test.com', password: 'test3_password')
        @follower1 = Follow.create!(user_id: @user1.id, following_id: @user2.id, read: 0)
        @follower2 = Follow.create!(user_id: @user2.id, following_id: @user1.id, read: 0)
        @follower3 = Follow.create!(user_id: @user3.id, following_id: @user1.id, read: 0)
      end
      context 'when unread follower exist' do
        describe 'method result' do
          it do
            followers = Follow.where(following_id: @user1.id)
            Follow.update_read(followers)
            followers.reload.each do |follower|
              expect(follower.read).to be_truthy
            end
          end
        end
      end
      context 'when unread follower nonexistent' do
        describe 'method result' do
          it do
            followers = nil
            expect(Follow.update_read(followers)).to be_nil
          end
        end
      end
    end
  end
end
