require 'rails_helper'

RSpec.describe User, :type => :model do
  describe 'Associations' do
    describe User do
      it { is_expected.to have_many(:providers).dependent(:destroy) }
      it { is_expected.to have_many(:user_photos) }
      it { is_expected.to have_many(:photos).through(:user_photos) }
      it { is_expected.to have_many(:clickings) }
      it { is_expected.to have_many(:clicking_experiences).through(:clickings).source(:experience) }
      it { is_expected.to have_many(:fixed_photos) }
      it { is_expected.to have_many(:follows) }
      it { is_expected.to have_many(:score_logs) }
      it { is_expected.to have_one(:action_log) }
    end
  end

  describe 'Validations' do
    before do
      @user = User.new(
        name:     name,
        email:    SecureRandom.uuid + '@test.com',
        password: Devise.friendly_token[0, 20]
      )
    end
    describe :name do
      describe 'presence:' do
        context 'When nil,' do
          let(:name) { nil }
          it { expect(@user).not_to be_valid }
          it { expect { @user.save! }.to raise_error }
        end
        context 'When empty,' do
          let(:name) { '' }
          it { expect(@user).not_to be_valid }
          it { expect { @user.save! }.to raise_error }
        end
        context 'When valid value,' do
          let(:name) { 'Some name' }
          it { expect(@user).to be_valid }
          it { expect { @user.save! }.not_to raise_error }
        end
      end
      describe 'length:' do
        context 'When 1 character,' do
          let(:name) { 'a' }
          it { expect(@user).to be_valid }
          it { expect { @user.save! }.not_to raise_error }
        end
        context 'When 20 characters,' do
          let(:name) { 'a' * 20 }
          it { expect(@user).to be_valid }
          it { expect { @user.save! }.not_to raise_error }
        end
        context 'When 21 characters,' do
          let(:name) { 'a' * 21 }
          it { expect(@user).not_to be_valid }
          it { expect { @user.save! }.to raise_error }
        end
      end
    end
  end

  # TODO: eager_loadのテストは保留。テスト方法調査から
  describe 'Scopes' do
    before(:context) do
      @experience = Experience.create(title: 'experience', description: 'description', created_at: DateTime.now)

      @click_user   = User.create(name: 'Test Click User',   email: 'test_click@hyakuren.org',   password: 'password')
      @unclick_user = User.create(name: 'Test Unclick User', email: 'test_unclick@hyakuren.org', password: 'password')

      Clicking.create(experience_id: @experience.id, user_id: @click_user.id, context: "go")
      Clicking.create(experience_id: @experience.id, user_id: @click_user.id, context: "went")
      Clicking.create(experience_id: @experience.id, user_id: @unclick_user.id, context: "go",   deleted: true)
      Clicking.create(experience_id: @experience.id, user_id: @unclick_user.id, context: "went", deleted: true)
    end
    describe 'clicked:' do
      before { @users = @experience.clicking_users.clicked.uniq }
      context 'Scoped objects' do
        it { expect(@users).to eq [@click_user] }
      end
    end
    describe 'without:' do
      before { @users = @experience.clicking_users.without(user_id).uniq }
      context 'Specify exist user ID.' do
        let(:user_id) { @click_user.id }
        context 'Scoped objects' do
          it { expect(@users).to eq [@unclick_user] }
        end
      end
      context 'Specify exist user ID.' do
        let(:user_id) { @click_user.id * 100 }
        context 'Scoped objects' do
          it { expect(@users).to eq [@click_user, @unclick_user] }
        end
      end
    end
  end

  describe 'Class methods' do
    describe 'For omniauth:' do
      before do
        @registered_user = User.create(
          name:     'registered_user_name',
          email:    SecureRandom.uuid + '@test.com',
          password: Devise.friendly_token[0, 20]
        )
        @registered_user.providers.create(
          user_id:   @registered_user.id,
          sns_id:    '0000000000',
          sns_type:  sns_type,
          nickname:  'registered_nickname',
          language:  :en,
          photo_url: 'regitstered_url'
        )
        @auth = double('auth',
          uid:  uid,
          info: double('auth.info',
            name:     name,
            email:    email,
            nickname: nickname,
            image:    sns_image
          ),
          # TODO: 属性を1つにする
          extra: double('auth.extra',
            raw_info: double('auth.extra.raw_info',
              locale: :en,
              lang:   :en
            )
          )
        )
        allow(User).to receive_messages(find_by: user)
      end

      describe '.find_for_twitter_oauth:' do
        let(:name)      { nil }
        let(:email)     { nil }
        let(:sns_type)  { 'twitter' }
        let(:sns_image) { 'http://pbs.twimg.com/profile_images/000000000000000000/xxxxxxxx_normal.jpeg' }
        describe 'Found or create user:' do
          let(:uid)      { '0000000000' }
          let(:nickname) { 'twitter_nickname' }
          before { @found_user = User.find_for_twitter_oauth(@auth) }
          context 'When user was exist,' do
            let(:user) { @registered_user }
            context 'found user name' do
              it { expect(@found_user.name).to eq @registered_user.name }
            end
            context "found user's SNS image URL" do
              it { expect(@found_user.providers.twitter.first.photo_url).to eq User.twitter_image_url(sns_image) }
            end
          end
          context 'When user was not exist, created user name' do
            let(:user) { nil }
            it { expect(@found_user.name).to eq @auth.info.nickname }
          end
        end
        describe 'Error handling:' do
          context 'When auth.info.nickname was nil' do
            let(:user)     { nil }
            let(:uid)      { '0000000000' }
            let(:nickname) { nil }
            it { expect { User.find_for_twitter_oauth(@auth) }.to raise_error }
          end
        end
      end

      describe '.find_for_facebook_oauth:' do
        let(:nickname)  { nil }
        let(:sns_type)  { 'facebook' }
        let(:sns_image) { 'http://graph.facebook.com/0000000000000000/picture' }
        describe 'Found or create user:' do
          let(:uid)   { '0000000000' }
          let(:name)  { 'facebook_name' }
          let(:email) { SecureRandom.uuid + '@test.com' }
          before { @found_user = User.find_for_facebook_oauth(@auth) }
          context 'When user was exist,' do
            let(:user) { @registered_user }
            context 'found user name' do
              it { expect(@found_user.name).to eq @registered_user.name }
            end
            context "found user's SNS image URL" do
              it { expect(@found_user.providers.facebook.first.photo_url).to eq User.facebook_image_url(sns_image, size: 120) }
            end
          end
          context 'When user was not exist, created user name' do
            let(:user) { nil }
            it { expect(@found_user.name).to eq @auth.info.name }
          end
        end
        describe 'Error handling:' do
          context 'When auth.info.name was nil' do
            let(:user)  { nil }
            let(:uid)   { '0000000000' }
            let(:name)  { nil }
            let(:email) { SecureRandom.uuid + '@test.com' }
            it { expect { User.find_for_facebook_oauth(@auth) }.to raise_error }
          end
          context 'When auth.info.email was nil' do
            let(:user)  { nil }
            let(:uid)   { '0000000000' }
            let(:name)  { 'facebook_name' }
            let(:email) { nil }
            it { expect { User.find_for_facebook_oauth(@auth) }.to raise_error }
          end
        end
      end

      describe '.find_for_google_oauth:' do
        let(:name)      { nil }
        let(:email)     { nil }
        let(:sns_type)  { 'google' }
        let(:sns_image) { 'https://lh6.googleusercontent.com/zzzzzzzz/yyyyyyyyyy/xxxxxxxxxx/photo.jpg?sz=50' }
        let(:nickname)  { nil }
        describe 'Found or create user:' do
          let(:uid)   { '0000000000' }
          let(:name)  { 'google_name' }
          let(:email) { 'abc@gmail.com' }
          before { @found_user  = User.find_for_google_oauth(@auth) }
          context 'When user was exist,' do
            let(:user) { @registered_user }
            context 'found user name' do
              it { expect(@found_user.name).to eq @registered_user.name }
            end
            context "found user's SNS image URL" do
              it { expect(@found_user.providers.google.first.photo_url).to eq User.google_image_url(sns_image) }
            end
          end
          context 'When user was not exist, created user name' do
            let(:user) { nil }
            it { expect(@found_user.name).to eq @auth.info.name }
          end
        end
        describe 'Error handling:' do
          context 'When auth.info.name was nil' do
            let(:user)     { nil }
            let(:uid)      { '0000000000' }
            it { expect { User.find_for_google_oauth(@auth) }.to raise_error }
          end
        end
      end
    end

    describe '.create_unique_string:' do
      before do
        @unique_strings = []
        100.times { @unique_strings << User.create_unique_string }
      end
      it 'Generated strings should be unique' do
        expect(@unique_strings.size).to eq @unique_strings.uniq.size
      end
    end

    describe '.create_unique_email:' do
      before do
        @unique_emails = []
        100.times { @unique_emails << User.create_unique_email }
        @correct_emails = @unique_emails.select { |email| email =~ /@example\.com/ }
      end
      it 'Generated emails should be unique' do
        expect(@unique_emails.size).to eq @unique_emails.uniq.size
      end
      it 'Generated emails should include fixed domain' do
        expect(@unique_emails.size).to eq @correct_emails.size
      end
    end

    describe '.twitter_image_url:' do
      before { @url = User.twitter_image_url('http://pbs.twimg.com/profile_images/000000000000000000/xxxxxxxx_normal.jpeg') }
      describe 'Generated URL' do
        it { expect(@url).not_to match(/_normal/) }
      end
    end

    describe '.facebook_image_url:' do
      before { @url = User.facebook_image_url('http://graph.facebook.com/0000000000000000/picture', size: 150) }
      describe 'When size argument value was 150, Generated URL' do
        it { expect(@url).to match(/width=150&height=150/) }
      end
    end

    describe '.google_image_url:' do
      before { @url = User.google_image_url('https://lh6.googleusercontent.com/zzzzzzzz/yyyyyyyyyy/xxxxxxxxxx/photo.jpg?sz=50') }
      describe 'Generated URL' do
        it { expect(@url).not_to match(/\?sz/) }
      end
    end
  end

  describe 'Instance methods' do
    before(:context) do
      @exp1 = Experience.create(title: 'exp-1', description: 'description-1', created_at: DateTime.now)
      @exp2 = Experience.create(title: 'exp-2', description: 'description-2', created_at: DateTime.now + 1)
      @exp3 = Experience.create(title: 'exp-3', description: 'description-3', created_at: DateTime.now + 2)
      @exp4 = Experience.create(title: 'exp-4', description: 'description-4', created_at: DateTime.now + 3)
      @exp5 = Experience.create(title: 'exp-5', description: 'description-5', created_at: DateTime.now + 4)
      @exp6 = Experience.create(title: 'exp-6', description: 'description-6', created_at: DateTime.now + 5)

      @user1  = User.create(name: 'Test User1', email: 'test1@hyakuren.org', password: 'password')
      @user2  = User.create(name: 'Test User2', email: 'test2@hyakuren.org', password: 'password')
      @user3  = User.create(name: 'Test User3', email: 'test3@hyakuren.org', password: 'password')
      @user4  = User.create(name: 'Test User4', email: 'test4@hyakuren.org', password: 'password')

      Clicking.create(experience_id: @exp1.id, user_id: @user1.id, context: "go")
      Clicking.create(experience_id: @exp2.id, user_id: @user1.id, context: "go",   deleted: true)

      Clicking.create(experience_id: @exp1.id, user_id: @user2.id, context: "went")
      Clicking.create(experience_id: @exp2.id, user_id: @user2.id, context: "went")
      Clicking.create(experience_id: @exp3.id, user_id: @user2.id, context: "went", deleted: true)

      Clicking.create(experience_id: @exp1.id, user_id: @user3.id, context: "go")
      Clicking.create(experience_id: @exp1.id, user_id: @user3.id, context: "went")
      Clicking.create(experience_id: @exp2.id, user_id: @user3.id, context: "go",   deleted: true)
      Clicking.create(experience_id: @exp2.id, user_id: @user3.id, context: "went", deleted: true)

      Clicking.create(experience_id: @exp1.id, user_id: @user4.id, context: "go")
      Clicking.create(experience_id: @exp2.id, user_id: @user4.id, context: "go")
      Clicking.create(experience_id: @exp3.id, user_id: @user4.id, context: "go")
    end

    describe '#clickable?:' do
      before { allow(Constants).to receive_messages(limit_of_click: 2) }
      context 'When user clickings are less than limit' do
        it { expect(@user1.clickable?(@exp4.id)).to be_truthy }
      end
      context 'When user clickings are upper limit' do
        it { expect(@user4.clickable?(@exp4.id)).to be_falsy }
      end
    end

    describe '#count_action:' do
      context 'When user.action_log is nil' do
        before { @user1.count_action(:refered_experience_detail) }
        it { expect(@user1.action_log.refered_experience_detail).to eq(1) }
      end
    end

    describe '#click_count:' do
      context 'Wish to go clicked user:' do
        before { @count = @user1.click_count(context_type) }
        context 'Number of wish to go clickings' do
          let(:context_type) { "go" }
          it { expect(@count).to eq(1) }
        end
        context 'Number of been there clickings' do
          let(:context_type) { "went" }
          it { expect(@count).to eq(0) }
        end
        context 'Number of going again clickings' do
          let(:context_type) { "revisit" }
          it { expect(@count).to eq(0) }
        end
      end
      context 'Been there clicked user:' do
        before { @count = @user2.click_count(context_type) }
        context 'Number of wish to go clickings' do
          let(:context_type) { "go" }
          it { expect(@count).to eq(0) }
        end
        context 'Number of been there clickings' do
          let(:context_type) { "went" }
          it { expect(@count).to eq(2) }
        end
        context 'Number of going again clickings' do
          let(:context_type) { "revisit" }
          it { expect(@count).to eq(0) }
        end
      end
      context 'Wish to go and Been there clicked user:' do
        before { @count = @user3.click_count(context_type) }
        context 'Number of wish to go clickings' do
          let(:context_type) { "go" }
          it { expect(@count).to eq(1) }
        end
        context 'Number of been there clickings' do
          let(:context_type) { "went" }
          it { expect(@count).to eq(1) }
        end
        context 'Number of going again clickings' do
          let(:context_type) { "revisit" }
          it { expect(@count).to eq(1) }
        end
      end
    end

    describe '#valid_email:' do
      before(:context) do
        @user1.providers.create(sns_type: :facebook, sns_id: '0000000000')
        @user2.providers.create(sns_type: :twitter,  sns_id: '0000000000')
        @user3.providers.create(sns_type: :google,   sns_id: '0000000000')
      end
      context "When Facebook user's email" do
        before { @email = @user1.valid_email }
        it { expect(@email).to eq('test1@hyakuren.org') }
      end
      context "When Twitter user's email" do
        before { @email = @user2.valid_email }
        it { expect(@email).to be_nil }
      end
      context "When Google user's email" do
        before { @email = @user3.valid_email }
        it { expect(@email).to eq('test3@hyakuren.org') }
      end
    end
  end
end
