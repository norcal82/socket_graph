// Generated by CoffeeScript 1.9.3
(function() {
  var StationSchema, mongoose;

  mongoose = require('mongoose');

  StationSchema = new mongoose.Schema({
    count: Number
  });

  module.exports = mongoose.model('Station', StationSchema);

}).call(this);
