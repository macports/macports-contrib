require 'spec_helper'

describe OsStatistic do
  before(:each) do
    @stat = OsStatistic.new :user_id =>10,
                            :macports_version => "version",
                            :osx_version => "version",
                            :os_arch => "arch",
                            :os_platform => "platform",
                            :build_arch => "build_arch",
                            :gcc_version => "gcc_version",
                            :xcode_version => "xcode_version"
  end
  
  it "should belong to user" do
    @stat.should belong_to :user
  end
  
  it "should have a macports version" do
    @stat[:macports_version] = nil
    @stat.should be_invalid
    
    @stat[:macports_version] = "version"
    @stat.should be_valid
  end
  
  it "should have an osx version" do
    @stat[:osx_version] = nil
    @stat.should be_invalid
    
    @stat[:osx_version] = "version"
    @stat.should be_valid
  end
  
  it "should have an os arch" do
    @stat[:os_arch] = nil
    @stat.should be_invalid
    
    @stat[:os_arch] = "arch"
    @stat.should be_valid
  end
  
  it "should have an os platform" do
    @stat[:os_platform] = nil
    @stat.should be_invalid
    
    @stat[:os_platform] = "platform"
    @stat.should be_valid
  end
  
  it "should have a build arch" do
    @stat[:build_arch] = nil
    @stat.should be_invalid
    
    @stat[:build_arch] = "arch"
    @stat.should be_valid
  end
  
  it "should have a gcc version" do
    @stat[:gcc_version] = nil
    @stat.should be_invalid
    
    @stat[:gcc_version] = "gcc"
    @stat.should be_valid
  end
  
  it "should have an xcode version" do
    @stat[:xcode_version] = nil
    @stat.should be_invalid
    
    @stat[:xcode_version] = "xcode"
    @stat.should be_valid
  end
  
  it "should have a valid user" do
    user = User.new
    @stat.user = user
    @stat.should be_invalid    
  end
  
  describe "self.add_os_data" do
    
    before(:each) do        
      @os = Hash.new
      @os['macports_version'] = 'macports_version'
      @os['osx_version'] = 'osx_version'
      @os['os_arch'] = 'os_arch'
      @os['os_platform'] = 'os_platform'
      @os['build_arch'] = 'build_arch'
      @os['gcc_version'] = 'gcc_version'
      @os['xcode_version'] = 'xcode_version'
      
      @valid_user = User.new :uuid => "8CF957AF-4710-4048-BF1F-B3B3EAEA6604"
      @valid_user.save
    end
    
    it "should return false when user is nil" do
      result = OsStatistic.add_os_data nil, @os
      result.should be_false
    end
    
    it "should return false when os is nil" do
      result = OsStatistic.add_os_data @valid_user, nil
      result.should be_false
    end
    
    it "should return false when user is not valid" do
      # Create an empty user that isn't in the database
      invalid_user = User.new
      
      result = OsStatistic.add_os_data invalid_user, @os
      result.should be_false
      
      # There should be no entry for this user in the table
      entry = OsStatistic.find_by_user_id(invalid_user.id)
      entry.should be_nil
    end
    
    it "should fail when the given valid user is not in the database" do
      user = User.new :uuid => @valid_user.uuid
      user.should be_valid
      
      result = OsStatistic.add_os_data user, @os
      result.should be_false
      
      # There should be no entry for this user in the table
      entry = OsStatistic.find_by_user_id(user.id)
      entry.should be_nil
    end
    
    it "should correctly save data for new users" do  
      # There should be no entry with new_user.id
      entry = @valid_user.os_statistic
      entry.should be_nil
      
      # Add a new entry and check the result
      result = OsStatistic.add_os_data @valid_user, @os
      result.should be_true
      
      # Find the entry
      entry = OsStatistic.find_by_user_id(@valid_user.id)
      entry.should_not be_nil
      
      # Verify that the data is correctly saved
      entry.macports_version.should == @os['macports_version']
      entry.osx_version.should == @os['osx_version']
      entry.os_arch.should == @os['os_arch']
      entry.os_platform.should == @os['os_platform']
      entry.build_arch.should == @os['build_arch']
      entry.gcc_version.should == @os['gcc_version']
      entry.xcode_version.should == @os['xcode_version']
    end
    
    it "should update an existing entry for existing users" do
      # Add an entry to update
      @stat.user_id = @valid_user.id
      @stat.save
      
      # Retrieve the entry
      entry = @valid_user.os_statistic
      entry.should_not be_nil
      
      # Updated values
      up = Hash.new
      up['macports_version'] = 'updated_macports_version'
      up['osx_version'] = 'updated_osx_version'
      up['os_arch'] = 'updated_os_arch'
      up['os_platform'] = 'updated_os_platform'
      up['build_arch'] = 'updated_build_arch'
      up['gcc_version'] = 'updated_gcc_version'
      up['xcode_version'] = 'updated_xcode_version'
      
      # Update entry and check the result
      result = OsStatistic.add_os_data @valid_user, up
      result.should be_true
      
      # Verify that the data was correctly updated
      entry.macports_version.should == up['macports_version']
      entry.osx_version.should == up['osx_version']
      entry.os_arch.should == up['os_arch']
      entry.os_platform.should == up['os_platform']
      entry.build_arch.should == up['build_arch']
      entry.gcc_version.should == up['gcc_version']
      entry.xcode_version.should == up['xcode_version']
    end
  end
end
