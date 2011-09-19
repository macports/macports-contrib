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
  
  # Returns a hash of frequency hashes with a key for each column
  # The frequency hash contains counts of the number of times a value has 
  # appeared in its column.
  # e.g. If "2.0.0" appears 8 times in the "macports_version" column then
  # frequencies["macports_version"]["2.0.0"] == 8
  def gather_frequencies
                           
    columns = { "macports_version" => Hash.new(0),
                "osx_version" => Hash.new(0),
                "os_arch" => Hash.new(0),
                "os_platform" => Hash.new(0),
                "build_arch" => Hash.new(0),
                "gcc_version" => Hash.new(0),
                "xcode_version" => Hash.new(0)
              }
    
    OsStatistic.find_each do |os_stat|
      # For each column in OsStatistics count the number of occurrences of a particular value
      columns.each do |column, hash|
        value = os_stat.attributes[column]
        hash[value] = hash[value] + 1
      end
    end
    
    return columns
  end
  
  
  def index
    @charts = Hash.new
    frequencies = gather_frequencies
    
    # Add charts for each type of data
    frequencies.each do |column, data_hash|
      add_chart column.to_sym, data_hash, method(:populate)
    end
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def show
    @os_stats = OsStatistic.find(params[:id])
  end
end