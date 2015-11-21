require 'rails_helper'

RSpec.describe Guide, :type => :model do

  describe 'Globalize' do
    before do
      @ja_data = {
        title: '日本語のタイトル',
        body:  '日本語での説明'
      }
      @en_data = {
        title: 'English title',
        body:  'English description'
      }
      Globalize.with_locale(:ja) do
        exp = Guide.new(@ja_data)
        exp.section  = 1
        exp.title_en = @en_data[:title]
        exp.body_en  = @en_data[:body]
        exp.save!
      end
    end

    context :ja do
      before do
        I18n.locale = :ja
        @exp = Guide.last
      end
      context :title do
        it { expect(@exp.title).to eq @ja_data[:title] }
      end
      context :body do
        it { expect(@exp.body).to eq @ja_data[:body] }
      end
    end

    context :en do
      before do
        I18n.locale = :en
        @exp = Guide.last
      end
      context :title do
        it { expect(@exp.title).to eq @en_data[:title] }
      end
      context :body do
        it { expect(@exp.body).to eq @en_data[:body] }
      end
    end
  end
end
