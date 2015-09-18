var Chart, ChartCollection, socket;

Chart = (function() {
  var DEFAULT, colors;

  Chart.prototype.count = 0;

  colors = ['#1abc9c', '#3498db', '#e74c3c', '#f39c12'];

  DEFAULT = {
    data: ['No data', 1],
    type: 'line',
    title: 'Title not set',
    palette: ['#1abc9c', '#3498db', '#e74c3c', '#f39c12']
  };

  function Chart(element, collection) {
    this.element = $(element);
    this.collection = collection;
    this.index = this._getIndex();
    this._generateUUID();
    this._generateChart();
  }

  Chart.prototype._counter = function() {
    return this.count += 1;
  };

  Chart.prototype._getIndex = function() {
    return $('.chart', '.charts').index(this.element);
  };

  Chart.prototype._generateUUID = function(type) {
    return [type || 'unknown', 'chart', this._counter()].join('-');
  };

  Chart.prototype._buildChart = function(socketData) {
    return {
      station_id: 1,
      sensor_id: 1,
      count: 55,
      type: 'line'
    };
  };

  Chart.prototype._generateChart = function(_options) {
    var chart, data, options, target, title, type;
    target = document.createElement("div");
    target.id = this._generateUUID('area-spline');
    data = null;
    type = null;
    title = null;
    colors = null;
    options = {
      bindto: target,
      data: {
        columns: data || DEFAULT['data'],
        type: type || DEFAULT['type']
      },
      title: title || DEFAULT['title'],
      color: colors || DEFAULT['palette']
    };
    return chart = c3.generate(options);
  };

  return Chart;

})();

ChartCollection = (function() {
  function ChartCollection() {
    var element;
    this.charts = (function() {
      var i, len, ref, results;
      ref = $('.chart', '.charts');
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        element = ref[i];
        results.push(new Chart(element, this));
      }
      return results;
    }).call(this);
  }

  ChartCollection.prototype.afterChartRemove = function(chart) {};

  ChartCollection.prototype.updateCharts = function() {
    var chart, i, len, ref, results;
    ref = this.charts;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      chart = ref[i];
      results.push(chart.index = chart._getIndex());
    }
    return results;
  };

  ChartCollection.prototype._size = function() {
    return this.charts.length;
  };

  ChartCollection.prototype._insert = function(new_chart) {
    if (new_chart != null) {
      return this.charts.unshift(new_chart);
    }
  };

  ChartCollection.prototype._removeAt = function(index) {
    if (index != null) {
      return this.charts.splice(index, 1);
    }
  };

  return ChartCollection;

})();

socket = io.connect('http://localhost:3000', {
  'force new connection': true
});

$(function() {
  var CHART_MAX, color_palette, del, get, httpChart, liveChart, post, put, request_columns, sensor_columns, sensor_counts, sensor_counts1, updateChart;
  window.chart_collection = new ChartCollection;
  CHART_MAX = 30;
  get = 0;
  post = 0;
  del = 0;
  put = 0;
  color_palette = ['#1abc9c', '#3498db', '#e74c3c', '#f39c12'];
  request_columns = [['GET', get], ['POST', post], ['DELETE', del], ['PUT', put]];
  sensor_counts = ['station: 2', 1];
  sensor_counts1 = ['station: 5', 5];
  sensor_columns = [sensor_counts, sensor_counts1];
  liveChart = c3.generate({
    bindto: '#liveChart',
    data: {
      columns: sensor_columns,
      type: 'area-spline'
    },
    color: {
      pattern: color_palette
    }
  });
  httpChart = c3.generate({
    bindto: '#httpChart',
    data: {
      columns: request_columns,
      type: 'donut'
    },
    donut: {
      title: 'HTTP Actions'
    },
    color: {
      pattern: color_palette
    }
  });
  socket.on('getRequest', function(data) {
    request_columns[0][1] = get += 1;
    console.log('get request');
    console.log(data);
    return updateChart(httpChart, request_columns);
  });
  socket.on('postRequest', function(data) {
    request_columns[1][1] = post += 1;
    console.log('post request');
    console.log(data);
    updateChart(httpChart, request_columns);
    if (data._id === '2') {
      sensor_counts.push(data._count);
      if (sensor_counts.length === CHART_MAX) {
        sensor_counts.splice(1, 1);
      }
      return updateChart(liveChart, sensor_columns);
    } else {
      sensor_counts1.push(data._count);
      if (sensor_counts1.length === CHART_MAX) {
        sensor_counts1.splice(1, 1);
      }
      return updateChart(liveChart, sensor_columns);
    }
  });
  socket.on('station_created', function(data) {});
  socket.emit('startup', {
    client: 'pong'
  });
  return updateChart = function(chart, data) {
    return chart.load({
      columns: data
    });
  };
});
