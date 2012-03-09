fs = require "fs"

express = require "express"
hbs = require "hbs"
piler = require "piler"

app = express.createServer()

io = require("socket.io").listen app
io.set "log level", 0


css = piler.createCSSManager()
js = piler.createJSManager()

rootDir = __dirname

templateCache = {}
app.configure "production", ->
  console.log "Production mode detected!"
  for filename in fs.readdirSync clientTmplDir
    templateCache[filename] = fs.readFileSync(clientTmplDir + filename).toString()

app.configure ->

  console.log "Production mode detected!"

  # We want use same templating engine for the client and the server. We have
  # to workarount bit so that we can get uncompiled Handlebars templates
  # through Handlebars
  hbs.registerHelper "clientTemplate", (name) ->
    source = templateCache[name + ".hbs"]
    if not source
      # Synchronous file reading is bad, but it doesn't really matter here since
      # we can cache it in production
      source = fs.readFileSync rootDir + "/views/client/#{ name }.hbs"

    "<script type='text/x-template-handlebars' id='#{ name }Template' >#{ source }</script>\n"


hbs.registerHelper "renderScriptTags", (pile) ->
  js.renderTags pile
hbs.registerHelper "renderStyleTags", (pile) ->
  css.renderTags pile

css.bind app
js.bind app


app.configure ->
  app.set "views", __dirname + "/views"
  app.set 'view engine', 'hbs'

  js.addFile __dirname + "/client/vendor/jquery.js"
  js.addFile __dirname + "/client/vendor/handlebars.js"
  js.addFile __dirname + "/client/vendor/underscore.js"
  js.addFile __dirname + "/client/vendor/backbone.js"

  js.addFile __dirname + "/client/helpers.coffee"
  js.addFile __dirname + "/client/main.coffee"
  css.addFile __dirname + "/client/style.styl"

app.configure "development", ->
  js.liveUpdate css, io



app.get "/", (req, res) ->
  res.render "index", app.config.servers



exports.webserver = app
exports.websocket = io
