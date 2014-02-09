# This is a base class for controllers that display charts
# It contains helpful methods for managing those charts

class ChartController < ApplicationController

	# Associate chart name with a data set
	def add_chart(chart_name, dataset, populate_code)
		set_chart_attribute chart_name, :data, dataset
		set_chart_attribute chart_name, :populate, populate_code
	end

	# Set the chart's title
	def set_chart_title(chart, title)
		set_chart_attribute chart, :title, title
	end

	# Set the chart's type
	def set_chart_type(chart, type)
		set_chart_attribute chart, :type, type
	end

	# Call a chart's populate_code to populate it with its associated dataset
	def populate_chart(chart_name, chart)
		populate = @charts[chart_name][:populate]
		populate.call(chart_name, chart)
	end

	# Get the dataset associate with this chart
	def chart_dataset(chart_name)
		@charts[chart_name][:data]
	end

	# Check if the chart's dataset is empty
	def dataset_empty?(chart_name)
		dataset = chart_dataset(chart_name)
		return dataset.empty?
	end

	# Get the title associate with this chart
	def chart_title(chart_name)
		@charts[chart_name][:title]
	end

	# Get the type of this chart (eg: PieChart, LineChart, etc...)
	def chart_type(chart_name)
		@charts[chart_name][:type]
	end

	private

	# Associate an attribute with the given chart
	def set_chart_attribute(chart, attribute, value)
		attrs = @charts[chart]

		if attrs.nil?
			attrs = Hash.new
		end

		attrs[attribute] = value
		@charts[chart] = attrs
	end
end
