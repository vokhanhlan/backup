require 'rails_helper'

RSpec.describe ActionLog, :type => :model do
  describe 'Associations' do
    describe ActionLog do
      it { is_expected.to belong_to(:user) }
    end
  end
end
