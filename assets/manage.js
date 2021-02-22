//
// Import dependencies
//

import 'jquery';

import CodeMirror from 'codemirror/lib/codemirror.js';;
import 'codemirror/lib/codemirror.css';
import 'codemirror/mode/htmlmixed/htmlmixed.js';
window.CodeMirror = CodeMirror;

import "phoenix_html";

import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } });
liveSocket.connect()

import "./semantic/dist/semantic.min.js";
import "./semantic/dist/semantic.min.css";
import "./semantic.scss";
// import "./semantic.js";

import "./slideout.js";
import "./slideout.css";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import "./manage.scss";
