var mCompileTimer = null
var mErrors = new Array()
var mExecs = new Array()
var mExecTimer = null
var mFeedback = false

function setShaderFromEditor () {
  if (headerShader !== null) {
    var rawCode = editor.session.doc.getAllLines()
    var rawCodeLength = rawCode.length
    var cleanCode = ''
    var startExp = /(?:\h?[d][1-8]|\h?hush|\h?let|\h?bps)/ig
    var i = 0
    while (i < rawCodeLength) {
      var resultStart = startExp.exec(rawCode[i])
      if (resultStart !== null) {
        while (i < rawCodeLength - 1) {
          cleanCode += '\n'
          i++
          if (rawCode[i].length === 0 || !rawCode[i].trim()) {
            break
          }
        }
      } else {
        cleanCode += rawCode[i] + '\n'
        i++
      }
    }
    // console.log();

    material.fragmentShader = headerShader + '\n\n' + cleanCode

    var result = createShader(material.vertexShader, material.fragmentShader)
    var n = headerShader.split(/\r\n|\r|\n/).length
    setLineErrors(result, n + 2)
    if (result.mSuccess === true) {
      material.needsUpdate = true
    }
  }
}

function setLineErrors (result, lineOffset) {
  while (mErrors.length > 0) {
    var mark = mErrors.pop()
    editor.session.removeMarker(mark)
  }

  editor.session.clearAnnotations()

  if (result.mSuccess === false) {
    // var lineOffset = getHeaderSize();
    var lines = result.mInfo.match(/^.*((\r\n|\n|\r)|$)/gm)
    var tAnnotations = []
    for (var i = 0; i < lines.length; i++) {
      var parts = lines[i].split(':')

      if (parts.length === 5 || parts.length === 6) {
        var annotation = {}
        annotation.row = parseInt(parts[2]) - lineOffset
        annotation.text = parts[3] + ' : ' + parts[4]
        annotation.type = 'error'

        if (debugging) { tAnnotations.push(annotation) }

        var id = editor.session.addMarker(new Range(annotation.row, 0, annotation.row, 1), 'errorHighlight', 'fullLine', false)
        mErrors.push(id)
      }
    }

    if (debugging) {
      console.log(result.mInfo)
      editor.session.setAnnotations(tAnnotations)
    }
  }
}

/// /////////////////////////////////
//  ACE launch
/// /////////////////////////////////
var langTools = ace.require('ace/ext/language_tools')
langTools.setCompleters([langTools.snippetCompleter, langTools.keyWordCompleter])

var editor = ace.edit('editor')
editor.setTheme('ace/theme/monokai')
editor.session.setMode('ace/mode/glsl')
editor.session.setUseWrapMode(true)
editor.session.setUseWorker(true)
editor.session.selection.clearSelection()

editor.setDisplayIndentGuides(false)

editor.setShowPrintMargin(false)
editor.getSession().on('change', function (e) {
  clearTimeout(mCompileTimer)
  mCompileTimer = setTimeout(setShaderFromEditor, 200)
})
editor.$blockScrolling = Infinity
editor.setOptions({
  fontSize: '14pt'
})
