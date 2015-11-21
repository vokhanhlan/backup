require 'rails_helper'

RSpec.describe Clicking, :type => :model do
  describe 'relation' do
    describe Clicking do
      it { is_expected.to belong_to(:experience) }
      it { is_expected.to belong_to(:user) }
    end
  end

  describe 'enum' do
    it { is_expected.to define_enum_for :context }
  end

  describe 'scope' do
    it do
      @exp1 = Experience.create(title: 'exp-1', description: 'description-1')
      @user  = User.create(name: 'Test User', email: 'test@hyakuren.org', password: 'password')
      Clicking.create(experience_id: @exp1.id, user_id: @user.id, context: "go", deleted: true)
      Clicking.create(experience_id: @exp1.id, user_id: @user.id, context: "went", deleted: false)
      expect(@exp1.clickings.not_deleted).to eq @exp1.clickings.where(deleted: false)
    end
  end

  describe 'validation' do
    before do
      @cl = Clicking.new(context: "go")
    end

    it 'saveできる' do
      expect(@cl.save).to be_truthy
    end

    describe 'context' do
      it 'nilの場合、saveできない' do
        @cl.context = nil
        expect(@cl.save).to be_falsy
      end
    end
  end

  describe 'calculate_score' do
    it '体験の評価ポイントが仕様通りであること' do
      # TODO HACK: テストデータ生成はFactoryGirl使うなどしてリファクタ
      @exp_revisit      = Experience.create(title: 'exp-1', description: 'description-1')
      @exp_went_only    = Experience.create(title: 'exp-2', description: 'description-2')
      @exp_go_only      = Experience.create(title: 'exp-3', description: 'description-3')
      @exp_none_clicked = Experience.create(title: 'exp-4', description: 'description-4')
      @user             = User.create(name: 'Test User', email: 'test@hyakuren.org', password: 'password')
      Clicking.create(experience_id: @exp_revisit.id, user_id: @user.id, context: "go", deleted: false)
      Clicking.create(experience_id: @exp_revisit.id, user_id: @user.id, context: "went", deleted: false)
      Clicking.create(experience_id: @exp_went_only.id, user_id: @user.id, context: "went", deleted: false)
      Clicking.create(experience_id: @exp_go_only.id, user_id: @user.id, context: "go", deleted: false)

      expect(Clicking.calculate_score(@exp_revisit)).to      eq(10)
      expect(Clicking.calculate_score(@exp_went_only)).to    eq(-5)
      expect(Clicking.calculate_score(@exp_go_only)).to      eq(1)
      expect(Clicking.calculate_score(@exp_none_clicked)).to eq(0)
    end
  end
end
