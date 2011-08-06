class OsStatisticsController < ApplicationController
  
  def hash_to_google_json(hash, columns)
    json = Hash.new
    
    json['cols'] = columns
    
    # Create rows array
    rows = []
    hash.each do |key, frequency|
      row = Hash.new
      row['c'] = [{'v' => key}, {'v' => frequency}]
      rows << row
    end
  
    json['rows'] = rows
    
    return json.to_json.to_s
  end
  
  def to_json(frequencies)
    first_col = {'id' => 'name', 'label' => 'name', 'type' => 'string'}
    second_col = {'id' => 'frequency', 'label' => 'Frequency', 'type' => 'number'}
    
    cols = [first_col, second_col]
    
    json = Hash.new
    frequencies.each do |name, hash|
      json[name] = hash_to_google_json(frequencies[name], cols)
    end
    
    return json
  end
  
  def gather_frequencies(stats)
    macports_version = Hash.new(0)
    osx_version = Hash.new(0)
    os_arch = Hash.new(0)
    os_platform = Hash.new(0)
    build_arch = Hash.new(0)
    gcc_version = Hash.new(0)
    xcode_version = Hash.new(0)
    
    stats.each do |row|
      key = row.macports_version.to_sym  
      macports_version[key] = macports_version[key] + 1
      
      key = row.osx_version.to_sym  
      osx_version[key] = osx_version[key] + 1
    
      key = row.os_arch.to_sym  
      os_arch[key] = os_arch[key] + 1
    
      key = row.os_platform.to_sym  
      os_platform[key] = os_platform[key] + 1
      
      key = row.build_arch.to_sym  
      build_arch[key] = build_arch[key] + 1
      
      key = row.gcc_version.to_sym  
      gcc_version[key] = gcc_version[key] + 1
      
  		key = row.xcode_version.to_sym  
      xcode_version[key] = xcode_version[key] + 1    
    end
    
    frequencies = Hash.new
    frequencies['macports_version'] = macports_version
    frequencies['osx_version'] = osx_version
    frequencies['os_arch'] = os_arch
    frequencies['os_platform'] = os_platform
    frequencies['build_arch'] = build_arch
    frequencies['gcc_version'] = gcc_version
    frequencies['xcode_version'] = xcode_version
    
    return frequencies
  end
  
  def index
    @stats = OsStatistic.all
    
    frequencies = gather_frequencies @stats
    @chartjson = to_json frequencies
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def show
    @os_stats = OsStatistic.find(params[:id])
  end
end