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
  def add_os_data(uuid, os)
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
   
    @os_stats = OsStatistic.new(:uuid => uuid,
                            :macports_version => macports_version,
                            :osx_version      => osx_version,
                            :os_arch          => os_arch,
                            :os_platform      => os_platform,
                            :build_arch       => build_arch,
                            :gcc_version      => gcc_version,
                            :xcode_version    => xcode_version)
    if not @os_stats.save
      logger.debug "Unable to save os_stats"
      logger.debug "Error message: #{@os_stats.errors.full_messages}"
    end
  end

  def add_port_data(uuid, ports)
    logger.debug "In add_port_data"
    
    if ports.nil?
      return
    end
    
    current_time = Time.now
    month = current_time.month
    year = current_time.year
    
    ports.each do |port|
      logger.debug {"Adding port #{port}"}
      port_id = 5
      portEntry = InstalledPort.new(:uuid => uuid,
                               :port_id => port_id,
                               :version => port['version'],
                               :variants => port['variants'],
                               :month => month,
                               :year => year)
                          
      if not portEntry.save
       logger.debug "Unable to save port #{port['name']}"
       logger.debug "Error message: #{portEntry.errors.full_messages}"
     end
    end
  end

  # POST /submissions
  def create
    @submission = Submission.new(params[:submission])
    json = ActiveSupport::JSON.decode(@submission.data) 
    os = json['os']
    active_ports = json['active_ports']
    add_os_data(json['id'], os)
    add_port_data(json['id'], active_ports)

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



