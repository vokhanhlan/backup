require 'rails_helper'

RSpec.describe Experience, :type => :model do
  describe 'Associations' do
    describe Experience do
      it { is_expected.to have_many(:experience_photos).dependent(:destroy) }
      it { is_expected.to have_many(:photos).through(:experience_photos) }
      it { is_expected.to have_many(:clickings).dependent(:destroy) }
      it { is_expected.to have_many(:clicking_users).through(:clickings).source(:user) }
      it { is_expected.to have_many(:affiliations) }
      it { is_expected.to have_many(:rankings).dependent(:destroy) }
      it { is_expected.to belong_to(:advertiser) }
    end
  end

  describe 'Validations' do
    describe 'of presence' do
      before do
        @exp = Experience.new(
          title:        test_title,
          description:  test_description
        )
      end
      describe 'in title:' do
        context 'When nil,' do
          let(:test_title)       { nil }
          let(:test_description) { 'Some description.' }
          it { expect(@exp).not_to be_valid }
          it { expect { @exp.save! }.to raise_error }
        end
        context 'When empty,' do
          let(:test_title)       { '' }
          let(:test_description) { 'Some description.' }
          it { expect(@exp).not_to be_valid }
          it { expect { @exp.save! }.to raise_error }
        end
        context 'When valid value,' do
          let(:test_title)       { 'Some title' }
          let(:test_description) { 'Some description.' }
          it { expect(@exp).to be_valid }
          it { expect { @exp.save! }.not_to raise_error }
        end
      end
    end
  end

  # TODO HACK: テストデータ生成はFactoryGirl使うなどしてリファクタ
  before(:context) do
    Globalize.with_locale(:ja) do
      @exp1 = Experience.new(title: 'exp-1', description: 'description-1', score: 14, created_at: DateTime.now)
      @exp2 = Experience.new(title: 'exp-2', description: 'description-2', score: -5, created_at: DateTime.now + 1)
      @exp3 = Experience.new(title: 'exp-3', description: 'description-3', score:  1, created_at: DateTime.now + 2)
      @exp4 = Experience.new(title: 'exp-4', description: 'description-4', score:  0, created_at: DateTime.now + 3)
      @exp1.set_tag_list_on(:prefectures, "東京都")
      @exp1.set_tag_list_on(:genres, "神社,山")
      @exp1.save!
      @exp2.set_tag_list_on(:prefectures, "宮城県")
      @exp2.set_tag_list_on(:genres, "山")
      @exp2.save!
      @exp3.set_tag_list_on(:prefectures, "宮城県")
      @exp3.set_tag_list_on(:genres, "神社")
      @exp3.save!
      @exp4.set_tag_list_on(:prefectures, "沖縄県")
      @exp4.set_tag_list_on(:genres, "神社")
      @exp4.save!
    end
    @user  = User.create!(name: 'Test User', email: 'test@hyakuren.org', password: 'password')
    Clicking.create!(experience_id: @exp1.id, user_id: @user.id, context: "go")
    Clicking.create!(experience_id: @exp1.id, user_id: @user.id, context: "went")
    Clicking.create!(experience_id: @exp2.id, user_id: @user.id, context: "went")
    Clicking.create!(experience_id: @exp3.id, user_id: @user.id, context: "go")
    Clicking.create!(experience_id: @exp4.id, user_id: @user.id, context: "go", deleted: true)
    @user.rankings.create(experience_id: @exp1.id, rank: 1)
    @user.rankings.create(experience_id: @exp2.id, rank: 3)
    @user.rankings.create(experience_id: @exp3.id, rank: 2)
  end

  # NOTE: eager loadingについては保留(テスト方法調査から)
  describe 'Scopes' do
    describe 'valid_clickings:' do
      before { @exps = @user.clicking_experiences.valid_clickings.to_a }
      context 'Scoped objects' do
        it { expect(@exps).to eq [@exp1, @exp2, @exp3] }
      end
    end

    describe 'for AD contents:' do
      before do
        title = "test title"
        @ad_exp1 = Experience.create!(title: title, advertiser_id: 1, start_date: DateTime.now - 5, end_date: DateTime.now + 1)
        @ad_exp2 = Experience.create!(title: title, advertiser_id: 1, start_date: DateTime.now - 5, end_date: DateTime.now)
        @ad_exp3 = Experience.create!(title: title, advertiser_id: 1, start_date: DateTime.now - 5, end_date: DateTime.now - 1)
      end
      describe 'regular_contents:' do
        before { @exps = Experience.regular_contents.to_a }
        context 'Scoped objects' do
          it { expect(@exps).to eq [@exp1, @exp2, @exp3, @exp4] }
        end
      end
      describe 'ad_contents:' do
        before { @exps = Experience.ad_contents.to_a }
        context 'Scoped objects' do
          it { expect(@exps).to eq [@ad_exp1, @ad_exp2, @ad_exp3] }
        end
      end
      describe 'publishable:' do
        before { @exps = Experience.publishable.to_a }
        context 'Scoped objects' do
          it { expect(@exps).to eq [@ad_exp1, @ad_exp2] }
        end
      end
    end

    describe 'clicked_as_wish_to_go_by:' do
      before { @exps = Experience.clicked_as_wish_to_go_by(@user.id).to_a }
      context 'Scoped objects' do
        it { expect(@exps).to eq [@exp1, @exp3] }
      end
    end

    describe 'clicked_as_been_there_by:' do
      before { @exps = Experience.clicked_as_been_there_by(@user.id).to_a }
      context 'Scoped objects' do
        it { expect(@exps).to eq [@exp1, @exp2] }
      end
    end

    describe 'clicked_as_going_again_by:' do
      before { @exps = Experience.clicked_as_going_again_by(@user.id).to_a }
      context 'Scoped objects' do
        it { expect(@exps).to eq [@exp1] }
      end
    end

    describe 'posted_order:' do
      before { @exps = Experience.posted_order.to_a }
      context 'Scoped objects' do
        it { expect(@exps).to eq [@exp4, @exp3, @exp2, @exp1] }
      end
    end

    describe 'evaluation_order:' do
      before { @exps = Experience.evaluation_order.to_a }
      context 'Scoped objects' do
        it { expect(@exps).to eq [@exp1, @exp3, @exp4, @exp2] }
      end
    end

    describe 'ranked_by(user_id):' do
      before { @exps = Experience.ranked_by(@user.id).to_a }
      context 'Scoped objects' do
        it { expect(@exps).to eq [@exp1, @exp3, @exp2] }
      end
    end
  end

  describe 'Class methods' do
    describe '.filter_by_click_context:' do
      before { @exps = Experience.filter_by_click_context(context,@user).to_a }
      context 'Wish to go selected' do
        let(:context) { 'go' }
        context 'Filtered objects' do
          it { expect(@exps).to eq [@exp1, @exp3] }
        end
      end
      context 'Been there selected' do
        let(:context) { 'went' }
        context 'Filtered objects' do
          it { expect(@exps).to eq [@exp1, @exp2] }
        end
      end
      context 'Going again selected' do
        let(:context) { 'revisit' }
        context 'Filtered objects' do
          it { expect(@exps).to eq [@exp1] }
        end
      end
    end
    describe '.filter_by_click_context: raise case' do
      context 'Empty context selected' do
        let(:context) {''}
        context 'Filtered objects' do
          it { expect {Experience.filter_by_click_context(context,@user)}.to raise_error }
        end
      end
      context 'Nil context selected' do
        let(:context) { nil }
        context 'Filtered objects' do
          it { expect {Experience.filter_by_click_context(context,@user)}.to raise_error }
        end
      end
      context 'Other context selected' do
        let(:context) { 'test' }
        context 'Filtered objects' do
          it { expect {Experience.filter_by_click_context(context,@user)}.to raise_error }
        end
      end
    end

    describe '.filter_by_tag:' do
      before { @exps = Experience.filter_by_tag(Experience.all, tag_names) }
      context 'Specify no word:' do
        let(:tag_names) { [] }
        context 'Filtered objects' do
          it { expect(@exps).to eq [@exp1, @exp2, @exp3, @exp4] }
        end
      end
      context 'Specify single word:' do
        context 'Filtered by "東京都"' do
          let(:tag_names) { ['東京都'] }
          context 'Filtered objects' do
            it { expect(@exps).to eq [@exp1] }
          end
        end
        context 'Filtered by "宮城県"' do
          let(:tag_names) { ['宮城県'] }
          context 'Filtered objects' do
            it { expect(@exps).to eq [@exp2, @exp3] }
          end
        end
        context 'Filtered by "沖縄県"' do
          let(:tag_names) { ['沖縄県'] }
          context 'Filtered objects' do
            it { expect(@exps).to eq [@exp4] }
          end
        end
        context 'Filtered by "山"' do
          let(:tag_names) { ['山'] }
          context 'Filtered objects' do
            it { expect(@exps).to eq [@exp1, @exp2] }
          end
        end
        context 'Filtered by "神社"' do
          let(:tag_names) { ['神社'] }
          context 'Filtered objects' do
            it { expect(@exps).to eq [@exp1, @exp3, @exp4] }
          end
        end
      end
      context 'Specify multiple word:' do
        context 'Filtered by "東京都", "宮城県"' do
          let(:tag_names) { ['東京都', '宮城県'] }
          context 'Filtered objects size' do
            it { expect(@exps.size).to eq(0) }
          end
        end
        context 'Filtered by "宮城県", "山"' do
          let(:tag_names) { ['宮城県', '山'] }
          context 'Filtered objects' do
            it { expect(@exps).to eq [@exp2] }
          end
        end
        context 'Filtered by "沖縄県", "神社"' do
          let(:tag_names) { ['沖縄県', '神社'] }
          context 'Filtered objects' do
            it { expect(@exps).to eq [@exp4] }
          end
        end
        context 'Filtered by "東京都", "山", "神社"' do
          let(:tag_names) { ['東京都', '山', '神社'] }
          context 'Filtered objects' do
            it { expect(@exps).to eq [@exp1] }
          end
        end
      end
    end

    describe '.sort_by_evaluation:' do
      before { @exps = Experience.sort_by_evaluation(Experience.all, sort_type) }
      context 'Sort type is "by_evaluation":' do
        let(:sort_type) { "by_evaluation" }
        context 'Sorted objects' do
          it { expect(@exps).to eq [@exp1, @exp3, @exp4, @exp2] }
        end
      end
      context 'Sort type is not "by_evaluation":' do
        let(:sort_type) { "any type" }
        context 'Sorted objects' do
          it { expect(@exps).to eq [@exp4, @exp3, @exp2, @exp1] }
        end
      end
    end

    describe '.relation_tag_experiences:' do
      # TODO HACK: テストデータ生成はFactoryGirl使うなどしてリファクタ
      before(:context) do
        @exp5 = Experience.create(title: 'exp-5', description: 'description-5', created_at: DateTime.now + 4)
        @exp6 = Experience.create(title: 'exp-6', description: 'description-6', created_at: DateTime.now + 5)
        @exp7 = Experience.create(title: 'exp-7', description: 'description-7', created_at: DateTime.now + 4)
        @exp8 = Experience.create(title: 'exp-8', description: 'description-8', created_at: DateTime.now + 5)
        @exp9 = Experience.create(title: 'exp-9', description: 'description-9', created_at: DateTime.now + 6)
        @exp10 = Experience.create(title: 'exp-10', description: 'description-10', created_at: DateTime.now + 7)
        @exp11 = Experience.create(title: 'exp-11', description: 'description-11', created_at: DateTime.now + 8)
        @exp5.set_tag_list_on(:prefectures, "東京都")
        @exp5.set_tag_list_on(:genres, "神社,山")
        @exp5.save!
        @exp6.set_tag_list_on(:prefectures, "宮城県")
        @exp6.set_tag_list_on(:genres, "山")
        @exp6.save!
        @exp7.set_tag_list_on(:prefectures, "宮城県")
        @exp7.set_tag_list_on(:genres, "寺")
        @exp7.save!
        @exp8.set_tag_list_on(:prefectures, "沖縄県")
        @exp8.set_tag_list_on(:genres, "神社")
        @exp8.save!
        @exp9.set_tag_list_on(:prefectures, "愛知県")
        @exp9.set_tag_list_on(:genres, "神社")
        @exp9.save!
        @exp10.set_tag_list_on(:prefectures, "沖縄県")
        @exp10.set_tag_list_on(:genres, "神社")
        @exp10.save!
        @exp11.set_tag_list_on(:prefectures, "宮城県")
        @exp11.set_tag_list_on(:genres, "神社")
        @exp11.save!
        @exp = Experience.find(@exp11.id)
        @relation_exp = Experience.relation_tag_experiences(@exp)
      end
      context '関連した似たタグを持つ体験' do
        it '関連した体験数が制限値の数であること' do
          expect(@relation_exp.count).to eq(10)
        end

        it '含有率の高い順に体験を表示' do
          exps_arr = [@exp3,@exp6,@exp4,@exp5,@exp2,@exp7,@exp8,@exp9,@exp10,@exp1]
          expect(@relation_exp).to eq(exps_arr)
        end

        it '体験詳細の体験は表示させない' do
          expect(@relation_exp).not_to include(@exp)
        end
      end
    end
  end

  describe 'Instance methods' do
    describe '#tags_least_used:' do
      before { @tags = @exp1.tags_least_used }
      context 'Objects' do
        it { expect(@tags.pluck(:name)).to eq ['東京都', '山', '神社'] }
      end
    end

    describe '#click_count:' do
      context 'Wish to go clicked experience:' do
        before { @count = @exp3.click_count(context_type) }
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
      context 'Been there clicked experience:' do
        before { @count = @exp2.click_count(context_type) }
        context 'Number of wish to go clickings' do
          let(:context_type) { "go" }
          it { expect(@count).to eq(0) }
        end
        context 'Number of been there clickings' do
          let(:context_type) { "went" }
          it { expect(@count).to eq(1) }
        end
        context 'Number of going again clickings' do
          let(:context_type) { "revisit" }
          it { expect(@count).to eq(0) }
        end
      end
      context 'Wish to go and Been there clicked experience:' do
        before { @count = @exp1.click_count(context_type) }
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

    describe '#clickings_find_by_user:' do
      context 'Wish to go clicked experience:' do
        before { @clickings = @exp3.clickings_find_by_user(context_type, @user.id) }
        context 'Number of wish to go clickings' do
          let(:context_type) { "go" }
          it { expect(@clickings.size).to eq(1) }
        end
        context 'Number of been there clickings' do
          let(:context_type) { "went" }
          it { expect(@clickings.size).to eq(0) }
        end
        context 'Number of going again clickings (misuse)' do
          let(:context_type) { "revisit" }
          it { expect(@clickings.size).to eq(0) }
        end
      end
      context 'Been there clicked experience:' do
        before { @clickings = @exp2.clickings_find_by_user(context_type, @user.id) }
        context 'Number of wish to go clickings' do
          let(:context_type) { "go" }
          it { expect(@clickings.size).to eq(0) }
        end
        context 'Number of been there clickings' do
          let(:context_type) { "went" }
          it { expect(@clickings.size).to eq(1) }
        end
        context 'Number of going again clickings (misuse)' do
          let(:context_type) { "revisit" }
          it { expect(@clickings.size).to eq(0) }
        end
      end
      context 'Wish to go and Been there clicked experience:' do
        before { @clickings = @exp1.clickings_find_by_user(context_type, @user.id) }
        context 'Number of wish to go clickings' do
          let(:context_type) { "go" }
          it { expect(@clickings.size).to eq(1) }
        end
        context 'Number of been there clickings' do
          let(:context_type) { "went" }
          it { expect(@clickings.size).to eq(1) }
        end
        context 'Number of going again clickings (misuse)' do
          let(:context_type) { "revisit" }
          it { expect(@clickings.size).to eq(0) }
        end
      end
    end
  end

  describe 'Globalize' do
    before do
      @ja_data = {
        title:        '日本語のタイトル',
        description:  '日本語での説明',
        address:      '宮城県仙台市青葉区本町',
        workday:      '年中'
      }
      @en_data = {
        title:        'English title',
        description:  'English description',
        address:      'Honcho, Aoba Word, Sendai City, Miyagi Pref.',
        workday:      'All year'
      }
      Globalize.with_locale(:ja) do
        exp = Experience.new(@ja_data)
        exp.title_en       = @en_data[:title]
        exp.description_en = @en_data[:description]
        exp.address_en     = @en_data[:address]
        exp.workday_en     = @en_data[:workday]
        exp.save!
      end
    end
    context :ja do
      before do
        I18n.locale = :ja
        @exp = Experience.last
      end
      context :title do
        it { expect(@exp.title).to eq @ja_data[:title] }
      end
      context :description do
        it { expect(@exp.description).to eq @ja_data[:description] }
      end
      context :address do
        it { expect(@exp.address).to eq @ja_data[:address] }
      end
      context :workday do
        it { expect(@exp.workday).to eq @ja_data[:workday] }
      end
    end
    context :en do
      before do
        I18n.locale = :en
        @exp = Experience.last
      end
      context :title do
        it { expect(@exp.title).to eq @en_data[:title] }
      end
      context :description do
        it { expect(@exp.description).to eq @en_data[:description] }
      end
      context :address do
        it { expect(@exp.address).to eq @en_data[:address] }
      end
      context :workday do
        it { expect(@exp.workday).to eq @en_data[:workday] }
      end
    end
  end
end
