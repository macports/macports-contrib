class SubmissionsController < ApplicationController
  # GET /submissions
  # GET /submissions.xml
  def index
    @submissions = Submission.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /submissions/1
  # GET /submissions/1.xml
  def show
    @submission = Submission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # Populate an OsStatistics row based on submitted JSON data
  def add_os_data(user, os)
    logger.debug "In add_os_data"
    
    if os.nil?
      return
    end
    
    macports_version = os['macports_version']
    osx_version      = os['osx_version']
    os_arch          = os['os_arch']
    os_platform      = os['os_platform']
    build_arch       = os['build_arch']
    gcc_version      = os['gcc_version']
    xcode_version    = os['xcode_version']
   
    # Try to find an existing entry
    os_stats = OsStatistic.find_by_user_id(user.id)
     
    if os_stats.nil?
      # No entry for this user - create a new one
      os_stats = OsStatistic.new()
    end
    
    os_stats[:user_id]          = user.id
    os_stats[:macports_version] = macports_version
    os_stats[:osx_version]      = osx_version
    os_stats[:os_arch]          = os_arch
    os_stats[:os_platform]      = os_platform
    os_stats[:build_arch]       = build_arch
    os_stats[:gcc_version]      = gcc_version
    os_stats[:xcode_version]    = xcode_version
    
    if not os_stats.save
      logger.debug "Unable to save os_stats"
      logger.debug "Error message: #{os_stats.errors.full_messages}"
    end
  end

  def add_port(user_id, macports_port, installed_port, month, year)
    logger.debug {"Adding installed port #{installed_port['name']}"}
        
    portEntry = InstalledPort.new(:user_id => user_id,
                             :port_id => macports_port.id,
                             :version => installed_port['version'],
                             :variants => installed_port['variants'],
                             :month => month,
                             :year => year)
                        
    if not portEntry.save
     logger.debug "Unable to save port #{port['name']}"
     logger.debug "Error message: #{portEntry.errors.full_messages}"
   end
 end

  def add_installed_ports(uuid, installed_ports)
    logger.debug "In add_installed_ports"
    
    if installed_ports.nil?
      return
    end
    
    current_time = Time.now
    month = current_time.month
    year = current_time.year
    
    installed_ports.each do |installed_port|
      # Find the reported port in the MacPorts repository
      macports_port = Port.find_by_name(installed_port['name'])

      if macports_port.nil?
        logger.debug {"Skipping unknown port #{installed_port['name']} - Not in MacPorts repository"}
        next
      end
      
      # Update installed port information
      add_port(uuid, macports_port, installed_port, month, year)
    end
  end

  # POST /submissions
  def create
    @submission = Submission.new(params[:submission])
    json = ActiveSupport::JSON.decode(@submission.data) 
    os = json['os']
    active_ports = json['active_ports']
    
    user = User.find_or_create_by_uuid(json['id'])
    
    add_os_data(user, os)
    add_installed_ports(json['id'], active_ports)

    respond_to do |format|
      format.html { redirect_to(@submission, :notice => 'Submission was successfully created.') }
    end
  end

  # GET /submits/new
  # GET /submits/new.xml
  def new
    @submit = Submission.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @submit }
    end
  end


  def destroy
    @submit = Submission.find(params[:id])
    @submit.destroy

    respond_to do |format|
      format.html { redirect_to(submissions_url) }
      format.xml  { head :ok }
    end
  end

end



