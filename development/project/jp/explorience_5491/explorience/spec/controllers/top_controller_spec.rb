require 'rails_helper'

RSpec.describe TopController, :type => :controller do
  # TODO: guides_controllerにも同じ定義、1箇所にする
  before do
    allow(controller).to receive(:restore_locale).and_return(:en)
  end

  describe "#show" do
    context "ad contents none" do
      before do
        [*"A".."C"].each do |c|
          Experience.create(title: c * 3)
        end
      end
      before{ get :show }

      it do
        expect(assigns(:experiences).size).to eq 3
      end
    end

    context "ad contents exists" do
      before do
        %w(A B C D E).each_with_index do |c, i|
          Experience.create(title: c, advertiser_id: '1', end_date: Date.today.since(4.days), created_at: Date.today.ago(i.hours))
        end

        [*1..36].each do |i|
          Experience.create(title: i, created_at: Date.today.ago(i.days))
        end
      end
      before{ get :show, page: page }

      context "show page 0" do
        let(:page){ 0 }

        it do
          expect(assigns(:ad_experiences).size).to eq 2
          expect(assigns(:ad_experiences).map(&:title)).to eq(%w(A B))
          expect(assigns(:experiences).size).to eq 8
          expect(assigns(:experiences).map(&:title)).to eq(%w(1 2 3 4 5 6 7 8))
        end
      end

      context "show page 1" do
        let(:page){ 1 }

        it do
          expect(assigns(:ad_experiences).size).to eq 2
          expect(assigns(:ad_experiences).map(&:title)).to eq(%w(A B))
          expect(assigns(:experiences).size).to eq 8
          expect(assigns(:experiences).map(&:title)).to eq(%w(1 2 3 4 5 6 7 8))
        end
      end

      context "show page 3" do
        let(:page){ 3 }

        it do
          expect(assigns(:ad_experiences).size).to eq 1
          expect(assigns(:ad_experiences).map(&:title)).to contain_exactly('E')
          expect(assigns(:experiences).size).to eq 9
          expect(assigns(:experiences).map(&:title)).to eq(%w(17 18 19 20 21 22 23 24 25))
        end
      end

      context "show page 4" do
        let(:page){ 4 }

        it do
          expect(assigns(:ad_experiences).size).to eq 0
          expect(assigns(:experiences).size).to eq 10
        end
      end

      context "show page 5" do
        let(:page){ 5 }

        it do
          expect(assigns(:ad_experiences).size).to eq 0
          expect(assigns(:experiences).size).to eq 1
          expect(assigns(:experiences).map(&:title)).to contain_exactly('36')
        end
      end
    end

    context "sort by evaluation" do
      before do
        %w(A B C D E).each.with_index(1) do |c, i|
          Experience.create(title: c, advertiser_id: '1', score: i * 100, end_date: Date.today.since(4.days), created_at: Date.today.ago(i.hours))
        end

        [*1..20].each do |i|
          Experience.create(title: i, score: i * 2, created_at: Date.today.ago(i.days))
        end
      end
      before{ get :show, page: page, sort: 'eval' }

      context "show page 1" do
        let(:page){ 1 }

        it do
          expect(assigns(:ad_experiences).size).to eq 0
          expect(assigns(:experiences).size).to eq 10
          expect(assigns(:experiences).map(&:title)).to eq(%w(E D C B A 20 19 18 17 16))
        end
      end

      context "show page 3" do
        let(:page){ 3 }

        it do
          expect(assigns(:ad_experiences).size).to eq 0
          expect(assigns(:experiences).size).to eq 5
          expect(assigns(:experiences).map(&:title)).to eq(%w(5 4 3 2 1))
        end
      end
    end
  end

end

