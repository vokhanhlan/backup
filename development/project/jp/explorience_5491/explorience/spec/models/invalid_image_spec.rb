require 'rails_helper'

RSpec.describe InvalidImage, :type => :model do
  describe 'Associations' do
    describe InvalidImage do
      it { is_expected.to have_many(:reporters).dependent(:destroy) }
    end
  end
end
