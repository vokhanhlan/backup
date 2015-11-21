require 'rails_helper'

RSpec.describe FixedPhoto, :type => :model do
  describe 'Associations' do
    describe FixedPhoto do
      it { is_expected.to belong_to(:user) }
    end
  end
end
