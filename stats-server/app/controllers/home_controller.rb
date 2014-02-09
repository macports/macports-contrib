class HomeController < ChartController

	# Populate the users chart
	def populate_users(chart_name, chart)
		chart.string "Month"
		chart.number "Number of users"

		dataset = chart_dataset chart_name

		dataset.each do |item, count|
			chart.add_row([item, count])
		end
	end

	# Gather number of participating users over past 12 months
	def gather_users_over_time
		monthly_users = Hash.new(0)

		now = Time.now
		now_d = now.to_date

		# Iterate over months from 11 months ago to 0 months ago (current month)
		11.downto(0) do |i|
			month = now.months_ago(i).to_date


			# Get the number of active (submitting) users for this month
			entries = InstalledPort.where(:created_at => (month.at_beginning_of_month)..(month.at_end_of_month))
			count = entries.select("DISTINCT(user_id)").count

			# Key is the abbreviated month name and the year (eg: Aug 2011)
			key = month.to_time.strftime("%b %Y")
			monthly_users[key] = count

			# Get users last month
			if i == 1
				@users_last_month = count
				@last_month = month.to_time.strftime("%B")
			end
		end

		add_chart :participating_users, monthly_users, method(:populate_users)
	end

	def index
		@charts = Hash.new
		gather_users_over_time

		respond_to do |format|
			format.html # index.html.erb
		end
	end


end
