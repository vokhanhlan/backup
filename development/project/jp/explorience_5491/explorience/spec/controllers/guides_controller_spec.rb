require 'rails_helper'

RSpec.describe GuidesController, :type => :controller do
  # TODO: top_controllerにも同じ定義、1箇所にする
  before do
    allow(controller).to receive(:restore_locale).and_return(:en)
  end

  describe "GET index" do
    it "returns http success" do
      get :index
      expect(response).to be_success
    end
  end

end
