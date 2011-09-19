require 'spec_helper'

describe User do
  before(:each) do
    @user = User.new
  end
  
  it "should have one os_statistic" do
    @user.should have_one :os_statistic
  end
  
  it "should have many ports" do
    @user.should have_many :installed_ports
  end
  
  it "should have a uuid present" do
    @user.should be_invalid
    @user.uuid = 'BD5C379F-F485-4C89-A3DB-20A3476116F1'
    @user.should be_valid
  end
  
  it "should only have a valid uuid" do
    @user.uuid = 'ABC-INVALID-UUID'
    @user.should be_invalid
    @user.errors[:uuid].should == ["uuid must be a valid universally unique identifier"]
            
    # A valid UUID - generated with uuidgen
    @user.uuid = 'BD5C379F-F485-4C89-A3DB-20A3476116F1'
    @user.should be_valid
  end
end
