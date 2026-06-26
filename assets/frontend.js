const $ = require("jquery");
window.$ = window.jQuery = $;

import CodeMirror from 'codemirror/lib/codemirror.js';
import 'codemirror/mode/htmlmixed/htmlmixed.js';
window.CodeMirror = CodeMirror;

require("./semantic/dist/components/checkbox.js");
require("./semantic/dist/components/dimmer.js");
require("./semantic/dist/components/dropdown.js");
require("./semantic/dist/components/form.js");
require("./semantic/dist/components/modal.js");
require("./semantic/dist/components/toast.js");
require("./semantic/dist/components/transition.js");
require("./semantic.js");


window.Imagine = {
  start(config) {
    Imagine.config = {
      toolbarStickyOffset: 52,
      toolbarStickyOffsetMobile: null,
      hugerte: {}
    };

    // merge in config if provided... not quite a deep merge but enough for now
    if (config) {
      if (config.hugerte) config.hugerte = { ...this.config.hugerte, ...config.hugerte };
      this.config = { ...this.config, ...config };
    }
  },

  config: {},
  activeEditor: null,

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

  currentEditor: () => {
    if (Imagine.activeEditor) return Imagine.activeEditor;
    if (window.hugerte && window.hugerte.activeEditor) return window.hugerte.activeEditor;

    const element = document.querySelector(".imagine-cms-rte");
    return element && window.hugerte ? window.hugerte.get(element.id) : null;
  },

  syncEditors: () => {
    if (window.hugerte && window.hugerte.triggerSave) window.hugerte.triggerSave();

    document.querySelectorAll(".imagine-cms-rte").forEach((element) => {
      const textarea = document.getElementById(element.dataset.textareaId);
      const editor = window.hugerte ? window.hugerte.get(element.id) : null;

      if (textarea) textarea.value = editor ? editor.getContent() : element.innerHTML;
    });
  },

  insertHtml: (html) => {
    const editor = Imagine.currentEditor();
    if (!editor) return false;

    editor.focus();
    editor.insertContent(html);
    Imagine.unsavedChanges = true;
    return true;
  },

  chooseLocalFile: (accept, callback) => {
    const input = document.createElement("input");
    input.type = "file";
    input.accept = accept;
    input.style.display = "none";
    document.body.appendChild(input);

    input.addEventListener("change", () => {
      const file = input.files && input.files[0];
      if (!file) {
        input.remove();
        return;
      }

      const reader = new FileReader();
      reader.addEventListener("load", function () {
        callback(file, this.result);
        input.remove();
      }, false);
      reader.readAsDataURL(file);
    });

    input.click();
  },

  insertLocalImage: () => {
    Imagine.chooseLocalFile("image/*", (file, dataUrl) => {
      const alt = file.name.replace(/\.[^.]+$/, "");
      const image = document.createElement("img");
      image.src = dataUrl;
      image.alt = alt;
      image.dataset.filename = file.name;

      Imagine.insertHtml(image.outerHTML);
    });
  },

  insertLocalFileLink: () => {
    Imagine.chooseLocalFile("", (file, dataUrl) => {
      const link = document.createElement("a");
      link.href = dataUrl;
      link.dataset.filename = file.name;
      link.innerText = file.name;

      Imagine.insertHtml(link.outerHTML);
    });
  },

  nudgeToolbarLayout: () => {
    window.clearTimeout(Imagine.resizeNudgeTimer);
    Imagine.resizeNudgeTimer = window.setTimeout(() => {
      window.dispatchEvent(new Event("resize"));
    }, 30);
  },

  bindScrollNudges: (element) => {
    let current = element.parentElement;

    while (current && current !== document.body) {
      const style = window.getComputedStyle(current);
      const scrollable = /(auto|scroll|overlay)/.test(style.overflow + style.overflowX + style.overflowY);

      if (scrollable && !current.dataset.imagineCmsResizeNudge) {
        current.dataset.imagineCmsResizeNudge = "true";
        current.addEventListener("scroll", Imagine.nudgeToolbarLayout, { passive: true });
      }

      current = current.parentElement;
    }

    if (!document.documentElement.dataset.imagineCmsResizeNudge) {
      document.documentElement.dataset.imagineCmsResizeNudge = "true";
      window.addEventListener("scroll", Imagine.nudgeToolbarLayout, { passive: true });
    }
  },

  buildToolbar: () => {
    return "undo redo | blocks | bold italic underline strikethrough removeformat | " +
      "alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | " +
      "link table cmsimage filelink code";
  },

  loadHugeRTE: () => {
    if (window.hugerte) return Promise.resolve(window.hugerte);
    if (Imagine.loadingHugeRTE) return Imagine.loadingHugeRTE;

    Imagine.loadingHugeRTE = new Promise((resolve, reject) => {
      const script = document.createElement("script");
      script.src = "/assets/vendor/hugerte/hugerte.min.js";
      script.onload = () => resolve(window.hugerte);
      script.onerror = () => reject(new Error("Unable to load HugeRTE"));
      document.head.appendChild(script);
    });

    return Imagine.loadingHugeRTE;
  },

  initHugeRTE: () => {
    const regions = Array.from(document.querySelectorAll(".imagine-cms-rte"));
    if (regions.length === 0 || !window.hugerte) return;

    regions.forEach((region) => {
      if (!region.id) region.id = `imagine-cms-rte-${Math.random().toString(36).slice(2)}`;
    });

    let stickyOffset = Imagine.config.toolbarStickyOffset || 52;
    if (Imagine.config.toolbarStickyOffsetMobile && window.innerWidth < 768) {
      stickyOffset = Imagine.config.toolbarStickyOffsetMobile;
    }

    window.hugerte.init({
      selector: ".imagine-cms-rte",
      inline: true,
      promotion: false,
      branding: false,
      menubar: false,
      toolbar_mode: "sliding",
      toolbar_sticky: true,
      toolbar_sticky_offset: stickyOffset,
      base_url: "/assets/vendor/hugerte",
      suffix: ".min",
      plugins: "autolink code image link lists quickbars searchreplace table",
      toolbar: Imagine.buildToolbar(),
      quickbars_insert_toolbar: "cmsimage filelink table",
      quickbars_selection_toolbar: "bold italic underline | link",
      extended_valid_elements: "*[*]",
      valid_children: "+body[style|script],+div[style|script]",
      convert_urls: false,
      entity_encoding: "raw",
      setup: (editor) => {
        editor.on("focus", () => {
          Imagine.activeEditor = editor;
        });
        editor.on("init", () => {
          Imagine.bindScrollNudges(editor.getElement());
        });
        editor.on("change input undo redo setcontent", () => {
          Imagine.unsavedChanges = true;
          const textarea = document.getElementById(editor.getElement().dataset.textareaId);

          if (textarea) {
            textarea.value = editor.getContent();
            textarea.dispatchEvent(new CustomEvent("imagine-cms:content-change", { bubbles: true }));
          }
        });
        editor.ui.registry.addButton("cmsimage", {
          text: "Image",
          tooltip: "Insert image",
          onAction: Imagine.insertLocalImage
        });
        editor.ui.registry.addButton("filelink", {
          text: "File",
          tooltip: "Create download link",
          onAction: Imagine.insertLocalFileLink
        });
      },
      ...Imagine.config.hugerte
    });
  },

  initEditor: () => {
    // set to true when text editor content changes
    // FIXME: also check for other things in the future, like page list settings
    Imagine.unsavedChanges = false;

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

    Imagine.loadHugeRTE().then(() => Imagine.initHugeRTE());

    document.getElementById("Imagine-Save-Page-Content-Button").addEventListener("click", (e) => {
      e.preventDefault();
      Imagine.syncEditors();
      Imagine.unsavedChanges = false;
      window.removeEventListener("beforeunload", warnAboutUnsavedChanges);
      document.getElementById("Imagine-Edit-Content-Form").submit();
    });

    document.getElementById("Imagine-Edit-Content-Form").addEventListener("submit", () => {
      Imagine.syncEditors();
      Imagine.unsavedChanges = false;
      window.removeEventListener("beforeunload", warnAboutUnsavedChanges);
    });

    // push down any fixed elements
    setTimeout(() => {
      document.querySelectorAll(".fixed").forEach((el) => {
        el.style.top = el.offsetTop + toolbar.offsetHeight + 'px';
      });
    });
  }
};
