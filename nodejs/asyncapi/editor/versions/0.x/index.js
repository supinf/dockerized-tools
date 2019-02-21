function onCodeChange (cm) {
  var value = cm.getValue();

  superagent
    .post('/code')
    .send(value)
    .set('Accept', 'text/plain')
    .set('Content-Type', 'text/plain')
    .end(function(err, res){
      if (err) {
        document.getElementById('errors').innerHTML = res.body.errors ? JSON.stringify(res.body.errors, null, 2) : res.body.message;
        document.querySelector('.errors-wrapper').classList.remove('errors-wrapper--hidden');
        return;
      }

      var result = res.text;

      document.getElementById('result').innerHTML = result;
      document.querySelector('.errors-wrapper').classList.add('errors-wrapper--hidden');

      bindExpandButtons();

      try {
        localStorage.setItem('doc', value);
        localStorage.setItem('result', result);
      } catch (e) {
        console.error('Could not store result in localStorage.');
      }
    });
}

var editor = CodeMirror.fromTextArea(document.getElementById("code"), {
  mode: "text/yaml",
  lineNumbers: true,
  lineWrapping: true,
  theme: 'material',
  tabSize: 2,
  indentWithTabs: false,
  extraKeys: { Tab: betterTab }
});

function betterTab(cm) {
  if (cm.somethingSelected()) {
    cm.indentSelection("add");
  } else {
    cm.replaceSelection(cm.getOption("indentWithTabs")? "\t":
      Array(cm.getOption("indentUnit") + 1).join(" "), "end", "+input");
  }
}

editor.on('change', _.debounce(onCodeChange, 500));

// Display specified spec if spec.yaml exists in /app/public/spec/ //
superagent
    .get('/spec/spec.yaml')
    .end(function (err, res) {
        if (err) {
            try {
                var doc = localStorage.getItem('doc');
                editor.setValue(doc);
            } catch (e) {
                console.error('Could not read previous document from localStorage.');
                editor.setValue(document.getElementById("code").value);
            }
            return;
        }
        editor.setValue(res.text);
    });
/////////////////////////////////////////////////////////////////////

function bindExpandButtons () {
  var buttons = document.querySelectorAll('.table__expand');

  for(var i=0; i < buttons.length; i++) {
    buttons[i].addEventListener('click', function (e) {
      var tableRow = document.querySelector('[data-nested-index="' + e.target.attributes['data-index'].value + '"]');
      tableRow.classList.toggle('table__body__row--with-nested--expanded');
      e.target.classList.toggle('table__expand--open');
    });
  }
}

document.getElementById('generate-docs').addEventListener('click', function () {
  var value = editor.getValue();

  var form = document.createElement("form");
  form.setAttribute("method", "post");
  form.setAttribute("action", "/generate/docs");
  form.setAttribute("style", "display: none;");

  var text = document.createElement("textarea");
  text.setAttribute("name", "data");
  text.value = value;
  form.appendChild(text);

  document.body.appendChild(form);

  form.submit();
});
