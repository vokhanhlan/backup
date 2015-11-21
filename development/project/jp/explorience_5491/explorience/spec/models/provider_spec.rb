require 'rails_helper'

RSpec.describe Provider, :type => :model do
  describe 'validation' do
    before do
      @pro = Provider.new({
          "sns_type" => "facebook",
          "sns_id"   => "99",
          "nickname" => "haykuren"
        })
    end

    it 'saveできる' do
      expect(@pro.save).to be_truthy
    end

    describe 'sns_type' do
      it '空の場合、saveできない' do
        @pro.sns_type = ""
        expect(@pro.save).to be_falsy
      end
    end

    describe 'sns_id' do
      it '空の場合、saveできない' do
        @pro.sns_id = ""
        expect(@pro.save).to be_falsy
      end
    end

    describe 'nickname' do
      it '空の場合、saveできる' do
        @pro.nickname = ""
        expect(@pro.save).to be_truthy
      end
      it '20字の場合、saveできる' do
        @pro.nickname = "a" * 20
        expect(@pro.save).to be_truthy
      end
      it '21字の場合、saveできない' do
        @pro.nickname = "a" * 21
        expect(@pro.save).to be_falsy
      end
    end
  end

  describe 'enum' do
    it { is_expected.to define_enum_for :sns_type }
  end

  describe 'relation' do
    it 'Userに従属する' do
      is_expected.to belong_to(:user)
    end
  end
end
