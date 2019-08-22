window.addEventListener("DOMContentLoaded", function(event) {
  textArea = document.getElementById('code-editor');
  if (!textArea) {
    return;
  }

  config = { mode: 'ruby', theme: 'twilight', lineNumbers: true };
  if (textArea.hasAttribute('readonly')) {
    config['readOnly'] = 'nocursor';
  }

  CodeMirror.fromTextArea(textArea, config);
});
