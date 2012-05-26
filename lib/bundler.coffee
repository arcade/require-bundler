fs = require 'fs'
path = require 'path'
util = require 'util'
cwd = process.cwd()

bundler = (program) ->
    conf =  loadFile(program.conf)
    out = cwd + '/' + program.out

    bundles = (readBundle bundle for bundle in conf)

    try
        fs.statSync out
    catch e
        fs.mkdirSync out

    writeBundle out, bundle for bundle in bundles

loadFile = (file) ->
    if (file.charAt(0) != '/')
        file = cwd + '/' + file

    try
        fs.statSync(file)
    catch e
        throw new Error "File #{file} not found"

    try
        data = require(file)
    catch e
        throw new Error "File #{file} is not valid JSON"

    return data

readBundle = (bundle) ->
    scripts = (loadScript script for script in bundle.modules)
        #try

    return {
        name: bundle.name,
        scripts: scripts
    }

loadScript = (script) ->
    ext = '.js'

    if (~script.indexOf('cs!'))
        ext = '.coffee'
        script = script.replace('cs!', '')

    file = cwd + '/' + script + ext

    code = fs.readFileSync file, 'utf-8'
    code = code.slice(0, 7) + "'" + script + "', " + code.slice(6)

    return {
        code: code
        ext: ext
    }

writeBundle = (out, bundle) ->
    path = out + '/' + bundle.name + '.js'
    code = (script.code for script in bundle.scripts).join('\n')
    fs.writeFileSync(path, code)
    console.log "Successfully wrote #{path}"

module.exports = bundler

