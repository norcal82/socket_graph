class Chart
	count: 0
	colors  = ['#1abc9c', '#3498db', '#e74c3c', '#f39c12']

	DEFAULT =
		data: ['No data', 1]
		type: 'line'
		title: 'Title not set'
		palette: ['#1abc9c', '#3498db', '#e74c3c', '#f39c12']

	constructor: (element, collection) ->
		@element    = $(element)
		@collection = collection
		@index      = @_getIndex()

		@_generateUUID()
		@_generateChart()

	_counter: -> @count += 1
	_getIndex: -> $('.chart', '.charts').index(@element)
	_generateUUID: (type) -> [type || 'unknown', 'chart', @_counter()].join('-')

	_buildChart: (socketData) ->
		{station_id: 1, sensor_id: 1, count: 55, type: 'line'}
		# count/interval/average?
		# teardown data and build chart options
		# @_generateChart(data, title, colors)

	# pass in top level options
	_generateChart: (_options) ->
		target    = document.createElement("div")
		target.id = @_generateUUID('area-spline')

		# options = $.extend({bindto: target}, arguments)

		#  verify this works ok
		data   = null
		type   = null
		title  = null
		colors = null

		options =
			bindto: target
			data:
				columns: data || DEFAULT['data']
				type: type    || DEFAULT['type']
			title: title    || DEFAULT['title']
			color: colors   || DEFAULT['palette']

		chart = c3.generate options
		# bindto: target
		# data:
		#   columns: data || ['some', 1]
		# title: "title"
		# color: colors || default_palette

		# @collection.insertChart(chart)

class ChartCollection
	constructor: ->
		@charts = (new Chart(element, @) for element in $('.chart', '.charts'))

	afterChartRemove: (chart) ->
		# index = @charts.indexOf(chart)
		# @_removeAt(index)
		# @_size()
		# @updatecharts()

	updateCharts: ->
		for chart in @charts
			chart.index = chart._getIndex()

	_size:                    -> @charts.length #unless @?
	_insert:   (new_chart)    -> @charts.unshift new_chart if new_chart?
	_removeAt: (index)        -> @charts.splice(index, 1) if index?

socket = io.connect('http://localhost:3000', 'force new connection': true)

$ ->
	window.chart_collection = new ChartCollection

	CHART_MAX = 30
	get  = 0
	post = 0
	del  = 0
	put  = 0
	color_palette   = ['#1abc9c', '#3498db', '#e74c3c', '#f39c12']
	request_columns = [['GET', get], ['POST', post], ['DELETE', del], ['PUT', put]]

	sensor_counts   = [ 'station: 2', 1 ]
	sensor_counts1  = [ 'station: 5', 5 ]
	# createStation = (data) -> station_columns.push( uuid = [data.id, data.count])
	sensor_columns  = [sensor_counts, sensor_counts1]

	# generateCharts = ->
	liveChart = c3.generate
		bindto: '#liveChart' #document.createElement()
		data:
			# apply with args/objects {} extend them and pass at data
			columns: sensor_columns
			type: 'area-spline'
		color: pattern: color_palette

	httpChart = c3.generate
		bindto: '#httpChart'
		data:
			columns: request_columns
			type: 'donut'
		donut: title: 'HTTP Actions'
		color: pattern: color_palette

	# generateCharts

	# socket.on varName, (data) ->
		# updateCorresponding graph

	socket.on 'getRequest', (data) ->
		request_columns[0][1] = get += 1
		console.log 'get request'
		console.log data
		updateChart(httpChart, request_columns)

	socket.on 'postRequest', (data) ->
		request_columns[1][1] = post += 1
		console.log 'post request'
		console.log data
		updateChart(httpChart, request_columns)

		if data._id == '2'
			sensor_counts.push data._count
			if sensor_counts.length == CHART_MAX
				sensor_counts.splice 1, 1
			updateChart(liveChart, sensor_columns)
		else
			sensor_counts1.push data._count
			if sensor_counts1.length == CHART_MAX
				sensor_counts1.splice 1, 1
			updateChart(liveChart, sensor_columns)

	socket.on 'station_created', (data) ->
		# console.log 'new station created and registered'
		# console.log data

	socket.emit 'startup', { client: 'pong' }

	updateChart = (chart, data) -> chart.load columns: data

	# console.error $.extend({arr: [1,2,3,4]},{types: 'this'})
