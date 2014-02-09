class User < ActiveRecord::Base
	has_one  :os_statistic
	has_many :installed_ports

	validates_presence_of :uuid
	validate :uuid_cannot_be_invalid

	def uuid_cannot_be_invalid
		if !UUID.validate(uuid)
			errors.add(:uuid, "uuid must be a valid universally unique identifier")
		end
	end
end
