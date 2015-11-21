require 'rails_helper'

class ScorableTestController < ActionController::Base
  include Scorable
end

RSpec.describe ScorableTestController, :type => :controller do

  describe 'Core methods:' do
    describe '#update_score' do
      before do
        allow(request).to receive(:bonus_score).and_return(bonus)
        @default_score = 10
        @test_user = User.create!(name: 'test-user', score: @default_score, email: 'test-user@hyakuren.org', password: 'password')
      end
      context 'When argument was correct' do
        before { controller.__send__(:update_score, user, score_context, opts) }
        let(:user)          { @test_user }
        let(:score_context) { :click_wish_to_go }
        context 'If bonus is not 0' do
          let(:bonus) { 5 }
          context 'and increment' do
            let(:opts) do
              {
                type:   :incr,
                counts: { prev: 0, current: 1 }
              }
            end
            describe "user's score" do
              it { expect(user.reload.score).to eq(@default_score + bonus) }
            end
            describe "user's score history count" do
              it { expect(user.score_logs.count).to be > 0 }
            end
          end
          context 'and decrement' do
            let(:opts) do
              {
                type:   :decr,
                counts: { prev: 1, current: 0 }
              }
            end
            describe "user's score" do
              it { expect(user.reload.score).to eq(@default_score - bonus) }
            end
            describe "user's score history count" do
              it { expect(user.score_logs.count).to eq 0 }
            end
          end
        end
        context 'If bonus is 0' do
          let(:bonus) { 0 }
          let(:opts) do
            {
              type:   :incr,
              counts: { prev: 1, current: 1 }
            }
          end
          describe "user's score" do
            it { expect(user.reload.score).to eq @default_score }
          end
          describe "user's score history count" do
            it { expect(user.score_logs.count).to eq 0 }
          end
        end
      end
      context 'When argument user was nil' do
        let(:bonus)         { 5 }
        let(:user)          { nil }
        let(:score_context) { :click_wish_to_go }
        let(:opts) do
          {
            type:   :incr,
            counts: { prev: 0, current: 1 }
          }
        end
        describe 'method result' do
          it { expect{ controller.__send__(:update_score, user, score_context, opts) }.to raise_error }
        end
      end
      context 'When argument context was nil' do
        let(:bonus)         { 5 }
        let(:user)          { @test_user }
        let(:score_context) { nil }
        let(:opts) do
          {
            type:   :incr,
            counts: { prev: 0, current: 1 }
          }
        end
        describe 'method result' do
          it { expect{ controller.__send__(:update_score, user, score_context, opts) }.to raise_error }
        end
      end
      context 'When argument hash was broken' do
        let(:bonus)         { 5 }
        let(:user)          { nil }
        let(:score_context) { :click_wish_to_go }
        let(:opts)          { {} }
        describe 'method result' do
          it { expect{ controller.__send__(:update_score, user, score_context, opts) }.to raise_error }
        end
      end
    end

    describe '#bonus_score' do
      context 'When argument was correct' do
        let(:score_context) { :click_wish_to_go }
        context 'If counts has difference of positive' do
          let(:counts)       { { prev: 0, current: 1 } }
          let(:return_value) { Constants.user_score.bonus_points.click_wish_to_go[0] }
          describe 'method result' do
            it { expect(controller.__send__(:bonus_score, score_context, counts)).to eq return_value }
          end
        end
        context 'If counts has difference of negative' do
          let(:counts)       { { prev: 1, current: 0 } }
          let(:return_value) { Constants.user_score.bonus_points.click_wish_to_go[0] }
          describe 'method result' do
            it { expect(controller.__send__(:bonus_score, score_context, counts)).to eq return_value }
          end
        end
        context 'If counts has no difference' do
          let(:counts) { { prev: 1, current: 1 } }
          describe 'method result' do
            it { expect(controller.__send__(:bonus_score, score_context, counts)).to eq 0 }
          end
        end
      end
      context 'When argument context was nil' do
        let(:score_context) { nil }
        let(:counts)        { { prev: 0, current: 1 } }
        describe 'method result' do
          it { expect{ controller.__send__(:bonus_score, score_context, counts) }.to raise_error }
        end
      end
      context 'When argument counts was broken' do
        let(:score_context) { :click_wish_to_go }
        let(:counts)        { {} }
        describe 'method result' do
          it { expect(controller.__send__(:bonus_score, score_context, counts)).to eq 0 }
        end
      end
    end

    describe '#count_transition' do
      context 'When count is 1,' do
        let(:count) { 1 }
        context 'increment transition' do
          let(:type) { :incr }
          describe 'method result' do
            it { expect(controller.__send__(:count_transition, count, type)).to eq({ prev: 0, current: 1 }) }
          end
        end
        context 'decrement transition' do
          let(:type) { :decr }
          describe 'method result' do
            it { expect(controller.__send__(:count_transition, count, type)).to eq({ prev: 2, current: 1 }) }
          end
        end
      end
      context 'When count is nil,' do
        describe 'method result' do
          it { expect{ controller.__send__(:count_transition, count, type) }.to raise_error }
        end
      end
    end
  end

  describe 'Interface methods' do

    # Create users
    before do
      @default_score = 10
      @test_user = User.create!(
        name: 'test-user',
        score: @default_score,
        last_sign_in_checking_at: last_checking_date,
        email: 'test-user@hyakuren.org',
        password: 'password'
      )
      @default_score2 = 20
      @test_user2 = User.create!(
        name: 'test-user2',
        score: @default_score2,
        email: 'test-user2@hyakuren.org',
        password: 'password'
      )
    end

    shared_examples_for :users_score do
      it { expect(awarded_user.reload.score).to eq expected_score }
    end

    describe 'Login bonus:' do
      describe '#add_bonus_for_login' do
        before do
          allow(controller).to receive(:current_user).and_return(target_user)
          controller.__send__(:add_bonus_for_login)
        end

        shared_examples_for :users_last_checking_date do
          it { expect(awarded_user.reload.last_sign_in_checking_at.to_date).to eq updated_day }
        end

        context 'When current user exists' do
          let(:target_user) { @test_user }
          context 'Last checking date is nil' do
            let(:last_checking_date) { nil }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
            it_behaves_like :users_last_checking_date do
              let(:awarded_user)   { @test_user }
              let(:updated_day) { Date.today }
            end
          end
          context 'Last checking date is 0 days ago' do
            let(:last_checking_date) { Time.zone.now }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
            it_behaves_like :users_last_checking_date do
              let(:awarded_user)   { @test_user }
              let(:updated_day) { Date.today }
            end
          end
          context 'Last checking date is 1 days ago' do
            let(:last_checking_date) { 1.days.ago }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score + Constants.user_score.bonus_points.login }
            end
            it_behaves_like :users_last_checking_date do
              let(:awarded_user)   { @test_user }
              let(:updated_day) { Date.today }
            end
          end
          context "Last checking date is #{Constants.user_score.reference_value.login.term_of_bonus} days ago" do
            let(:last_checking_date) { Constants.user_score.reference_value.login.term_of_bonus.days.ago }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score + Constants.user_score.bonus_points.login }
            end
            it_behaves_like :users_last_checking_date do
              let(:awarded_user)   { @test_user }
              let(:updated_day) { Date.today }
            end
          end
          context "Last checking date is #{Constants.user_score.reference_value.login.term_of_bonus + 1} days ago" do
            let(:last_checking_date) { (Constants.user_score.reference_value.login.term_of_bonus + 1).days.ago }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
            it_behaves_like :users_last_checking_date do
              let(:awarded_user)   { @test_user }
              let(:updated_day) { Date.today }
            end
          end
        end
        context 'When current user does not exist' do
          let(:target_user) { nil }
          let(:last_checking_date) { 1.days.ago }
          it_behaves_like :users_score do
            let(:awarded_user)   { @test_user }
            let(:expected_score) { @default_score }
          end
          it_behaves_like :users_last_checking_date do
            let(:awarded_user)   { @test_user }
            let(:updated_day) { 1.days.ago.to_date }
          end
        end
      end
    end

    describe 'Clicking bonus:' do
      let(:last_checking_date) { Time.zone.now }

      before do
        allow(controller).to receive(:current_user).and_return(target_user)
      end

      describe '#add_bonus_for_click' do
        describe 'When current user exists' do
          let(:target_user) { @test_user }
          before do
            @test_user.clickings.create!(experience_id: 1, context: click_context)
            controller.__send__(:add_bonus_for_click, click_context)
          end
          context 'User clicked as wish to go' do
            let(:click_context) { :go }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score + Constants.user_score.bonus_points.click_wish_to_go[0] }
            end
          end
          context 'User clicked as been there' do
            let(:click_context) { :went }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score + Constants.user_score.bonus_points.click_been_there[0] }
            end
          end
        end
        describe 'When current_user does not exist' do
          let(:target_user)   { nil }
          let(:click_context) { :go }
          it { expect{ controller.__send__(:add_bonus_for_click, click_context) }.to raise_error }
        end
      end

      describe '#subtract_bonus_for_click' do
        describe 'When current user exists' do
          let(:target_user) { @test_user }
          before do
            controller.__send__(:subtract_bonus_for_click, click_context)
          end
          context 'User canceled clicking as wish to go' do
            let(:click_context) { :go }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score - Constants.user_score.bonus_points.click_wish_to_go[0] }
            end
          end
          context 'User canceled clicking as been there' do
            let(:click_context) { :went }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score - Constants.user_score.bonus_points.click_been_there[0] }
            end
          end
        end
        describe 'When current_user does not exist' do
          let(:target_user)   { nil }
          it { expect{ controller.__send__(:subtract_bonus_for_click, :go) }.to raise_error }
        end
      end
    end

    describe 'Experience activation bonnus:' do
      let(:last_checking_date) { Time.zone.now }

      before do
        @exp_id = 1
      end

      describe '#add_bonus_for_activated_exp_by_click' do
        before do
          @test_user.clickings.create!(experience_id: @exp_id, context: click_context, updated_at: 1.days.ago)
        end
        context 'User clicked as wish to go' do
          let(:click_context) { :go }
          context 'after no users clicks' do
            before do
              controller.__send__(:add_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
          context "after #{Constants.user_score.reference_value.activated_exp_by_click[0] - 1} users clicks" do
            before do
              (Constants.user_score.reference_value.activated_exp_by_click[0] - 1).times do |i|
                user = User.create!(name: "dummy-user#{i}", email: "dummy-user#{i}@example.com", password: 'password')
                user.clickings.create!(experience_id: @exp_id, context: click_context)
              end
              controller.__send__(:add_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
          context "after #{Constants.user_score.reference_value.activated_exp_by_click[0]} users clicks" do
            before do
              Constants.user_score.reference_value.activated_exp_by_click[0].times do |i|
                user = User.create!(name: "dummy-user#{i}", email: "dummy-user#{i}@example.com", password: 'password')
                user.clickings.create!(experience_id: @exp_id, context: click_context)
              end
              controller.__send__(:add_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score + Constants.user_score.bonus_points.activated_exp_by_click[0] }
            end
          end
          context "after #{Constants.user_score.reference_value.activated_exp_by_click[0] + 1} users clicks" do
            before do
              (Constants.user_score.reference_value.activated_exp_by_click[0] + 1).times do |i|
                user = User.create!(name: "dummy-user#{i}", email: "dummy-user#{i}@example.com", password: 'password')
                user.clickings.create!(experience_id: @exp_id, context: click_context)
              end
              controller.__send__(:add_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
        end
        context 'User clicked as been there' do
          let(:click_context) { :went }
          context 'after no users clicks' do
            before do
              controller.__send__(:add_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
          context "after #{Constants.user_score.reference_value.activated_exp_by_click[0] - 1} users clicks" do
            before do
              (Constants.user_score.reference_value.activated_exp_by_click[0] - 1).times do |i|
                user = User.create!(name: "dummy-user#{i}", email: "dummy-user#{i}@example.com", password: 'password')
                user.clickings.create!(experience_id: @exp_id, context: click_context)
              end
              controller.__send__(:add_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
          context "after #{Constants.user_score.reference_value.activated_exp_by_click[0]} users clicks" do
            before do
              Constants.user_score.reference_value.activated_exp_by_click[0].times do |i|
                user = User.create!(name: "dummy-user#{i}", email: "dummy-user#{i}@example.com", password: 'password')
                user.clickings.create!(experience_id: @exp_id, context: click_context)
              end
              controller.__send__(:add_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score + Constants.user_score.bonus_points.activated_exp_by_click[0] }
            end
          end
          context "after #{Constants.user_score.reference_value.activated_exp_by_click[0] + 1} users clicks" do
            before do
              (Constants.user_score.reference_value.activated_exp_by_click[0] + 1).times do |i|
                user = User.create!(name: "dummy-user#{i}", email: "dummy-user#{i}@example.com", password: 'password')
                user.clickings.create!(experience_id: @exp_id, context: click_context)
              end
              controller.__send__(:add_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
        end
      end

      describe '#subtract_bonus_for_activated_exp_by_click' do
        before do
          @test_user.clickings.create!(experience_id: @exp_id, context: click_context, updated_at: 1.days.ago)
        end
        context 'User clicked as wish to go' do
          let(:click_context) { :go }
          context 'after no users clicks' do
            before do
              controller.__send__(:subtract_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
          context "after #{Constants.user_score.reference_value.activated_exp_by_click[0] - 2} users clicks" do
            before do
              (Constants.user_score.reference_value.activated_exp_by_click[0] - 2).times do |i|
                user = User.create!(name: "dummy-user#{i}", email: "dummy-user#{i}@example.com", password: 'password')
                user.clickings.create!(experience_id: @exp_id, context: click_context)
              end
              controller.__send__(:subtract_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
          context "after #{Constants.user_score.reference_value.activated_exp_by_click[0] - 1} users clicks" do
            before do
              (Constants.user_score.reference_value.activated_exp_by_click[0] - 1).times do |i|
                user = User.create!(name: "dummy-user#{i}", email: "dummy-user#{i}@example.com", password: 'password')
                user.clickings.create!(experience_id: @exp_id, context: click_context)
              end
              controller.__send__(:subtract_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score - Constants.user_score.bonus_points.activated_exp_by_click[0] }
            end
          end
          context "after #{Constants.user_score.reference_value.activated_exp_by_click[0]} users clicks" do
            before do
              Constants.user_score.reference_value.activated_exp_by_click[0].times do |i|
                user = User.create!(name: "dummy-user#{i}", email: "dummy-user#{i}@example.com", password: 'password')
                user.clickings.create!(experience_id: @exp_id, context: click_context)
              end
              controller.__send__(:subtract_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
        end
        context 'User clicked as been there' do
          let(:click_context) { :went }
          context 'after no users clicks' do
            before do
              controller.__send__(:subtract_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
          context "after #{Constants.user_score.reference_value.activated_exp_by_click[0] - 2} users clicks" do
            before do
              (Constants.user_score.reference_value.activated_exp_by_click[0] - 2).times do |i|
                user = User.create!(name: "dummy-user#{i}", email: "dummy-user#{i}@example.com", password: 'password')
                user.clickings.create!(experience_id: @exp_id, context: click_context)
              end
              controller.__send__(:subtract_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
          context "after #{Constants.user_score.reference_value.activated_exp_by_click[0] - 1} users clicks" do
            before do
              (Constants.user_score.reference_value.activated_exp_by_click[0] - 1).times do |i|
                user = User.create!(name: "dummy-user#{i}", email: "dummy-user#{i}@example.com", password: 'password')
                user.clickings.create!(experience_id: @exp_id, context: click_context)
              end
              controller.__send__(:subtract_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score - Constants.user_score.bonus_points.activated_exp_by_click[0] }
            end
          end
          context "after #{Constants.user_score.reference_value.activated_exp_by_click[0]} users clicks" do
            before do
              Constants.user_score.reference_value.activated_exp_by_click[0].times do |i|
                user = User.create!(name: "dummy-user#{i}", email: "dummy-user#{i}@example.com", password: 'password')
                user.clickings.create!(experience_id: @exp_id, context: click_context)
              end
              controller.__send__(:subtract_bonus_for_activated_exp_by_click, @exp_id, click_context)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
        end
      end
    end

    describe 'Uploading photo bonus:' do
      let(:last_checking_date) { Time.zone.now }

      before do
        allow(controller).to receive(:current_user).and_return(target_user)
      end

      describe '#add_bonus_for_upload_photo' do
        context 'When current user exists' do
          let(:target_user) { @test_user }
          context "Uploaded photo count is #{Constants.user_score.reference_value.upload_photo[0]}" do
            before do
              Constants.user_score.reference_value.upload_photo[0].times do
                @test_user.photos.create!(img_file_name: 'dummy-img.jpg')
              end
              controller.__send__(:add_bonus_for_upload_photo)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score + Constants.user_score.bonus_points.upload_photo[0] }
            end
          end
          context "Uploaded photo count is #{Constants.user_score.reference_value.upload_photo[0] + 1}" do
            before do
              (Constants.user_score.reference_value.upload_photo[0] + 1).times do
                @test_user.photos.create!(img_file_name: 'dummy-img.jpg')
              end
              controller.__send__(:add_bonus_for_upload_photo)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
        end
        context 'When current user does not exist' do
          let(:target_user) { nil }
          it { expect{ controller.__send__(:add_bonus_for_upload_photo) }.to raise_error }
        end
      end

      describe '#subtract_bonus_for_upload_photo' do
        context 'When current user exists' do
          let(:target_user) { @test_user }
          context "Remain uploaded photo count is #{Constants.user_score.reference_value.upload_photo[0] - 1}" do
            before do
              (Constants.user_score.reference_value.upload_photo[0] - 1).times do
                @test_user.photos.create!(img_file_name: 'dummy-img.jpg')
              end
              controller.__send__(:subtract_bonus_for_upload_photo)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score - Constants.user_score.bonus_points.upload_photo[0] }
            end
          end
          context "Remain uploaded photo count is #{Constants.user_score.reference_value.upload_photo[0]}" do
            before do
              Constants.user_score.reference_value.upload_photo[0].times do
                @test_user.photos.create!(img_file_name: 'dummy-img.jpg')
              end
              controller.__send__(:subtract_bonus_for_upload_photo)
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
          end
        end
        context 'When current user does not exist' do
          let(:target_user) { nil }
          it { expect{ controller.__send__(:subtract_bonus_for_upload_photo) }.to raise_error }
        end
      end
    end

    describe 'Pinned photo bonus:' do
      let(:last_checking_date) { Time.zone.now }

      before do
        @old_pinned_photo = @test_user.photos.create!(img_file_name: 'dummy-photo1.jpg')
        @new_pinned_photo = @test_user2.photos.create!(img_file_name: 'dummy-photo2.jpg')
      end

      describe '#add_and_subtract_bonus_for_pinned_photo' do
        context 'Old pinned photo ID is nil' do
          let(:old_photo_id) { nil }
          context 'New pinned photo ID is nil' do
            before do
              controller.__send__(:add_and_subtract_bonus_for_pinned_photo, old_photo_id, new_photo_id)
            end
            let(:new_photo_id) { nil }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user2 }
              let(:expected_score) { @default_score2 }
            end
          end
          context 'New pinned photo ID exists' do
            before do
              @test_user.fixed_photos.create!(experience_id: 1, photo_id: @new_pinned_photo.id)
              controller.__send__(:add_and_subtract_bonus_for_pinned_photo, old_photo_id, new_photo_id)
            end
            let(:new_photo_id) { @new_pinned_photo.id }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user2 }
              let(:expected_score) { @default_score2 + Constants.user_score.bonus_points.pinned_photo[0] }
            end
          end
        end
        context 'Old pinned photo ID exists' do
          let(:old_photo_id) { @old_pinned_photo.id }
          context 'New pinned photo ID is nil' do
            before do
              controller.__send__(:add_and_subtract_bonus_for_pinned_photo, old_photo_id, new_photo_id)
            end
            let(:new_photo_id) { nil }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score - Constants.user_score.bonus_points.pinned_photo[0] }
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user2 }
              let(:expected_score) { @default_score2 }
            end
          end
          context 'New pinned photo ID exists' do
            before do
              @test_user.fixed_photos.create!(experience_id: 1, photo_id: @new_pinned_photo.id)
              controller.__send__(:add_and_subtract_bonus_for_pinned_photo, old_photo_id, new_photo_id)
            end
            let(:new_photo_id) { @new_pinned_photo.id }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score - Constants.user_score.bonus_points.pinned_photo[0] }
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user2 }
              let(:expected_score) { @default_score2 + Constants.user_score.bonus_points.pinned_photo[0] }
            end
          end
        end
      end
    end

    describe 'Follow/Followed bonus:' do
      let(:last_checking_date) { Time.zone.now }

      describe '#add_bonus_for_followed_following' do
        context 'Following user is nil' do
          let(:following) { nil }
          context 'Follower user is nil' do
            before do
              Follow.create!(user_id: nil, following_id: nil)
              controller.__send__(:add_bonus_for_followed_following, following, follower)
            end
            let(:follower) { nil }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user2 }
              let(:expected_score) { @default_score2 }
            end
          end
          context 'Follower user exists' do
            before do
              @test_user.follows.create!(following_id: nil)
              controller.__send__(:add_bonus_for_followed_following, following, follower)
            end
            let(:follower) { @test_user }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score  + Constants.user_score.bonus_points.pinned_photo[0] }
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user2 }
              let(:expected_score) { @default_score2 }
            end
          end
        end
        context 'Following user exists' do
          let(:following) { @test_user2 }
          context 'Follower user is nil' do
            before do
              Follow.create!(user_id: nil, following_id: @test_user2.id)
              controller.__send__(:add_bonus_for_followed_following, following, follower)
            end
            let(:follower) { nil }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user2 }
              let(:expected_score) { @default_score2 + Constants.user_score.bonus_points.pinned_photo[0] }
            end
          end
          context 'Follower user exists' do
            before do
              @test_user.follows.create!(following_id: @test_user2.id)
              controller.__send__(:add_bonus_for_followed_following, following, follower)
            end
            let(:follower) { @test_user }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score  + Constants.user_score.bonus_points.pinned_photo[0] }
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user2 }
              let(:expected_score) { @default_score2 + Constants.user_score.bonus_points.pinned_photo[0] }
            end
          end
        end
      end

      describe '#subtract_bonus_for_followed_following' do
        before { controller.__send__(:subtract_bonus_for_followed_following, following, follower) }
        context 'Following user is nil' do
          let(:following) { nil }
          context 'Follower user is nil' do
            let(:follower) { nil }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user2 }
              let(:expected_score) { @default_score2 }
            end
          end
          context 'Follower user exists' do
            let(:follower) { @test_user }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score  - Constants.user_score.bonus_points.pinned_photo[0] }
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user2 }
              let(:expected_score) { @default_score2 }
            end
          end
        end
        context 'Following user exists' do
          let(:following) { @test_user2 }
          context 'Follower user is nil' do
            let(:follower) { nil }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score }
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user2 }
              let(:expected_score) { @default_score2 - Constants.user_score.bonus_points.pinned_photo[0] }
            end
          end
          context 'Follower user exists' do
            let(:follower) { @test_user }
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user }
              let(:expected_score) { @default_score  - Constants.user_score.bonus_points.pinned_photo[0] }
            end
            it_behaves_like :users_score do
              let(:awarded_user)   { @test_user2 }
              let(:expected_score) { @default_score2 - Constants.user_score.bonus_points.pinned_photo[0] }
            end
          end
        end
      end
    end
  end
end
