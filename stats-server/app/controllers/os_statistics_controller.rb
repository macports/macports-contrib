class OsStatisticsController < ChartController
  
  # Populate charts with data
  def populate(chart_name, chart)
    # This is the column's label
    chart.string "Item"
    
    # This is the numerical value associated with the label
    chart.number "Frequency"

    # Add rows of data
    dataset = chart_dataset chart_name
    dataset.each do |item, count|
      chart.add_row([item, count])
    end
  end
  
  # Gather all needed data from the model
  def gather_frequencies(stats)
    macports_version = Hash.new(0)
    osx_version = Hash.new(0)
    os_arch = Hash.new(0)
    os_platform = Hash.new(0)
    build_arch = Hash.new(0)
    gcc_version = Hash.new(0)
    xcode_version = Hash.new(0)
    
    # For each column in OsStatistics count the number of unique entries
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
    
    populate = method(:populate)
    
    add_chart :macports_version, macports_version, populate
    add_chart :osx_version, osx_version, populate
    add_chart :os_arch, os_arch, populate
    add_chart :os_platform, os_platform, populate
    add_chart :build_arch, build_arch, populate
    add_chart :macports_version, macports_version, populate
    add_chart :gcc_version, gcc_version, populate
    add_chart :xcode_version, xcode_version, populate
  end
    
  def index
    @stats = OsStatistic.all
    @charts = Hash.new
    gather_frequencies @stats
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def show
    @os_stats = OsStatistic.find(params[:id])
  end
end