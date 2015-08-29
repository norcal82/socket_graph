express  = require('express')
app      = express()
server   = require('http').Server(app)
io       = require('socket.io')(server)
request  = require('request')
morgan   = require('morgan')
mongoose = require('mongoose')

bodyParser = require('body-parser');
app.use(bodyParser.json()); # support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); # support encoded bodies

port_number  = process.argv[2] || 3000

server.listen port_number
console.log "listening on: " + port_number

base_uri     = 'http://localhost:3000'
mongodb_uri  = 'http://localhost:28017/serverStatus'
index        = '/'

app.use("/prod/css", express.static(__dirname + '/prod/css'));
app.use("/prod/js", express.static(__dirname + '/prod/js'));

# logging
app.use(morgan('combined'))

mongoose.connect('mongodb://localhost:27017/graph')

db = mongoose.connection
db.on 'error', console.error.bind(console, 'connection error:')
db.once 'open', (callback) ->
  console.log "mongo connection"


# move
Schema = mongoose.Schema;

StationSchema = new Schema({
    count: Number
});

module.exports = mongoose.model('Station', StationSchema);
Station = mongoose.model('Station', StationSchema)

io.on 'connection', (socket) ->
  socket.emit 'startup', { server: 'ping' }

app.get index, (req, res) ->
  io.sockets.emit 'getRequest', {}
  res.sendFile __dirname + '/prod/index.html'

# app.get '/api/station/:id', (req, res) ->
#   res.json({ message: 'get @ /api endpoint' })

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
    io.sockets.emit 'postRequest', { _id: station_id, _count: count   }
    res.json({_id: station_id, _message: "created station "+ station_id})
    station.find {}, (err, stations) ->
        # do thangs
      console.log(stations)


#TODO: figure out routes
# add logging helper for crud actions, socket stuff
postRequest = ->
   request.post(base_uri + '/api/station').form({id:'5', count: Math.floor(Math.random() * 600) + 1})

postRequest1 = ->
   request.post(base_uri + '/api/station').form({id:'2', count: Math.floor(Math.random() * 600) + 1})

getRequest = ->
   request.get(base_uri + index)

setInterval(postRequest, 2000)
setInterval(postRequest1, 1500)
setInterval(getRequest, 3000)

request mongodb_uri, (error, response, body) ->
  if !error and response.statusCode == 200
    data = JSON.parse body
    console.log data.host
    console.log data.version
    console.log data.uptime
