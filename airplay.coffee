#! /usr/bin/env coffee
http = require 'http'
fs = require 'fs'
os = require 'os'

module.exports = class Airplayer
  constructor: (@host, @port) ->

  request: (method, path, msg="", cb) ->
    options =
      host: @host
      port: @port
      path: "/#{path}"
      method: method
      headers: "Content-Length": msg.length
    req = http.request(options, (res) ->
      body = ""
      res.on 'data', (chunk) -> body += chunk
      res.on 'end', -> cb(null, body) if cb
    )
    req.on 'error', (error) -> cb(error) if cb
    if method != 'GET'
      req.write(msg)
    req.end()

  get: (path, cb) -> @request('GET', path, "", cb)

  post: (path, msg, cb)-> @request('POST', path, msg, cb)

  put: (path, msg, cb) -> @request('PUT', path, msg, cb)

  playmsg: (content_location, start_position) -> "Content-Location: #{content_location}/\nStart-Position: #{start_position}"

  playurl: (url, start_position=0, cb) -> @post('play', @playmsg(url, start_position), cb)

  serve_file: (port, filepath) ->
    http.createServer( (req, res) ->
      res.writeHeader(200, {'Content-Type': 'video/h264'})
      if req.method == "HEAD"
        res.end()
      if req.method == "GET"
        res.writeHeader(200, {'Content-Type': 'video/h264'})
        readstream = fs.createReadStream(filepath)
        readstream.on 'data', (chunk) -> res.write chunk
        readstream.on 'close', -> res.end()
        req.on 'end', => @close()
    ).listen(port)

  playfile: (filepath, start_position=0, cb) ->
    port = 8000
    @serve_file(port, filepath)
    @playurl("http://#{os.hostname()}.local:#{port}", start_position, cb)
  pause: (cb) -> @rate("0.00000", cb)

  playpause: (cb) -> @rate((if is_playing then "0.00000" else "1.00000"), cb)

  stop: -> @post 'stop', "", cb

  set: (param, value, cb, key="value") -> @post "#{param}?#{key}=#{value}", "", cb

  rate: (rate) -> @set("rate", rate, cb)

  volume: (vol, cb) -> @set("volume", vol, cb)

  scrub: (position, cb) ->
    if position
      @set("scrub", position, cb, "position")
    else
      @get 'scrub', cb

  photo: (photo, cb) -> @put 'photo', photo, cb

  playback_info: ->
    plist = require 'plist'
    @get 'playback-info', (result) -> plist.parseString result, cb 
