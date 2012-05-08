require 'spec_helper'

describe Dwolla do
  context "in test mode" do
    before do
      test_var = Dwolla.test_mode
      Dwolla.test_mode = true
    end
    after { Dwolla.test_mode = false }

    its(:endpoint) { should == "https://www.dwolla.com/oauth/rest/testapi" }
  end

  context "test mode off" do
    before do
      Dwolla.test_mode.should == false
    end

    its(:endpoint) { should == "https://www.dwolla.com/oauth/rest/accountapi" }
  end

  its(:user_agent) { should == "Dwolla Ruby Wrapper" }

  describe 'debugging' do
    after do
      Dwolla.debug = false
    end

    it { should_not be_debugging }

    it 'should be debugging' do
      Dwolla.debug = true
      Dwolla.should be_debugging
    end
  end
end
