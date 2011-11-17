http = require 'http'
fs = require 'fs'


invalid_range = (res) ->
  body = "Requested Range Not Satisfiable"
  res.setHeader 'Content-Type', 'text/plain'
  res.setHeader 'Content-Length', body.length
  res.statusCode = 416
  res.end(body)

parse_ranges = (size, rangestr) ->
  # based on the connectjs static middleware
  # Copyright (c) 2010 Sencha Inc. / Copyright (c) 2011 LearnBoost / Copyright (c) 2011 TJ Holowaychuk
  try
    rangestr.substr(6).split(",").map (range) ->
      [start, end] = range.split("-").map (rangepart) -> parseInt rangepart, 10
      if isNaN(start)
        start = size-end
        end = size-1
      else if isNaN(end)
        end = size-1
      if (isNaN(start) || isNaN(end) || start > end)
        throw "invalid range"
      return {start: start, end: end}
  catch e
    return undefined


module.exports = (filepath) ->
  http.createServer((req, res) ->
    ranges = req.headers.range
    fs.stat filepath, (err, stat) ->
      throw err if err
      chunk = stat.size
      opts = {}
      my_opts = {}
      if ranges
        ranges = parse_ranges(stat.size, ranges)
        connect_ranges = undefined
        if ranges
          opts = ranges[0]
          chunk = opts.end - opts.start + 1
          res.statusCode = 206
          res.setHeader 'Content-Range', "bytes #{opts.start}-#{opts.end}/#{stat.size}"
        else
          return invalid_range(res)
      res.setHeader 'Content-Type', 'video/x-msvideo'
      res.setHeader 'Content-Length', chunk
      res.setHeader 'Accept-Ranges', 'bytes'
      return res.end() if req.method is 'HEAD'
      rs = fs.createReadStream(filepath, opts)
      rs.pipe(res)
    #req.on 'end', => @close()
  )
