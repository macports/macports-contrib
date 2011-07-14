class OsStatisticsController < ApplicationController
  
  def gather_frequencies(stats)
    @macports_version = Hash.new(0)
    @osx_version = Hash.new(0)
    @os_arch = Hash.new(0)
    @os_platform = Hash.new(0)
    @build_arch = Hash.new(0)
    @gcc_version = Hash.new(0)
    @xcode_version = Hash.new(0)
    
    stats.each do |row|
      key = row.macports_version.to_sym  
      @macports_version[key] = @macports_version[key] + 1
      
      key = row.osx_version.to_sym  
      @osx_version[key] = @osx_version[key] + 1
    
      key = row.os_arch.to_sym  
      @os_arch[key] = @os_arch[key] + 1
    
      key = row.os_platform.to_sym  
      @os_platform[key] = @os_platform[key] + 1
      
      key = row.build_arch.to_sym  
      @build_arch[key] = @build_arch[key] + 1
      
      key = row.gcc_version.to_sym  
      @gcc_version[key] = @gcc_version[key] + 1
      
  		key = row.xcode_version.to_sym  
      @xcode_version[key] = @xcode_version[key] + 1    
    end
    
  end
  
  def index
    @stats = OsStatistic.all
    
    gather_frequencies(@stats)
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def show
    @os_stats = OsStatistic.find(params[:id])
  end
end