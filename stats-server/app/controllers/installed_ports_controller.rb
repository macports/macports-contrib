class InstalledPortsController < ChartController
  
  # Populate the users chart
  def populate_top25(chart_name, chart)
    chart.string "Port"
    chart.number "Number of installations"

    dataset = chart_dataset chart_name
    
    dataset.each do |item, count|
      chart.add_row([item, count])
    end
  end
  
  # Return the average number of ports each user has installed
  def average_ports_per_user
    users = User.all
    sum = 0
    
    users.each do |user|
      sum = sum + user.installed_ports.count
    end
    
    return 0 unless users.count > 0
    average = sum / users.count unless users.count == 0
  end
  
  # Find the port that has been installed most this year
  def most_installed_port_this_year
    now = Time.now.to_date

    # Find InstalledPort entries for this month
    current = InstalledPort.where(:created_at => (now.at_beginning_of_year)..(now.at_end_of_year))
    
    
    top = current.count(:port_id,
                               :group => :port_id,
                               :order => 'count_port_id DESC',
                               :limit => 1)
                               
   # most populator port this year
   popular_port_year = top.first
   @popular_port_year = nil
   @popular_port_year_count = 0
   unless popular_port_year == nil
     @popular_port_year = Port.find(popular_port_year[0])
     @popular_port_year_count = popular_port_year[1]
   end
  end
  
  # Most popular port this month
  def popular_port_this_month(port_id, count)
    @popular_port_month = Port.find(port_id)
    @popular_port_month_count = count
  end
  
  def gather_top25
    
    top25 = Hash.new(0)
    now = Time.now.to_date
    
    # Full month name
    @month = Time.now.strftime("%B")
    # This year
    @year = Time.now.strftime("%Y")
    
    # Find InstalledPort entries for this month
    current = InstalledPort.where(:created_at => (now.at_beginning_of_month)..(now.at_end_of_month))
    
    @top = current.count(:port_id,
                               :group => :port_id,
                               :order => 'count_port_id DESC',
                               :limit => 25)    
    
    @top.each do |port_id, count|
      port = Port.find(port_id)
      if not port.nil?
        top25[port.name] = count
      end
    end
    
    # Sort the table by count
    sorted = top25.sort_by { |k, v| v }
    top25 = sorted.reverse # Descending order
        
    add_chart :top25, top25, method(:populate_top25)
  end
  
  def gather_data
    
    # Get the top 25 most installed ports for this month
    gather_top25
    
    # Average number of ports per user                        
    @average_ports = average_ports_per_user
    
    # most populator port this month
    pop = @top.first
    if not pop.nil?
      popular_port_this_month(pop[0],pop[1])
    end
    
    # most popular port this year
    most_installed_port_this_year
  end
  
  def index   
    
    @charts = Hash.new
    
    gather_data
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
end
