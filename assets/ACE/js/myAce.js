var Range = ace.require('ace/range').Range
var mCompileTimer = null
var mErrors = new Array()

function sendShaderFromEditor () {
  // window.webkit.messageHandlers.myApp.postMessage("that's something")
  var message = {}
  message.what = 'code'
  message.data = editor.getValue()
  window.webkit.messageHandlers.myApp.postMessage(message)
}

function setLineErrors (result, lineOffset, markers) {
  clearErrors()
  var tAnnotations = []

  for (var i = 0; result.length > i; ++i) {
    var annotation = result[i]
    // var lineOffset = getHeaderSize();
    console.log(annotation)
    if (markers === true) {
      tAnnotations.push(annotation)
    }

    var id = editor.session.addMarker(new Range(annotation.row, 0, annotation.row, 1), 'errorHighlight', 'fullLine', false)
    mErrors.push(id)
  }

  if (markers === true) {
    editor.session.setAnnotations(tAnnotations)
  }
}

function clearErrors () {
  while (mErrors.length > 0) {
    var mark = mErrors.pop()
    editor.session.removeMarker(mark)
  }

  editor.session.clearAnnotations()
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
editor.setDisplayIndentGuides(false)
editor.setShowPrintMargin(false)
editor.getSession().on('change', function (e) {
  clearTimeout(mCompileTimer)
  mCompileTimer = setTimeout(sendShaderFromEditor, 200)
})
editor.$blockScrolling = Infinity
editor.setOptions({
  fontSize: '14pt'
})
editor.session.selection.clearSelection()
editor.focus()
