import 'jquery';

import CodeMirror from 'codemirror/lib/codemirror.js';;
import 'codemirror/lib/codemirror.css';
import 'codemirror/mode/htmlmixed/htmlmixed.js';
window.CodeMirror = CodeMirror;

import "./semantic/dist/components/button.css";
import "./semantic/dist/components/checkbox.css";
import "./semantic/dist/components/checkbox";
import "./semantic/dist/components/dimmer.css";
import "./semantic/dist/components/dimmer.js";
import "./semantic/dist/components/dropdown.css";
import "./semantic/dist/components/dropdown.js";
import "./semantic/dist/components/form.css";
import "./semantic/dist/components/form.js";
import "./semantic/dist/components/icon.css";
import "./semantic/dist/components/modal.css";
import "./semantic/dist/components/modal.js";
import "./semantic/dist/components/toast.css";
import "./semantic/dist/components/toast.js";
import "./semantic/dist/components/transition.css";
import "./semantic/dist/components/transition.js";
import "./semantic.scss";
import "./semantic.js";

import "./frontend.scss";


window.Imagine = {
  start(config) {
    Imagine.config = {
      editor: 'redactor',
      redactor: {
        removeScript: false,
        toolbarExternal: '#Imagine-RTE-Toolbar',
        plugins: [],
        clips: [],
        imageResizable: true,
        imagePosition: true,
        imageUpload: this.imageUploadHandler,
        fileUpload: this.fileUploadHandler,
      },
      article: {
        plugins: [
          'blockcode',
          // 'counter',
          // 'inlineformat',
          'reorder',
          // 'selector',
        ],
        toolbar: {
          sticky: false
        },
        image: {
          upload: (upload, data) => { this.handleUpload(upload, data) },
          multiple: false
        },
        format: {
          "p": {
            title: '## format.normal-text ##',
            params: { tag: 'p', block: 'paragraph' }
          },
          "h1": {
            title: '<span style="font-size: 18px; font-weight: bold;">## format.large-heading ## (H1)</span>',
            params: { tag: 'h1', block: 'heading' }
          },
          "h2": {
            title: '<span style="font-size: 16px; font-weight: bold;">## format.medium-heading ## (H2)</span>',
            params: { tag: 'h2', block: 'heading' }
          },
          "h3": {
            title: '<span style="font-weight: bold;">## format.small-heading ## (H3)</span>',
            params: { tag: 'h3', block: 'heading' }
          },
          "ul": {
            title: '&bull; ## format.unordered-list ##',
            params: { tag: 'ul', block: 'list' }
          },
          "ol": {
            title: '1. ## format.ordered-list ##',
            params: { tag: 'ol', block: 'list' }
          }
        },
        subscribe: {
          'editor.focus': function () {
            document.body.querySelectorAll(".arx-toolbar-container").forEach((el) => { el.style.display = "none" });
            this.container.$toolbar.nodes[0].style.display = "flex";
          },
          'editor.content.change': function () {
            this.unsavedChanges = true;
          }
        }
      }
    };

    // merge in config if provided... not quite a deep merge but enough for now
    if (config) {
      if (config.article) config.article = { ...this.config.article, ...config.article };
      if (config.redactor) config.redactor = { ...this.config.redactor, ...config.redactor };
      this.config = { ...this.config, ...config };
    }
  },

  config: {},

  showViewToolbar: (id, path, display_version_options, published_version_options, published_version_class) => {
    const toolbar = document.createElement("div");
    toolbar.id = "Imagine-View-Toolbar";
    toolbar.classList.add("Imagine-Toolbar");
    const pagesURL = "/manage/cms_pages";
    const logoutURL = "/manage/logout";
    const csrf_token = document.querySelector("meta[name=csrf-token]").content;

    if (id) {
      const realPath = path == "" ? "" : `/${path}`;
      const editURL = location.href + (location.href.endsWith("/") ? "" : "/") + "edit";
      const propertiesURL = pagesURL + "/" + id + "/edit";

      toolbar.innerHTML = `<div class="Imagine-Toolbar-Content">
    <a href="${editURL}" id="Imagine-Edit-Page-Content-Button">Edit</a>
    <a href="${propertiesURL}" id="Imagine-Page-Properties-Button">Properties</a>
    <a href="${pagesURL}?cms_page_id=${id}" id="Imagine-Pages-Button">Pages</a>
    <a href="#" id="Imagine-Logout-Button" data-csrf="${csrf_token}" data-method="delete" data-to="${logoutURL}">Log out</a>
    <select id="Imagine-Display-Version-Select">${display_version_options}</select>
    <select id="Imagine-Published-Version-Select">${published_version_options}</select>
    <img id="Imagine-Published-Version-Spinner" src="/images/page_loading.gif" width="16" height="16" style="display: none;">
  </div>`;
      document.body.prepend(toolbar);

      const propertiesButton = document.getElementById("Imagine-Page-Properties-Button");
      propertiesButton.addEventListener("click", (e) => {
        $('#Imagine-Properties-Modal').modal('show');

        $("select.dropdown").dropdown({ placeholder: false, fullTextSearch: true });

        const _editor = CodeMirror.fromTextArea(document.getElementById("Imagine-Properties-Form_html_head"), {
          mode: 'htmlmixed',
          selectionPointer: true,
          lineNumbers: true
        });

        e.preventDefault();
        return false;
      });

      const displayVersionSelect = document.getElementById("Imagine-Display-Version-Select");
      displayVersionSelect.addEventListener("change", () => {
        location.href = `${realPath}/version/${displayVersionSelect.value}`;
      });

      const publishedVersionSelect = document.getElementById("Imagine-Published-Version-Select");
      publishedVersionSelect.classList.toggle("old-version", publishedVersionSelect.selectedIndex > 1);
      publishedVersionSelect.addEventListener("change", () => {
        document.getElementById("Imagine-Published-Version-Spinner").style.display = 'initial';

        const xhr = new XMLHttpRequest();
        const url = `${pagesURL}/${id}/set_published_version/${publishedVersionSelect.value}`;
        xhr.open("POST", url, true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.send(JSON.stringify({
          _csrf_token: csrf_token
        }));

        xhr.onreadystatechange = function () {
          if (this.readyState != 4) return;

          if (this.status == 200) {
            // const data = JSON.parse(this.responseText);

            // we get the returned data
            // console.log("set published version success");
            document.getElementById("Imagine-Published-Version-Spinner").style.display = 'none';

            publishedVersionSelect.classList.toggle("old-version", publishedVersionSelect.selectedIndex > 1);
          }

          // end of state change: it can be after some time (async)
        };
      });
    } else {
      // 404 page
      toolbar.innerHTML = `<div class="Imagine-Toolbar-Content">
    <a href="${pagesURL}" id="Imagine-Pages-Button">Pages</a>
    <a href="#" id="Imagine-Logout-Button" data-csrf="${csrf_token}" data-method="delete" data-to="${logoutURL}">Log out</a>
  </div>`;
      document.body.prepend(toolbar);
    }

    // push down any fixed elements
    setTimeout(() => {
      document.querySelectorAll(".fixed").forEach((el) => {
        el.style.top = el.offsetTop + toolbar.offsetHeight + 'px';
      });
    });
  },

  imageUploadHandler: function (_formData, files, _event, upload) {
    var placeholders = {};

    for (var i = 0; i < files.length; i++) {
      let file = files[i];
      var reader = new FileReader();

      let id = `file-${Imagine.uploadCounter++}`;
      placeholders[id] = { "id": id, "url": "/images/page_loading.gif" };;

      reader.addEventListener("load", function () {
        let image = document.querySelector(`img[data-image='${id}']`);
        image.src = this.result;
        image.alt = file.name;
        image.dataset.filename = file.name;
        delete image.dataset.image;
        // upload.editor.insertion.insertHtml(image.outerHTML);
      }, false);

      reader.readAsDataURL(file);
    };

    return placeholders;
  },

  fileUploadHandler: function (formData, files, _event, upload) {
    var placeholders = {};

    for (var i = 0; i < files.length; i++) {
      let file = files[i];
      var reader = new FileReader();

      let id = `file-${Imagine.uploadCounter++}`;
      placeholders[id] = { "id": id, "url": "" };

      reader.addEventListener("load", function () {
        let link = document.querySelector(`a[data-file='${id}']`);
        link.href = this.result;
        link.dataset.filename = file.name;
        delete link.dataset.file;

        if (link.innerHTML.trim().length == 0) link.innerText = file.name;
        // upload.editor.insertion.insertHtml(link.outerHTML);
      }, false);

      reader.readAsDataURL(file);
    };

    return placeholders;
  },

  initEditor: () => {
    // set to true when text editor content changes
    // FIXME: also check for other things in the future, like page list settings
    Imagine.unsavedChanges = false;
    Imagine.uploadCounter = 0;

    const warnAboutUnsavedChanges = (e) => {
      const confirmationMessage = "This page is asking you to confirm that you want to leave - data you have entered may not be saved.";
      if (Imagine.unsavedChanges) {
        (e || window.event).returnValue = confirmationMessage;
        return confirmationMessage;
      } else {
        return false;
      }
    };
    window.addEventListener("beforeunload", warnAboutUnsavedChanges);

    document.getElementById("Imagine-Cancel-Edit-Page-Content-Button").addEventListener("click", (e) => {
      if (!Imagine.unsavedChanges || confirm('Are you sure you want to throw away any changes to this page since your last save?')) {
        window.removeEventListener("beforeunload", warnAboutUnsavedChanges);
      } else {
        e.preventDefault();
        return false;
      }
    });

    // add edit toolbar
    const toolbar = document.getElementById("Imagine-Edit-Toolbar");
    document.body.prepend(toolbar);
    toolbar.style.display = "block";

    // add editors
    const editorSelector = 'form#Imagine-Edit-Content-Form .Imagine-CmsPageObject-TextEditor .rteditor';

    switch (Imagine.config.editor) {
      case 'redactor':
        $R(editorSelector, Imagine.config.redactor);
        break;

      case 'article':
        window.ArticleEditor(editorSelector, Imagine.config.article);
        break;
    }

    document.getElementById("Imagine-Save-Page-Content-Button").addEventListener("click", (e) => {
      e.preventDefault();
      window.removeEventListener("beforeunload", warnAboutUnsavedChanges);
      document.getElementById("Imagine-Edit-Content-Form").submit();
    });

    // push down any fixed elements
    setTimeout(() => {
      document.querySelectorAll(".fixed").forEach((el) => {
        el.style.top = el.offsetTop + toolbar.offsetHeight + 'px';
      });
    });
  },

  handleUpload: (upload, data) => {
    // loop files (there should only be one, using FileReader makes multiple files difficult)
    for (let i = 0; i < data.files.length; i++) {
      let file = data.files[i];
      let reader = new FileReader();

      // set up handler for when result is ready
      reader.addEventListener("load", function () {
        let response = {};

        response[`file-1`] = {
          "url": this.result,
          // "id": "some-id"
        };

        // call the upload complete callback
        upload.complete(response, data.e);
      }, false);

      // then start the read
      reader.readAsDataURL(file);
    }
  }
};
