# Websocket编程

我们将建立一个简单的server,它发回我们发给它所有的内容。

```go
$ go get github.com/gorilla/websocket
```

接下来，我们所有的应用都将使用这个库.

```go
// websockets.go
package main

import (
	"fmt"
	"net/http"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

func main() {
	http.HandleFunc("/echo", func(w http.ResponseWriter, r *http.Request) {
		conn, _ := upgrader.Upgrade(w, r, nil) // error ignored for sake of simplicity

		for {
			// Read message from browser
			msgType, msg, err := conn.ReadMessage()
			if err != nil {
				return
			}

			// Print the message to the console
			fmt.Printf("%s sent: %s\n", conn.RemoteAddr(), string(msg))

			// Write message back to browser
			if err = conn.WriteMessage(msgType, msg); err != nil {
				return
			}
		}
	})

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "websockets.html")
	})

	http.ListenAndServe(":8080", nil)
}
<!-- websockets.html -->
<input id="input" type="text" />
<button onclick="send()">Send</button>
<pre id="output"></pre>
<script>
	var input = document.getElementById("input");
	var output = document.getElementById("output");
	var socket = new WebSocket("ws://localhost:8080/echo");

	socket.onopen = function () {
		output.innerHTML += "Status: Connected\n";
	};

	socket.onmessage = function (e) {
		output.innerHTML += "Server: " + e.data + "\n";
	};

	function send() {
		socket.send(input.value);
		input.value = "";
	}
</script>
$ go run websockets.go
[127.0.0.1]:53403 sent: Hello Go Web Examples, you're doing great!
```