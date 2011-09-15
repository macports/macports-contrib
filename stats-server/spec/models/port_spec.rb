require 'spec_helper'

describe Port do
  
  before(:each) do
    @port = Port.new :name => "name",
                     :version => "version"
  end
  
  it "should belong to category" do
    @port.should belong_to :category
  end

  it "should have many installed ports" do
    @port.should have_many :installed_ports
  end

  it "should have a name" do
    @port[:name] = nil
    @port.should be_invalid
    
    @port[:name] = "name"
    @port.should be_valid
  end
  
  it "should have a version" do
    @port[:version] = nil
    @port.should be_invalid
    
    @port[:version] = "version"
    @port.should be_valid
  end

end
