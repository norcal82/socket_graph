express = require('express')
app     = express()
server  = require('http').Server(app)
io      = require('socket.io')(server)
request = require('request')
morgan  = require('morgan')
mongoose = require('mongoose')

base_uri = 'http://localhost:3000'
mongo_uri = 'http://localhost:28017/serverStatus'
index = '/'
app.use("/scripts", express.static(__dirname + '/scripts'));
# logging
app.use(morgan('combined'))

mongoose.connect('mongodb://localhost:27017/graph');

db = mongoose.connection
db.on 'error', console.error.bind(console, 'connection error:')
db.once 'open', (callback) ->
  console.log "mongo connection"

Schema = mongoose.Schema;

StationSchema = new Schema({
    count: Number
});

module.exports = mongoose.model('Station', StationSchema);
Station = mongoose.model('Station', StationSchema)

bodyParser = require('body-parser');
app.use(bodyParser.json()); # support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); # support encoded bodies


port_number = 3000
server.listen port_number
console.log "Sever started on port: " + port_number

io.on 'connection', (socket) ->
  socket.emit 'startup', { server: 'ping' }

app.get index, (req, res) ->
  io.sockets.emit 'getRequest', {}
  res.sendFile __dirname + '/index.html'

# app.get '/api/station/:id', (req, res) ->
#   res.json({ message: 'get @ /api endpoint' })

  # gets last saved values

# PUTS
# app.put '/api/station/:id', (req, res) ->
#   console.log req.params.id

#   data = { message: 'put @ /api endpoint' }

#   res.json(data)

  # udpates the ui

# app.post '/api/station/sensor', (req, res) ->

# POSTS
app.post '/api/station', (req, res) ->
  Station = mongoose.model('Station', '/models/station.js');
  station = new Station
  station_id = req.body.id
  count      = req.body.count
  station.count = req.body.count
  station.save (err) ->
    if err
      res.send err
    io.sockets.emit 'countRecieved', { _id: station_id, _count: count   }
    res.json({_id: station_id, _message: "created station "+ station_id})
    station.find {}, (err, stations) ->
        # do thangs
      console.log(stations)

# app.post 'log', (req, res) -> # creates a new log message
#   data
#     message: ''
#     time: ''

#   res.json data
  # append to log file. logstalgia on production logs!

#TODO: figure out routes
# add logging helper for crud actions, socket stuff
postRequest = ->
   request.post(base_uri + '/api/station').form({id:'5', count: Math.floor(Math.random() * 600) + 1})

postRequest1 = ->
   request.post(base_uri + '/api/station').form({id:'2', count: Math.floor(Math.random() * 600) + 1})

getRequest = ->
   request.get(base_uri + index)

# setInterval(postRequest, 2000)
# setInterval(postRequest1, 1500)
# setInterval(getRequest, 1000)
