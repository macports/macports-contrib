class InstalledPort < ActiveRecord::Base
	belongs_to :port
	has_one    :user

	validates_presence_of :user_id, :port_id, :version

	# Populate InstalledPort rows based on submitted JSON data
	def self.add_installed_ports(uuid, installed_ports)
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
			InstalledPort.add_port(uuid, macports_port, installed_port, month, year)
		end
	end

	def self.add_port(user, macports_port, installed_port, month, year)
		logger.debug {"Adding installed port #{installed_port['name']}"}

		# Update any ports found for this user if they have already been submitted this month
		port_entrys = user.installed_ports.where(:created_at => (Date.today.at_beginning_of_month)..(Date.today.at_end_of_month))
		port_entry = port_entrys.find_by_port_id(macports_port.id)

		# No existing entry was found - create a new one
		if port_entry.nil?
			port_entry = InstalledPort.new
		end

		port_entry[:user_id]  = user.id
		port_entry[:port_id]  = macports_port.id
		port_entry[:version]  = installed_port['version']
		port_entry[:variants] = installed_port['variants']

		if not port_entry.save
			logger.debug "Unable to save port #{installed_port['name']}"
			logger.debug "Reason: #{port_entry.errors.full_messages}"
		end
	end
end
