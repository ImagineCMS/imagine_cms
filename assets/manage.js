//
// Import dependencies
//

const $ = require("jquery");
window.$ = window.jQuery = $;

import CodeMirror from 'codemirror/lib/codemirror.js';
import 'codemirror/mode/htmlmixed/htmlmixed.js';
window.CodeMirror = CodeMirror;

import "phoenix_html";

import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } });
liveSocket.connect()

require("./semantic/dist/semantic.min.js");
// import "./semantic.js";

import "./slideout.js";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
