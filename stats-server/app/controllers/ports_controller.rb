class PortsController < ChartController
  caches_page :index, :show
  cache_sweeper :port_sweeper, :only => [:create, :update, :destroy]
  
  # Populate a simple two column chart
  def populate_simple_chart(chart_name, chart)
    chart.string "Item"
    chart.number "Frequency"

    dataset = chart_dataset chart_name
    
    dataset.each do |item, count|
      chart.add_row([item, count])
    end
  end
  
  # Populate the versions over time chart
  def populate_monthly_versions(chart_name, chart)
    chart.string "Month"
      
    # Add version columns
    column_order = []
    @top_versions.each do |version, count|
      chart.number version;
      column_order << version
    end

    # Add the data
    dataset = chart_dataset chart_name
    dataset.each do |month, version_counts|
      row = [month]
      column_order.each do |version|
        row << version_counts[version]
      end
      chart.add_row(row)
    end
  end
  
  # Gather all chart datasets
  def gather_data
    gather_frequencies
    gather_data_over_months
  end
  
  # Frequency tallys
  def gather_frequencies()
    variant_count = Hash.new(0)
    version_count = Hash.new(0)
      
    @installed.each do |row|
      if not row.variants.nil?
        # row.variants is a space delimited string of varients
        variants = row.variants.split
        
        # If no variant is present increment a dummy variant 'None'
        if variants.empty?
          variant_count['None'] = variant_count['None'] + 1
        end
        
        # Count
        variants.each do |variant|
          key = variant.to_sym  
          variant_count[key] = variant_count[key] + 1
        end
      end
      
      # Count versions
      key = row.version.to_sym  
      version_count[key] = version_count[key] + 1
    end
    
    populate = method(:populate_simple_chart)
    add_chart :variant_count, variant_count, populate
    add_chart :version_count, version_count, populate
  end
  
  # Gather month by month tallys
  def gather_data_over_months()
    monthly_installs = Hash.new(0)
    monthly_versions = Hash.new
    
    now = Time.now
    now_d = now.to_date
    
    # Iterate over months from 11 months ago to 0 months ago (current month)
    11.downto(0) do |i|
      month = now.months_ago(i).to_date
      
      # Find InstalledPort entries for month
      entries = @installed.where(:created_at => (month.at_beginning_of_month)..(month.at_end_of_month))
      
      count_monthly_installs monthly_installs, month, entries
      count_monthly_versions monthly_versions, month, entries
    end
    
    add_chart :versions_over_time, monthly_versions, method(:populate_monthly_versions)
    add_chart :installs_over_time, monthly_installs, method(:populate_simple_chart)
  end
  
  # Count the number of installs of this port for the given month
  def count_monthly_installs(monthly_installs, month, entries)
    if entries.size == 0
      return
    end
    
    # Key is the abbreviated month name and the year (eg: Aug 2011)
    key = month.to_time.strftime("%b %Y")
    monthly_installs[key] = entries.size
  end
    
  # Count the number of times each version of this port was installed for
  # the given month
  def count_monthly_versions(monthly_versions, month, entries)
    @top_versions.each do |version, count|
      version_entries = entries.where("version = ?", version)
      
      # Key is the abbreviated month name and the year (eg: Aug 2011)
      key = month.to_time.strftime("%b %Y")
      
      if monthly_versions[key].nil?
        monthly_versions[key] = Hash.new
      end
      
      counts_for_month = monthly_versions[key]
      counts_for_month[version] = version_entries.size      
      monthly_versions[key] = counts_for_month
    end  
  end
  
  def index
    unless params[:category_id].nil?
      @ports = Category.find(params[:category_id]).ports.paginate :page => params[:page], :order => 'name ASC', :per_page => 50
    else
      @ports = Port.paginate :page => params[:page], :order => 'name ASC', :per_page => 50
    end
    @page = params[:page] || 1

    respond_to do |format|
      format.html
    end
  end
 
  def show
    @port = Category.find(params[:category_id]).ports.find(params[:id])
    @installed = InstalledPort.where("port_id = ?", @port.id)
    @top_versions = @installed.group(:version).order("count_all DESC").limit(5).size
    @charts = Hash.new

    gather_data
      
    respond_to do |format|
      format.html
    end
  end

  def search
    @ports = Port.search(params[:criteria], params[:val], params[:page])
    @page = params[:page] || 1

    respond_to do |format|
      format.html { render :action => :index }
    end
  end

  def search_generate
    redirect_to "/ports/search/#{params[:criteria]}/#{params[:val]}"
  end
end
