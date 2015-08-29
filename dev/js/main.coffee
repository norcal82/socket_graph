socket = io.connect('http://localhost:3000', 'force new connection': true)

$ ->
  CHART_MAX = 30
  get  = 0
  post = 0
  del  = 0
  put  = 0
  color_palette   = ['#1abc9c', '#3498db', '#e74c3c', '#f39c12']
  request_columns = [['GET', get], ['POST', post], ['DELETE', del], ['PUT', put]]
  sensor_counts   = [ 'station: 2', 1 ]
  sensor_counts1  = [ 'station: 5', 5 ]
  sensor_columns  = [sensor_counts, sensor_counts1]

  # generateCharts = ->
  chart = c3.generate
    data:
      columns: sensor_columns
      type: 'area-spline'
    color: pattern: color_palette

  chart1 = c3.generate
    bindto: '#chart1'
    data:
      columns: request_columns
      type: 'donut'
    donut: title: 'HTTP Actions'
    color: pattern: color_palette

  # generateCharts

  socket.on 'getRequest', (data) ->
    get = get + 1
    console.log 'get request'
    console.log data
    updateChart(chart1, request_columns)

  socket.on 'postRequest', (data) ->
    post = post + 1
    console.log 'post request'
    console.log data
    updateChart(chart1, request_columns)

    if data._id == '2'
      sensor_counts.push data._count
      if sensor_counts.length == CHART_MAX
        sensor_counts.splice 1, 1
    else
      sensor_counts1.push data._count
      if sensor_counts1.length == CHART_MAX
        sensor_counts1.splice 1, 1
        updateChart(chart, sensor_columns)

  socket.on 'station_created', (data) ->
    # console.log 'new station created and registered'
    # console.log data

  socket.emit 'startup', { client: 'pong' }

  updateChart = (chart, data) ->
    chart.load
      columns: data

  # console.error $.extend({arr: [1,2,3,4]},{types: 'this'})
