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

	def index
		@charts = Hash.new
		frequencies = OsStatistic.frequencies

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
