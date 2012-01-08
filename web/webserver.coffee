

express = require "express"
piler = require "piler"

app = express.createServer()

io = require("socket.io").listen app
io.set "log level", 0


css = piler.createCSSManager()
js = piler.createJSManager()

css.bind app
js.bind app


app.configure ->
  app.set "views", __dirname + "/views"

  js.addFile __dirname + "/client/vendor/jquery.js"
  js.addFile __dirname + "/client/vendor/underscore.js"
  js.addFile __dirname + "/client/vendor/backbone.js"

  js.addFile __dirname + "/client/application.coffee"
  css.addFile __dirname + "/client/style.styl"

app.configure "development", ->
  js.liveUpdate css, io



app.get "/", (req, res) ->
  res.render "index.jade"



exports.app = app
exports.io = io
