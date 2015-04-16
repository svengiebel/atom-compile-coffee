# REQUIRES

coffee = require "coffee-script"
fs   = require "fs"
path = require "path"
# loophole fix
# thanks to yhsiang http://discuss.atom.io/t/atom-content-security-policy-error/4425/5
{Function} = require "loophole"

# HELPER FUNCTIONS

getFileContents = (filePath, callback) ->
  content = ''
  fs.readFile filePath, 'utf-8', read = (err, data) ->
    throw err  if err
    callback data

# MAIN FUNCTIONS

compileCoffee = (filepath) ->

  # GET CONFIGS
  bareJs = atom.config.get('atom-compile-coffee.compileBareJavascript')
  generateMaps = atom.config.get('atom-compile-coffee.generateMaps')

  # COMPILE LESS TO CSS
  getFileContents filepath, (content) ->
    throw err if !content
    op = { bare: bareJs, sourceMap : generateMaps }
    op.file = filepath.split('\\').pop().split('/').pop() if generateMaps
    op.sourceRoot = "/"
    op.sourceFiles = op.file
    op.generatedFile = op.file.replace(".coffee", ".js.map")
    jsContent = coffee.compile(content, op)
    v3SourceMap = jsContent.v3SourceMap if jsContent.v3SourceMap
    coffeeToJsPath = filepath.replace(".coffee", ".js")
    coffeeToMapPath = filepath.replace(".coffee", ".js.map")

    jsContent = jsContent.js || jsContent
    ##debugger
    # SAVE COMPILED FILE
    fs.writeFile( coffeeToJsPath, "#{jsContent}\n\/\/@ sourceMappingURL=#{op.file}" , (err) ->
        console.log "FAILED TO COMPILE COFFEE: " + coffeeToJsPath, err if err
        console.log "FRESH COFFEE COMPILED TO: " + coffeeToJsPath
      )
    # SAVE source map FILE
    if generateMaps then fs.writeFile( coffeeToMapPath, v3SourceMap, (err) ->
      console.log "FAILED TO CREATE MAP COFFEE: " + coffeeToMapPath, err if err
      console.log "FRESH COFFEE SPILLED ON MAP TO: " + coffeeToMapPath
    )

atomCompileCoffee = ->

  currentEditor = atom.workspace.getActiveEditor()

  if currentEditor

    # SET COMPILE VARS
    currentFilePath  = currentEditor.getPath()

    if currentFilePath.substr(-7) == ".coffee"

      # SET CONFIG VARS
      projectPath      = atom.project.getPath()

      # COMPILE FILE
      compileCoffee(currentFilePath)

      #loophole fix
      global.Function = Function


# MODULE EXPORT

module.exports =

  activate: (state) =>
    atom.workspaceView.command "core:save", => atomCompileCoffee()

  deactivate: ->

  serialize: ->

module.exports.configDefaults =
    compileBareJavascript:  false
    generateMaps : true
