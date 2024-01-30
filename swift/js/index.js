
import { handleMessage, handleOpen, handleClose } from "./swift.js"
import { setParseURLCallback, setRevokeURLCallback } from "./lib.js"

const isEmbedded = window.location.search.startsWith("?pyjs.");

// Open the connection to python
if (!isEmbedded) {
	// Connect to WebSocket hosted by python interpreter
	let connected = false;
	let port = parseInt(window.location.search.slice(1));
	let ws = new WebSocket("ws://localhost:" + port + "/")

	ws.onopen = function(event) {
		connected = true;
		ws.send(handleOpen(event.data));
	}

	ws.onclose = function(event) {
		handleClose();
		connected = false;
	}

	ws.onmessage = function (event) {
		let res = handleMessage(event.data);
		if (res !== undefined) {
			ws.send(res);
		}
	};
} else {
	// Bind callbacks to Python impl via pyjs.
	// Currently the entry-point name is passed to Swift via the URL search parameter.
	// I feel like this is not such a great idea but works for now.
	let entryPoint = window.location.search.substring(6);
	
	window.parent[entryPoint](
		() => { 
			console.log('SwiftPyJS connected')
			try {
				handleOpen(0);
			} catch (e) {
				console.error(e);
			}
		},

		() => { 
			console.log('SwiftPyJS closing');
			try {
				handleClose();
			} catch (e) {
				console.error(e);
			}
		},

		msg => {
			try {
				return handleMessage(msg)
			} catch (e) {
				console.error(e);
			}
		}
	);
	
	setParseURLCallback(
		url => {
			let bytes = window.parent.pyjs.FS.readFile(url);
			let blob  = new Blob([bytes]);
			return URL.createObjectURL(blob);
		}
	);

	setRevokeURLCallback(url => URL.revokeObjectURL(url))
}