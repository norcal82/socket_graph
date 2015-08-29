mongoose = require('mongoose');

Schema = mongoose.Schema;

StationSchema = new Schema({
    count: Number
});

module.exports = mongoose.model('Station', StationSchema);

Station = mongoose.model('Station', StationSchema)
