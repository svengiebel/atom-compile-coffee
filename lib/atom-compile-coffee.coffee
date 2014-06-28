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

  # COMPILE LESS TO CSS
  getFileContents filepath, (content) ->
    throw err if !content

    jsContent = coffee.compile(content, { bare: bareJs })
    coffeeToJsPath = filepath.replace(".coffee", ".js")

    # SAVE COMPILED FILE
    fs.writeFile( coffeeToJsPath, jsContent, (err) ->
      console.log "FAILED TO COMPILE COFFEE: " + coffeeToJsPath, err if err
      console.log "FRESH COFFEE COMPILED TO: " + coffeeToJsPath

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

  configDefaults:
    compileBareJavascript:  false

  activate: (state) =>
    atom.workspaceView.command "core:save", => atomCompileCoffee()

  deactivate: ->

  serialize: ->
