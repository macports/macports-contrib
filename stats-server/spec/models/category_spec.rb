require 'spec_helper'

describe Category do
  
  before(:each) do
    @category = Category.new
  end
  
  it "should be invalid without a name" do
    @category.should be_invalid
    
    @category.name = "Test"
    @category.should be_valid
  end
  
  it "should have many ports" do
    @category.should have_many :ports
  end
end
