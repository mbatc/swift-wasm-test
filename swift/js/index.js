
import { handleMessage, handleOpen, handleClose } from "./swift.js"

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
		ws.send(res);
	};
} else {
	// Bind callbacks to Python impl via pyjs.
	// Currently the entry-point name is passed to Swift via the URL search parameter.
	// I feel like this is not such a great idea but works for now.
	let entryPoint = window.location.search.substring(6);

	window.parent[entryPoint](
		() => { handleOpen(0); console.log('SwiftPyJS connected') },
		() => { handleClose(); console.log('SwiftPyJS closing') },
		msg => { return handleMessage(msg) }
	);
}